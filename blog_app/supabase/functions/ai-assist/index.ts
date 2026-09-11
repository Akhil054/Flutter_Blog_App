/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const HF_ROUTER_URL = "https://router.huggingface.co/v1/chat/completions";
const HF_MODEL = "Qwen/Qwen3-8B";

const SYSTEM_PROMPT =
  "You are an assistant embedded in a blogging app. " +
  "Reply ONLY with a single valid JSON object, no prose, no markdown fences, no <think> tags.";

interface RequestBody {
  action: "summarize" | "suggest_metadata";
  title?: string;
  content: string;
  allowedTopics?: string[];
}

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/// Qwen3 is a "thinking" model by default - even with enable_thinking:false
/// (which not every Inference Providers backend honors) it can still wrap
/// its answer in prose or a ```json fence, so this pulls the JSON object
/// out of whatever text comes back instead of assuming raw.trim() is JSON.
function extractJson(raw: string): unknown {
  const withoutThink = raw.replace(/<think>[\s\S]*?<\/think>/gi, "");
  const start = withoutThink.indexOf("{");
  const end = withoutThink.lastIndexOf("}");
  const candidate = start !== -1 && end !== -1
    ? withoutThink.slice(start, end + 1)
    : withoutThink;
  return JSON.parse(candidate);
}

async function callHf(userPrompt: string) {
  const response = await fetch(HF_ROUTER_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${Deno.env.get("HF_TOKEN")}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: HF_MODEL,
      response_format: { type: "json_object" },
      temperature: 0.4,
      max_tokens: 1024,
      chat_template_kwargs: { enable_thinking: false },
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: userPrompt },
      ],
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new HfError(errorText);
  }

  const data = await response.json();
  const raw = data.choices?.[0]?.message?.content ?? "{}";
  return extractJson(raw);
}

class HfError extends Error {}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body: RequestBody = await req.json();
    const content = (body.content ?? "").trim();

    if (content.length < 20) {
      return jsonResponse(
        { error: "content must be at least 20 characters" },
        400,
      );
    }

    if (body.action === "summarize") {
      const result = await callHf(
        `Summarize the following blog post as a 2-3 sentence TL;DR. ` +
          `Reply as JSON: {"summary": string}.\n\nContent:\n${content}`,
      );
      return jsonResponse(result);
    }

    if (body.action === "suggest_metadata") {
      const allowedTopics = body.allowedTopics ?? [];
      const result = await callHf(
        `Given the blog title and content below, suggest a better title, ` +
          `1-3 relevant topics chosen ONLY from this list: ${
            JSON.stringify(allowedTopics)
          }, ` +
          `and a 2-3 sentence summary. ` +
          `Reply as JSON: {"suggestedTitle": string, "suggestedTopics": string[], "summary": string}.\n\n` +
          `Title: ${body.title ?? ""}\nContent:\n${content}`,
      );
      return jsonResponse(result);
    }

    return jsonResponse({ error: `unknown action: ${body.action}` }, 400);
  } catch (error) {
    if (error instanceof HfError) {
      return jsonResponse({ error: error.message }, 502);
    }
    return jsonResponse({ error: String(error) }, 500);
  }
});
