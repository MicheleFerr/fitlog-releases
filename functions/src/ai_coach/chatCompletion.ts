/**
 * 🤖 AI Coach Chat Completion (Server-Side OpenRouter Proxy)
 *
 * Security goals:
 * - Keep OPENROUTER_API_KEY only on backend
 * - Enforce auth + App Check
 * - Rate limit requests
 * - Validate payload to prevent abuse/cost spikes
 */

import { HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import * as https from 'node:https';
import * as admin from 'firebase-admin';
import { withRateLimit, RATE_LIMITS } from '../security/rateLimiterV1';
import { getEffectiveAccountTier } from '../premium/entitlements';

interface ChatMessage {
  role: string;
  content: string;
}

interface ChatCompletionRequest {
  model?: string;
  messages?: unknown;
  tools?: unknown;
  maxTokens?: number;
}

interface OpenRouterToolCall {
  id: string;
  name: string;
  arguments: Record<string, unknown>;
}

interface QuotaSnapshot {
  accountTier: AccountTier;
  usedToday: number;
  limitPerDay: number;
  remainingToday: number;
}

const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions';
const DEFAULT_MODEL = 'meta-llama/llama-3.3-70b-instruct';
const ALLOWED_MODELS = new Set([DEFAULT_MODEL]);
const DEFAULT_MAX_TOKENS = 1000;
const MAX_MESSAGES = 50;
const MAX_MESSAGE_LENGTH = 30000;
const MAX_TOTAL_MESSAGE_CHARS = 120000;
const MAX_TOOLS = 32;
const FREE_DAILY_LIMIT = 20;
const PREMIUM_DAILY_LIMIT = 200;

/**
 * Callable function for AI chat completions.
 */
export const aiCoachChatCompletion = withRateLimit<ChatCompletionRequest>(
  async (request) => {
    const startedAt = Date.now();

    if (!request.app) {
      throw new HttpsError(
        'failed-precondition',
        'App Check token is required.'
      );
    }

    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const apiKey = process.env.OPENROUTER_API_KEY;
    if (!apiKey) {
      throw new HttpsError(
        'failed-precondition',
        'OPENROUTER_API_KEY is not configured on backend.'
      );
    }

    const data = request.data ?? {};
    const messages = validateMessages(data.messages);
    const tools = validateTools(data.tools);
    const maxTokens = validateMaxTokens(data.maxTokens);
    const model = selectModel(data.model);
    const accountTier = await getUserAccountTier(request.auth.uid);
    const quota = await consumeDailyQuota(
      request.auth.uid,
      accountTier
    );

    logger.info('ai_coach_request', {
      model,
      accountTier,
      messageCount: messages.length,
      toolsCount: tools.length,
      maxTokens,
      quotaUsedToday: quota.usedToday,
      quotaLimitPerDay: quota.limitPerDay,
      quotaRemainingToday: quota.remainingToday,
    });

    const requestBody: Record<string, unknown> = {
      model,
      messages,
      max_tokens: maxTokens,
    };

    if (tools.length > 0) {
      requestBody.tools = tools;
      requestBody.tool_choice = 'auto';
    }

    try {
      const response = await postJson(
        OPENROUTER_URL,
        {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://fitlog.app',
          'X-Title': 'FitLog AI Coach',
        },
        JSON.stringify(requestBody),
        105000
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        logger.warn('ai_coach_upstream_error', {
          statusCode: response.statusCode,
          responseBodyLength: response.body.length,
        });

        if (response.statusCode === 429) {
          throw new HttpsError(
            'resource-exhausted',
            'AI provider temporarily rate-limited. Please retry shortly.',
            { source: 'upstream_provider' }
          );
        }

        if (response.statusCode >= 400 && response.statusCode < 500) {
          throw new HttpsError(
            'failed-precondition',
            'AI provider rejected the request. Please retry.',
            { source: 'upstream_provider', statusCode: response.statusCode }
          );
        }

        throw new HttpsError(
          'unavailable',
          'AI provider unavailable. Please retry shortly.',
          { source: 'upstream_provider', statusCode: response.statusCode }
        );
      }

      const parsed = safeParseJson(response.body);
      const responseData = toRecord(parsed);
      const choices = Array.isArray(responseData['choices']) ? responseData['choices'] : [];

      if (choices.length === 0) {
        throw new HttpsError('internal', 'OpenRouter returned no choices.');
      }

      const firstChoice = toRecord(choices[0]);
      const message = toRecord(firstChoice['message']);
      const content = typeof message['content'] === 'string' ? message['content'] : '';
      const finishReason = typeof firstChoice['finish_reason'] === 'string' ? firstChoice['finish_reason'] : null;
      const toolCalls = parseToolCalls(message['tool_calls']);

      logger.info('ai_coach_success', {
        model,
        finishReason,
        responseChars: content.length,
        toolCallsCount: toolCalls.length,
        durationMs: Date.now() - startedAt,
        quotaRemainingToday: quota.remainingToday,
      });

      return {
        content,
        finishReason,
        toolCalls,
        modelUsed: model,
        quota,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        logger.warn('ai_coach_known_error', {
          code: error.code,
          detailsSource: toRecord(error.details)['source'] ?? 'unknown',
          durationMs: Date.now() - startedAt,
        });
        throw error;
      }

      logger.error('ai_coach_unhandled_error', {
        error: error instanceof Error ? error.message : String(error),
        durationMs: Date.now() - startedAt,
      });

      throw new HttpsError(
        'internal',
        'AI Coach backend request failed.'
      );
    }
  },
  {
    ...RATE_LIMITS.STANDARD,
    identifier: 'aiCoachChatCompletion',
    trackBy: 'user',
    secrets: ['OPENROUTER_API_KEY'],
    timeoutSeconds: 120,
  }
);

function validateMessages(rawMessages: unknown): ChatMessage[] {
  if (!Array.isArray(rawMessages)) {
    throw new HttpsError('invalid-argument', '`messages` must be an array.');
  }

  if (rawMessages.length === 0) {
    throw new HttpsError('invalid-argument', '`messages` cannot be empty.');
  }

  if (rawMessages.length > MAX_MESSAGES) {
    throw new HttpsError(
      'invalid-argument',
      `Too many messages. Maximum allowed is ${MAX_MESSAGES}.`
    );
  }

  let totalChars = 0;
  const sanitized = rawMessages.map((raw, index) => {
    const item = toRecord(raw);
    const role = typeof item['role'] === 'string' ? item['role'] : '';
    const content = typeof item['content'] === 'string' ? item['content'] : '';

    if (!role || typeof item['content'] !== 'string') {
      throw new HttpsError(
        'invalid-argument',
        `Message at index ${index} must contain string role/content.`
      );
    }

    if (!['system', 'user', 'assistant', 'tool'].includes(role)) {
      throw new HttpsError(
        'invalid-argument',
        `Invalid role at index ${index}: ${role}`
      );
    }

    if (content.length > MAX_MESSAGE_LENGTH) {
      throw new HttpsError(
        'invalid-argument',
        `Message at index ${index} exceeds ${MAX_MESSAGE_LENGTH} characters.`
      );
    }

    totalChars += content.length;
    return { role, content };
  });

  if (totalChars > MAX_TOTAL_MESSAGE_CHARS) {
    throw new HttpsError(
      'invalid-argument',
      `Total message size exceeds ${MAX_TOTAL_MESSAGE_CHARS} characters.`
    );
  }

  return sanitized;
}

type AccountTier = 'free' | 'premium';

function getDateKeyUTC(date: Date): string {
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, '0');
  const d = String(date.getUTCDate()).padStart(2, '0');
  return `${y}${m}${d}`;
}

async function getUserAccountTier(userId: string): Promise<AccountTier> {
  try {
    return await getEffectiveAccountTier(userId);
  } catch (_error) {
    return 'free';
  }
}

function getDailyLimit(accountTier: AccountTier): number {
  return accountTier === 'premium' ? PREMIUM_DAILY_LIMIT : FREE_DAILY_LIMIT;
}

async function consumeDailyQuota(userId: string, accountTier: AccountTier): Promise<QuotaSnapshot> {
  const now = new Date();
  const dateKey = getDateKeyUTC(now);
  const limit = getDailyLimit(accountTier);
  const usageRef = admin.firestore()
    .collection('aiCoachDailyUsage')
    .doc(`${userId}_${dateKey}`);

  let usedAfterIncrement = 0;

  await admin.firestore().runTransaction(async (tx) => {
    const snapshot = await tx.get(usageRef);
    const usedNow = snapshot.exists
      ? Number(toRecord(snapshot.data())['count'] ?? 0)
      : 0;

    if (usedNow >= limit) {
      const quotaExceeded: QuotaSnapshot = {
        accountTier,
        usedToday: usedNow,
        limitPerDay: limit,
        remainingToday: 0,
      };
      throw new HttpsError(
        'resource-exhausted',
        `Daily AI Coach quota reached (${limit}/day).`,
        {
          source: 'daily_quota',
          quota: quotaExceeded,
        }
      );
    }

    usedAfterIncrement = usedNow + 1;
    const expiresAt = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000);

    tx.set(
      usageRef,
      {
        userId,
        accountTier,
        dateKey,
        count: usedAfterIncrement,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      },
      { merge: true }
    );
  });

  return {
    accountTier,
    usedToday: usedAfterIncrement,
    limitPerDay: limit,
    remainingToday: Math.max(0, limit - usedAfterIncrement),
  };
}

function validateTools(rawTools: unknown): Record<string, unknown>[] {
  if (rawTools == null) {
    return [];
  }

  if (!Array.isArray(rawTools)) {
    throw new HttpsError('invalid-argument', '`tools` must be an array when provided.');
  }

  if (rawTools.length > MAX_TOOLS) {
    throw new HttpsError(
      'invalid-argument',
      `Too many tools. Maximum allowed is ${MAX_TOOLS}.`
    );
  }

  return rawTools.map((tool, index) => {
    const item = toRecord(tool);
    const type = item['type'];
    const fn = toRecord(item['function']);

    if (type !== 'function' || typeof fn['name'] !== 'string') {
      throw new HttpsError(
        'invalid-argument',
        `Invalid tool format at index ${index}.`
      );
    }

    return item;
  });
}

function validateMaxTokens(rawMaxTokens: unknown): number {
  if (rawMaxTokens == null) {
    return DEFAULT_MAX_TOKENS;
  }

  if (typeof rawMaxTokens !== 'number' || !Number.isInteger(rawMaxTokens)) {
    throw new HttpsError('invalid-argument', '`maxTokens` must be an integer.');
  }

  if (rawMaxTokens < 1 || rawMaxTokens > 2000) {
    throw new HttpsError('invalid-argument', '`maxTokens` must be between 1 and 2000.');
  }

  return rawMaxTokens;
}

function selectModel(rawModel: unknown): string {
  if (typeof rawModel === 'string' && ALLOWED_MODELS.has(rawModel)) {
    return rawModel;
  }

  return DEFAULT_MODEL;
}

function parseToolCalls(rawToolCalls: unknown): OpenRouterToolCall[] {
  if (!Array.isArray(rawToolCalls)) {
    return [];
  }

  return rawToolCalls.map((raw) => {
    const tool = toRecord(raw);
    const fn = toRecord(tool['function']);
    const argsString = typeof fn['arguments'] === 'string' ? fn['arguments'] : '{}';

    let args: Record<string, unknown> = {};
    try {
      const parsed = safeParseJson(argsString);
      args = toRecord(parsed);
    } catch (_error) {
      args = {};
    }

    return {
      id: typeof tool['id'] === 'string' ? tool['id'] : '',
      name: typeof fn['name'] === 'string' ? fn['name'] : 'unknown',
      arguments: args,
    };
  });
}

function safeParseJson(value: string): unknown {
  try {
    return JSON.parse(value);
  } catch (_error) {
    throw new HttpsError('internal', 'Invalid JSON from upstream AI provider.');
  }
}

function toRecord(value: unknown): Record<string, unknown> {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return {};
}

async function postJson(
  url: string,
  headers: Record<string, string>,
  body: string,
  timeoutMs: number
): Promise<{ statusCode: number; body: string }> {
  const target = new URL(url);

  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: target.hostname,
        path: `${target.pathname}${target.search}`,
        method: 'POST',
        headers: {
          ...headers,
          'Content-Length': Buffer.byteLength(body).toString(),
        },
      },
      (res) => {
        const chunks: Buffer[] = [];

        res.on('data', (chunk: Buffer) => {
          chunks.push(chunk);
        });

        res.on('end', () => {
          resolve({
            statusCode: res.statusCode ?? 0,
            body: Buffer.concat(chunks).toString('utf8'),
          });
        });
      }
    );

    req.on('error', (err) => reject(err));
    req.setTimeout(timeoutMs, () => {
      req.destroy(new Error('OpenRouter request timeout'));
    });

    req.write(body);
    req.end();
  });
}
