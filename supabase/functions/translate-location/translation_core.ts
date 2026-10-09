export type TranslationLocale = "en" | "ko";

export interface TranslationRequest {
  targetLocale: TranslationLocale;
  content: unknown;
  model: string;
  apiKey: string;
  fetcher?: typeof fetch;
}

interface TranslationAssessment {
  valid: boolean;
  reason?: string;
}

export class TranslationProviderError extends Error {
  readonly detail?: string;

  constructor(
    message: string,
    detail?: string,
  ) {
    super(message);
    this.name = "TranslationProviderError";
    this.detail = detail;
  }
}

export function buildTranslationPrompt(
  targetLocale: TranslationLocale,
  content: unknown,
  retryReason?: string,
): string {
  const language = targetLocale === "ko" ? "Korean (한국어)" : "English";
  return [
    "You are a professional localization translator for an educational app.",
    "The source language is Vietnamese (vi).",
    `The target language is ${language}.`,
    `Translate every learner-facing Vietnamese sentence into ${language}; never copy Vietnamese sentences into the result.`,
    "Return only valid JSON with exactly the same keys, arrays, IDs and value types.",
    "Do not translate URLs, UUIDs, slugs, enum values, media metadata, romanization, or Korean Hangul vocabulary.",
    "Translate names for display, descriptions, instructions, quiz prompts/options/explanations, labels and travel text.",
    "Preserve placeholders and do not add facts. Use natural educational language.",
    ifRetry(retryReason),
    JSON.stringify(content),
  ].filter((line) => line.length > 0).join("\n");
}

function ifRetry(reason?: string): string {
  return reason == null
    ? ""
    : `The previous answer was rejected: ${reason}. Translate again and verify the target-language text before responding.`;
}

const vietnameseCharacters =
  /[ăâđêôơưáàảãạấầẩẫậắằẳẵặéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ]/iu;
const hangulCharacters = /[가-힣]/u;

function collectStrings(
  value: unknown,
  path = "$",
  result = new Map<string, string>(),
): Map<string, string> {
  if (typeof value === "string") {
    result.set(path, value);
  } else if (Array.isArray(value)) {
    value.forEach((item, index) =>
      collectStrings(item, `${path}[${index}]`, result)
    );
  } else if (value !== null && typeof value === "object") {
    Object.entries(value).forEach(([key, item]) =>
      collectStrings(item, `${path}.${key}`, result)
    );
  }
  return result;
}

export function assessTranslation(
  targetLocale: TranslationLocale,
  source: unknown,
  translated: unknown,
): TranslationAssessment {
  if (JSON.stringify(source) === JSON.stringify(translated)) {
    return {
      valid: false,
      reason: targetLocale === "ko"
        ? "Korean translation still contains Vietnamese source text"
        : "English translation still contains Vietnamese source text",
    };
  }

  const sourceStrings = collectStrings(source);
  const translatedStrings = collectStrings(translated);
  const vietnameseEntries = [...sourceStrings.entries()].filter(([, value]) =>
    vietnameseCharacters.test(value)
  );
  if (vietnameseEntries.length === 0) return { valid: true };

  let unchanged = 0;
  let stillVietnamese = 0;
  let withHangul = 0;
  for (const [path, sourceValue] of vietnameseEntries) {
    const translatedValue = translatedStrings.get(path) ?? "";
    if (translatedValue.trim() === sourceValue.trim()) unchanged++;
    if (vietnameseCharacters.test(translatedValue)) stillVietnamese++;
    if (hangulCharacters.test(translatedValue)) withHangul++;
  }

  const maximumUntranslated = Math.floor(vietnameseEntries.length * 0.25);
  const lacksTargetLanguage = targetLocale === "ko" &&
    withHangul < Math.ceil(vietnameseEntries.length * 0.6);
  if (
    unchanged > maximumUntranslated ||
    stillVietnamese > maximumUntranslated ||
    lacksTargetLanguage
  ) {
    return {
      valid: false,
      reason: targetLocale === "ko"
        ? "Korean translation still contains Vietnamese source text"
        : "English translation still contains Vietnamese source text",
    };
  }
  return { valid: true };
}

export async function translateContent({
  targetLocale,
  content,
  model,
  apiKey,
  fetcher = fetch,
}: TranslationRequest): Promise<unknown> {
  let retryReason: string | undefined;
  for (let attempt = 0; attempt < 2; attempt++) {
    const response = await fetcher(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{
            role: "user",
            parts: [{
              text: buildTranslationPrompt(
                targetLocale,
                content,
                retryReason,
              ),
            }],
          }],
          generationConfig: {
            responseMimeType: "application/json",
            temperature: 0.1,
          },
        }),
      },
    );
    if (!response.ok) {
      throw new TranslationProviderError(
        "Translation provider failed",
        await response.text(),
      );
    }

    const payload = await response.json();
    const raw = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof raw !== "string") {
      throw new TranslationProviderError("Translation provider returned no JSON");
    }

    let translated: unknown;
    try {
      translated = JSON.parse(raw);
    } catch (_) {
      throw new TranslationProviderError(
        "Translation provider returned invalid JSON",
      );
    }
    const assessment = assessTranslation(targetLocale, content, translated);
    if (assessment.valid) return translated;
    retryReason = assessment.reason;
  }

  throw new TranslationProviderError(
    retryReason ?? "Translation output failed validation",
  );
}
