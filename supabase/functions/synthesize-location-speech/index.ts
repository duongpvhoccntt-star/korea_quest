import { createClient } from "npm:@supabase/supabase-js@2";

const bucket = "location-speech";
const cacheVersion = "cloud-tts-v1";
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const voices: Record<string, { languageCode: string; name: string }> = {
  vi: { languageCode: "vi-VN", name: "vi-VN-Neural2-A" },
  ko: { languageCode: "ko-KR", name: "ko-KR-Neural2-A" },
  en: { languageCode: "en-US", name: "en-US-Neural2-F" },
};
const validSegments = new Set([
  "overview", "history", "highlight", "experience", "food", "fun_fact", "transport",
]);
type Input = { slug: string; locale: "vi" | "en" | "ko"; segment: string; index?: number };
const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status, headers: { ...cors, "Content-Type": "application/json" },
});
const invalid = (status = 400) => reply({ error: "Yêu cầu đọc nội dung không hợp lệ." }, status);
const record = (value: unknown): Record<string, unknown> | null =>
  value != null && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown> : null;
const value = (item: unknown) => typeof item === "string" ? item.trim() : "";
const spoken = (items: unknown[]) => items.flatMap((item) =>
  Array.isArray(item) ? item.map(value) : [value(item)]
).filter(Boolean).join("\n\n");

function inputFrom(rawValue: unknown): Input | null {
  const raw = record(rawValue);
  if (raw == null) return null;
  const slug = value(raw.slug);
  const locale = value(raw.locale);
  const segment = value(raw.segment);
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug) ||
      !(locale in voices) || !validSegments.has(segment)) return null;
  const indexed = segment !== "overview";
  if (indexed && (typeof raw.index !== "number" || !Number.isInteger(raw.index) || raw.index < 0)) return null;
  if (!indexed && raw.index !== undefined) return null;
  return { slug, locale: locale as Input["locale"], segment, ...(indexed ? { index: raw.index as number } : {}) };
}
function at(parent: Record<string, unknown>, key: string, index: number): Record<string, unknown> | null {
  return Array.isArray(parent[key]) ? record(parent[key][index]) : null;
}

// This accepts a selector, never browser-supplied prose. The anon RPC is the
// authorization boundary and returns null for Draft or non-public locations.
function textFor(detail: Record<string, unknown>, input: Input): string | null {
  if (input.segment === "overview") return spoken([
    detail.name, detail.korean_name, detail.long_description || detail.short_description,
    detail.city, detail.region, detail.country, detail.location_type, detail.address,
  ]);
  if (input.segment === "transport") {
    const travel = record(detail.travel);
    const item = travel == null ? null : at(travel, "transport_options", input.index!);
    return item == null ? null : spoken([item.mode, item.title, item.instructions, item.tip]);
  }
  const keys: Record<string, string> = {
    history: "history", highlight: "highlights", experience: "experiences",
    food: "foods", fun_fact: "fun_facts",
  };
  const item = at(detail, keys[input.segment], input.index!);
  if (item == null) return null;
  switch (input.segment) {
    case "history": return spoken([item.period_label, item.title, item.short_description, item.long_description, item.related_people, item.fun_fact]);
    case "highlight": return spoken([item.name, item.korean_name, item.tagline, item.short_description, item.long_description, item.address, item.activities, item.categories, item.fun_fact]);
    case "experience": return spoken([item.name, item.korean_name, item.short_description, item.long_description, item.origin_meaning, item.recognizable_features, item.dos, item.donts, item.related_experience]);
    case "food": return spoken([item.name, item.korean_name, item.short_description, item.long_description, item.special_feature, item.ingredients, item.flavors, item.experience_places]);
    case "fun_fact": return spoken([item.title, item.fact]);
    default: return null;
  }
}
async function hash(input: string): Promise<string> {
  const bytes = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(input));
  return Array.from(new Uint8Array(bytes)).map((byte) => byte.toString(16).padStart(2, "0")).join("");
}
function minute(): string { const now = new Date(); now.setSeconds(0, 0); return now.toISOString(); }
function ip(request: Request): string {
  return request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ||
    request.headers.get("x-real-ip")?.trim() || "unknown";
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (request.method !== "POST") return invalid(405);
  let input: Input | null;
  try { input = inputFrom(await request.json()); } catch (_) { return invalid(); }
  if (input == null) return invalid();
  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const googleKey = Deno.env.get("GOOGLE_CLOUD_TTS_API_KEY");
  const salt = Deno.env.get("SPEECH_RATE_LIMIT_SALT");
  if (!url || !anonKey || !serviceKey || !googleKey || !salt) {
    return reply({ error: "Dịch vụ giọng đọc chưa được cấu hình." }, 503);
  }
  const published = createClient(url, anonKey, { auth: { persistSession: false, autoRefreshToken: false } });
  const { data, error } = await published.rpc("get_published_location", {
    target_slug: input.slug, requested_locale: input.locale,
  });
  const detail = record(data);
  if (error || detail == null) return invalid(404);
  const prose = textFor(detail, input);
  if (prose == null || !prose) return invalid(404);
  const voice = voices[input.locale];
  const clipped = prose.slice(0, 4500);
  const objectHash = await hash([
    cacheVersion, value(detail.revision_id), input.locale, input.segment,
    input.index ?? "", voice.name, clipped,
  ].join("|"));
  const path = cacheVersion + "/" + input.locale + "/" + objectHash + ".mp3";
  const service = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
  const publicUrl = () => service.storage.from(bucket).getPublicUrl(path).data.publicUrl;
  const { data: cached } = await service.from("storage.objects").select("id")
    .eq("bucket_id", bucket).eq("name", path).maybeSingle();
  if (cached != null) return reply({ audio_url: publicUrl(), cache_hit: true });

  const { data: allowed, error: rateError } = await service.rpc("consume_location_speech_cache_miss", {
    p_client_hash: await hash(salt + ":" + ip(request)),
    p_window_started_at: minute(),
    p_limit: 12,
  });
  if (rateError || allowed !== true) {
    return reply({ error: "Bạn đã yêu cầu tạo giọng đọc quá nhanh. Vui lòng thử lại sau một phút." }, 429);
  }
  try {
    const provider = await fetch(
      "https://texttospeech.googleapis.com/v1/text:synthesize?key=" + encodeURIComponent(googleKey),
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ input: { text: clipped }, voice, audioConfig: { audioEncoding: "MP3" } }),
        signal: AbortSignal.timeout(15000),
      },
    );
    const payload = await provider.json() as { audioContent?: unknown };
    if (!provider.ok || typeof payload.audioContent !== "string" || !payload.audioContent) throw new Error("TTS failure");
    const audio = Uint8Array.from(atob(payload.audioContent), (char) => char.charCodeAt(0));
    const { error: uploadError } = await service.storage.from(bucket).upload(path, audio, {
      contentType: "audio/mpeg", cacheControl: "31536000", upsert: false,
    });
    if (uploadError) {
      const { data: raced } = await service.from("storage.objects").select("id")
        .eq("bucket_id", bucket).eq("name", path).maybeSingle();
      if (raced == null) throw uploadError;
    }
    return reply({ audio_url: publicUrl(), cache_hit: false });
  } catch (_) {
    return reply({ error: "Dịch vụ giọng đọc tạm thời không khả dụng." }, 502);
  }
});
