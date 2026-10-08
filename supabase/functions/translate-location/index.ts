import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const authorization = request.headers.get("Authorization");
  if (!authorization) return jsonResponse({ error: "Unauthorized" }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  if (!supabaseUrl || !anonKey || !geminiKey) {
    return jsonResponse({ error: "Server translation is not configured" }, 503);
  }

  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false },
  });
  const { data: isAdmin, error: adminError } = await supabase.rpc("is_admin");
  if (adminError || isAdmin !== true) {
    return jsonResponse({ error: "Admin access required" }, 403);
  }

  let body: { target_locale?: string; content?: unknown };
  try {
    body = await request.json();
  } catch (_) {
    return jsonResponse({ error: "Invalid JSON body" }, 400);
  }
  if (!body.content || !["en", "ko"].includes(body.target_locale ?? "")) {
    return jsonResponse({ error: "target_locale and content are required" }, 400);
  }

  const language = body.target_locale === "ko" ? "Korean" : "English";
  const prompt = [
    `Translate the user-facing text in the following KoreaQuest JSON to ${language}.`,
    "Return only valid JSON with exactly the same keys, arrays, IDs and value types.",
    "Do not translate URLs, UUIDs, slugs, enum values, media metadata, romanization, or Korean Hangul vocabulary.",
    "Translate names for display, descriptions, instructions, quiz prompts/options/explanations, labels and travel text.",
    "Preserve placeholders and do not add facts. Use natural educational language.",
    JSON.stringify(body.content),
  ].join("\n");

  const model = Deno.env.get("GEMINI_TRANSLATION_MODEL") ?? "gemini-3.1-flash-lite";
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${geminiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ role: "user", parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType: "application/json", temperature: 0.2 },
      }),
    },
  );
  if (!response.ok) {
    const detail = await response.text();
    return jsonResponse({ error: "Translation provider failed", detail }, 502);
  }

  const payload = await response.json();
  const raw = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof raw !== "string") {
    return jsonResponse({ error: "Translation provider returned no JSON" }, 502);
  }
  try {
    return jsonResponse({ content: JSON.parse(raw) });
  } catch (_) {
    return jsonResponse({ error: "Translation provider returned invalid JSON" }, 502);
  }
});
