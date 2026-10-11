import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const fields = [
  "name",
  "korean_name",
  "english_name",
  "address",
  "city",
  "region",
  "country",
  "slug",
] as const;

type Input = Partial<Record<(typeof fields)[number], string>>;
type Candidate = {
  latitude: number;
  longitude: number;
  label: string;
  address: string;
  source: "maptiler";
  confidence: number;
  reason: string;
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

function inputFrom(value: unknown): Input | null {
  if (value == null || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }
  const raw = value as Record<string, unknown>;
  return Object.fromEntries(
    fields
      .map((field) => [field, raw[field]?.toString().trim()] as const)
      .filter(([, fieldValue]) => fieldValue),
  ) as Input;
}

function queryFrom(input: Input): string {
  return fields
    .map((field) => input[field]?.trim())
    .filter(Boolean)
    .join(", ");
}

async function normalizeWithGemini(
  query: string,
  geminiKey: string | undefined,
  warnings: string[],
): Promise<string> {
  if (!geminiKey) {
    warnings.push("Gemini chưa được cấu hình; đã dùng trực tiếp tên và địa chỉ do Admin nhập.");
    return query;
  }

  try {
    const prompt = [
      "Normalize this Korean cultural location into one concise geocoding query.",
      "Return JSON only in the form {\"query\":\"...\"}.",
      "Do not invent an address or alter facts.",
      `Input: ${query}`,
    ].join(" ");
    const model = Deno.env.get("GEMINI_COORDINATE_MODEL") ??
      Deno.env.get("GEMINI_TRANSLATION_MODEL") ??
      "gemini-3.1-flash-lite";
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${encodeURIComponent(geminiKey)}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
        signal: AbortSignal.timeout(10000),
      },
    );
    if (!response.ok) throw new Error("Gemini response was not successful");

    const payload: any = await response.json();
    const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof text !== "string") throw new Error("Gemini response has no text");
    const parsed = JSON.parse(text.replace(/^```(?:json)?\s*|\s*```$/g, ""));
    if (typeof parsed.query !== "string" || !parsed.query.trim()) {
      throw new Error("Gemini response has no query");
    }
    return parsed.query.trim();
  } catch (_) {
    warnings.push("Không thể chuẩn hóa truy vấn bằng Gemini; đã dùng trực tiếp tên và địa chỉ do Admin nhập.");
    return query;
  }
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }
  if (request.method !== "POST") return json({ error: "Phương thức không được hỗ trợ." }, 405);

  const authorization = request.headers.get("Authorization");
  if (!authorization) return json({ error: "Bạn cần đăng nhập." }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const mapTilerKey = Deno.env.get("MAPTILER_API_KEY");
  if (!supabaseUrl || !anonKey || !mapTilerKey) {
    return json({ error: "Tính năng gợi ý vị trí chưa được cấu hình." }, 503);
  }

  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false },
  });
  const { data: isAdmin, error: adminError } = await supabase.rpc("is_admin");
  if (adminError || isAdmin !== true) {
    return json({ error: "Bạn không có quyền quản trị." }, 403);
  }

  let rawInput: unknown;
  try {
    rawInput = await request.json();
  } catch (_) {
    return json({ error: "Dữ liệu gửi lên không hợp lệ." }, 400);
  }
  const input = inputFrom(rawInput);
  if (input == null) return json({ error: "Dữ liệu gửi lên không hợp lệ." }, 400);

  const originalQuery = queryFrom(input);
  if (!originalQuery) {
    return json({
      status: "no_result",
      candidates: [],
      warnings: ["Thiếu tên hoặc địa chỉ địa điểm."],
    });
  }

  const warnings: string[] = [];
  const query = await normalizeWithGemini(
    originalQuery,
    Deno.env.get("GEMINI_API_KEY"),
    warnings,
  );
  const url =
    `https://api.maptiler.com/geocoding/${encodeURIComponent(query)}.json?key=${encodeURIComponent(mapTilerKey)}&limit=5&language=ko,en`;

  try {
    const response = await fetch(url, { signal: AbortSignal.timeout(10000) });
    if (!response.ok) {
      return json({ error: "Dịch vụ gợi ý vị trí đang tạm thời không khả dụng." }, 502);
    }

    const payload: any = await response.json();
    const features = Array.isArray(payload.features) ? payload.features : [];
    const candidates = features
      .map((feature: any): Candidate | null => {
        const [longitude, latitude] = feature.center ?? [];
        if (
          typeof latitude !== "number" ||
          typeof longitude !== "number" ||
          latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180
        ) {
          return null;
        }
        const confidence =
          typeof feature.relevance === "number" ? feature.relevance : 0;
        return {
          latitude,
          longitude,
          label: (feature.text ?? feature.place_name ?? "").toString(),
          address: (feature.place_name ?? "").toString(),
          source: "maptiler",
          confidence,
          reason: confidence >= 0.8
            ? "Kết quả khớp cao; Admin vẫn cần kiểm tra."
            : "Cần Admin kiểm tra trước khi áp dụng.",
        };
      })
      .filter((candidate: Candidate | null): candidate is Candidate =>
        candidate != null
      );

    if (candidates.length > 1) {
      warnings.push("Có nhiều kết quả; hãy chọn đúng địa điểm trước khi áp dụng.");
    }
    return json({
      status: candidates.length === 0
        ? "no_result"
        : candidates.length === 1
        ? "ok"
        : "ambiguous",
      candidates,
      warnings,
    });
  } catch (_) {
    return json({ error: "Dịch vụ gợi ý vị trí đang tạm thời không khả dụng." }, 502);
  }
});