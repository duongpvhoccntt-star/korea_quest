import assert from "node:assert/strict";
import test from "node:test";

import { translateContent } from "./translation_core.ts";

const vietnameseSource = {
  detail: {
    city: "Seoul",
    name: "Tháp Namsan Seoul",
    quiz: [{ prompt: "Namsan Seoul Tower mở cửa cho công chúng vào năm nào?" }],
  },
};

test("rejects a Korean translation that merely echoes Vietnamese", async () => {
  let callCount = 0;
  const echoingGemini = async () => {
    callCount++;
    return new Response(JSON.stringify({
      candidates: [{
        content: {
          parts: [{ text: JSON.stringify(vietnameseSource) }],
        },
      }],
    }), { status: 200, headers: { "Content-Type": "application/json" } });
  };

  await assert.rejects(
    translateContent({
      targetLocale: "ko",
      content: vietnameseSource,
      model: "test-model",
      apiKey: "test-key",
      fetcher: echoingGemini,
    }),
    /Korean translation still contains Vietnamese source text/,
  );
  assert.equal(callCount, 2);
});

test("retries once and accepts a real Korean translation", async () => {
  const koreanTranslation = {
    detail: {
      city: "서울",
      name: "남산서울타워",
      quiz: [{ prompt: "남산서울타워는 몇 년에 일반에 공개되었나요?" }],
    },
  };
  const prompts = [];
  const retryingGemini = async (_url, init) => {
    prompts.push(JSON.parse(init.body).contents[0].parts[0].text);
    const content = prompts.length === 1 ? vietnameseSource : koreanTranslation;
    return new Response(JSON.stringify({
      candidates: [{ content: { parts: [{ text: JSON.stringify(content) }] } }],
    }), { status: 200, headers: { "Content-Type": "application/json" } });
  };

  const translated = await translateContent({
    targetLocale: "ko",
    content: vietnameseSource,
    model: "test-model",
    apiKey: "test-key",
    fetcher: retryingGemini,
  });

  assert.deepEqual(translated, koreanTranslation);
  assert.equal(prompts.length, 2);
  assert.match(prompts[1], /previous answer was rejected/i);
  assert.match(prompts[1], /Korean translation still contains Vietnamese/);
});
