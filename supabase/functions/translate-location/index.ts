import { createClient } from "npm:@supabase/supabase-js@2";
import {
  translateContent,
  TranslationProviderError,
  type TranslationLocale,
} from "./translation_core.ts";

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

  const model = Deno.env.get("GEMINI_TRANSLATION_MODEL") ?? "gemini-3.1-flash-lite";
  try {
    const content = await translateContent({
      targetLocale: body.target_locale as TranslationLocale,
      content: body.content,
      model,
      apiKey: geminiKey,
    });
    return jsonResponse({ content });
  } catch (error) {
    if (error instanceof TranslationProviderError) {
      return jsonResponse({ error: error.message, detail: error.detail }, 502);
    }
    return jsonResponse({ error: "Translation provider failed" }, 502);
  }
});
