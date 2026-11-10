// Input checks shared by the callable functions (freemium-plus NFR1).
import { logger } from 'firebase-functions';
import { CallableRequest, FunctionsErrorCode, HttpsError } from 'firebase-functions/v2/https';

/** An error the app can act on: `details.reason` is a stable code. */
export function callableError(
  code: FunctionsErrorCode,
  reason: string,
  message: string,
): HttpsError {
  return new HttpsError(code, message, { reason });
}

/** The caller's uid; the uid always comes from Auth, never from the data. */
export function requireUid(request: CallableRequest<unknown>): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw callableError('unauthenticated', 'UNAUTHENTICATED', 'Sign in first.');
  }
  return uid;
}

/** The request data as a plain object, or an invalid-argument error. */
export function requireObject(data: unknown): Record<string, unknown> {
  if (data === null || data === undefined) return {};
  if (typeof data !== 'object' || Array.isArray(data)) {
    throw callableError('invalid-argument', 'INVALID_REQUEST', 'Expected an object.');
  }
  return data as Record<string, unknown>;
}

export function invalid(field: string): HttpsError {
  return callableError('invalid-argument', 'INVALID_REQUEST', `Invalid field: ${field}`);
}

/** A non-negative safe integer field. */
export function requireCount(data: Record<string, unknown>, field: string): number {
  const value = data[field];
  if (typeof value !== 'number' || !Number.isSafeInteger(value) || value < 0) {
    throw invalid(field);
  }
  return value;
}

/** A string field matching [pattern]. */
export function requireString(
  data: Record<string, unknown>,
  field: string,
  pattern: RegExp,
): string {
  const value = data[field];
  if (typeof value !== 'string' || !pattern.test(value)) throw invalid(field);
  return value;
}

/**
 * Runs a callable body: an [HttpsError] goes to the app as it is, anything
 * else is logged (without request data) and becomes `internal`.
 */
export async function runCallable<T>(name: string, body: () => Promise<T>): Promise<T> {
  try {
    return await body();
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    logger.error(`${name} failed`, { error: (error as Error)?.name, message: (error as Error)?.message });
    throw callableError('internal', 'INTERNAL', 'Something went wrong; retry later.');
  }
}
