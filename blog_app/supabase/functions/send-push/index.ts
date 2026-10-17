/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

/// Called by the `on_notification_created` trigger (pg_net) on INSERT into
/// public.notifications. Looks up the recipient's FCM device tokens and
/// sends each one a push via the FCM HTTP v1 API, so "X liked your blog" /
/// "X posted a new blog" reach the user even when the app is in the
/// background or closed.
///
/// Deployed with --no-verify-jwt: the trigger authenticates with the
/// x-webhook-secret header instead of a JWT.
///
/// Secrets (supabase secrets set ...):
///   FIREBASE_SERVICE_ACCOUNT - the full service-account JSON downloaded from
///                              Firebase console > Project settings > Service accounts
///   SEND_PUSH_SECRET         - same value as the `send_push_secret` Vault secret
/// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided automatically.

import { createClient } from "npm:@supabase/supabase-js@2";

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: { id: string } | null;
}

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const serviceAccount: ServiceAccount = JSON.parse(
  Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}",
);

function base64Url(input: ArrayBuffer | string) {
  const bytes = typeof input === "string"
    ? new TextEncoder().encode(input)
    : new Uint8Array(input);
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/// Google OAuth access tokens last an hour - cache one per warm instance
/// instead of signing a new JWT for every notification.
let cachedToken: { value: string; expiresAt: number } | null = null;

// authenticate with google & jwt _> firebase pvt key & exchange for access 
async function getAccessToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.value;
  }

  const now = Math.floor(Date.now() / 1000);
  const header = base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = base64Url(JSON.stringify({
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const unsigned = `${header}.${claims}`;

  const pem = serviceAccount.private_key
    .replace(/-----(BEGIN|END) PRIVATE KEY-----/g, "")
    .replace(/\s/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64Url(signature)}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!response.ok) {
    throw new Error(`Google OAuth failed: ${await response.text()}`);
  }

  const data = await response.json();
  cachedToken = {
    value: data.access_token,
    expiresAt: Date.now() + data.expires_in * 1000,
  };
  return cachedToken.value;
}

/// cr edge func for fcm push & in background & close 
Deno.serve(async (req) => {
  const webhookSecret = Deno.env.get("SEND_PUSH_SECRET");
  if (!webhookSecret || req.headers.get("x-webhook-secret") !== webhookSecret) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }

  try {
    const payload: WebhookPayload = await req.json();
    if (payload.type !== "INSERT" || !payload.record?.id) {
      return jsonResponse({ skipped: true });
    }

    /// re-read the row rather than trusting the request body, so a caller
    /// can only (re)send a notification that really exists in the table
    const { data: notification, error } = await supabase
      .from("notifications")
      .select("id, recipient_id, type, blog_id, title, body")
      .eq("id", payload.record.id)
      .maybeSingle();
    if (error) throw error;
    if (!notification) return jsonResponse({ skipped: "not found" });

    const { data: tokens, error: tokensError } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", notification.recipient_id);
    if (tokensError) throw tokensError;
    if (!tokens?.length) return jsonResponse({ sent: 0 });

    /// send to device 
    const accessToken = await getAccessToken();
    const fcmUrl =
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

    const staleTokens: string[] = [];
    let sent = 0;

    await Promise.all(tokens.map(async ({ token }: { token: string }) => {
      const response = await fetch(fcmUrl, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token,
            notification: {
              title: notification.title,
              body: notification.body,
            },
            /// the app uses notification_id to tell these apart from other
            /// pushes (it already shows them itself via Realtime while in
            /// the foreground) and blog_id to open the blog when tapped
            data: {
              notification_id: notification.id,
              type: notification.type,
              blog_id: notification.blog_id ?? "",
            },
            android: {
              priority: "high",
              notification: { channel_id: "high_importance_channel" },
            },
            apns: { payload: { aps: { sound: "default" } } },
          },
        }),
      });

      if (response.ok) {
        sent++;
        return;
      }

      const errorText = await response.text();
      /// the app was uninstalled or the token rotated - drop it
      if (response.status === 404 || errorText.includes("UNREGISTERED")) {
        staleTokens.push(token);
      } else {
        console.error(`FCM send failed (${response.status}): ${errorText}`);
      }
    }));

    if (staleTokens.length) {
      await supabase.from("device_tokens").delete().in("token", staleTokens);
    }

    return jsonResponse({ sent, removed: staleTokens.length });
  } catch (error) {
    console.error(error);
    return jsonResponse({ error: String(error) }, 500);
  }
});
