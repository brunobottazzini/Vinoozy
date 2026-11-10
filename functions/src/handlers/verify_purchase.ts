// verifyPurchase (freemium-plus FR3.3; study §5.2, §5.3): the only way a
// bought Plus becomes an entitlement.
import { logger } from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';

import { PACKAGE_NAME, PLUS_PRODUCT_ID } from '../config.js';
import { Deps } from '../deps.js';
import { isPlusValidAt } from '../domain/entitlement.js';
import { plusLineItem, PlaySubscription, PlayVerdict, verdictFor } from '../domain/play_state.js';
import { PlayPurchaseNotFoundError, PlayUnavailableError } from '../clients/play_client.js';
import { callableError, requireObject } from './callable_support.js';
import {
  acknowledgeIfNeeded,
  applyVerdictInTx,
  entitlementRef,
  logTag,
  purchaseRef,
  stateName,
  tokenHash,
} from './purchase_store.js';

export interface VerifyPurchaseResponse {
  /** pending | active | grace | on_hold | paused | expired | revoked | none */
  state: string;
  plusActive: boolean;
  expiresAt: string | null;
  acknowledged: boolean;
}

const TOKEN = /^[A-Za-z0-9._:\-]{1,4096}$/;

interface VerifyInput {
  purchaseToken: string;
}

function parseInput(raw: unknown): VerifyInput {
  const data = requireObject(raw);
  const token = data.purchaseToken;
  if (typeof token !== 'string' || !TOKEN.test(token)) {
    throw callableError('invalid-argument', 'INVALID_TOKEN', 'Invalid purchase token.');
  }
  if (data.packageName !== undefined && data.packageName !== PACKAGE_NAME) {
    throw callableError('failed-precondition', 'WRONG_PACKAGE', 'Purchase of another app.');
  }
  if (data.productId !== undefined && data.productId !== PLUS_PRODUCT_ID) {
    throw callableError('failed-precondition', 'WRONG_PRODUCT', 'Not a Plus purchase.');
  }
  return { purchaseToken: token };
}

function tokenInUse(): Error {
  return callableError(
    'permission-denied',
    'TOKEN_IN_USE',
    'This purchase belongs to another account.',
  );
}

/** Throws when [hash] is already bound to an account other than [uid]. */
async function assertNotBoundElsewhere(deps: Deps, hash: string, uid: string): Promise<void> {
  const owner = (await purchaseRef(deps, hash).get()).data()?.uid;
  if (typeof owner === 'string' && owner !== uid) throw tokenInUse();
}

async function readPlay(deps: Deps, token: string, hash: string): Promise<PlaySubscription> {
  try {
    return await deps.play.getSubscription(token);
  } catch (error) {
    if (error instanceof PlayPurchaseNotFoundError) {
      logger.warn('verifyPurchase: unknown token', { purchase: logTag(hash) });
      throw callableError('not-found', 'PURCHASE_NOT_FOUND', 'Play does not know this purchase.');
    }
    if (error instanceof PlayUnavailableError) {
      throw callableError('unavailable', 'PLAY_UNAVAILABLE', 'Google Play is not reachable; retry later.');
    }
    throw error;
  }
}

/** Binds the token to [uid] and applies [verdict], in one transaction. */
async function bindAndApply(params: {
  deps: Deps;
  uid: string;
  hash: string;
  token: string;
  verdict: PlayVerdict;
}): Promise<PlayVerdict> {
  const { deps, uid, hash, token } = params;
  return deps.db.runTransaction(async (tx) => {
    const record = (await tx.get(purchaseRef(deps, hash))).data();
    if (typeof record?.uid === 'string' && record.uid !== uid) throw tokenInUse();
    // A revocation is final for this token, whatever Play reports later.
    const verdict: PlayVerdict =
      record?.revoked === true && params.verdict.kind === 'entitlement'
        ? { ...params.verdict, status: 'revoked' }
        : params.verdict;
    const now = Timestamp.fromDate(deps.now());
    await applyVerdictInTx({
      tx,
      deps,
      uid,
      hash,
      verdict,
      recordPatch: {
        uid,
        purchaseToken: token,
        productId: PLUS_PRODUCT_ID,
        revoked: record?.revoked === true,
        acknowledged: record?.acknowledged === true,
        lastEventAtMillis: typeof record?.lastEventAtMillis === 'number' ? record.lastEventAtMillis : 0,
        createdAt: record?.createdAt instanceof Timestamp ? record.createdAt : now,
      },
    });
    return verdict;
  });
}

export async function verifyPurchaseHandler(
  deps: Deps,
  uid: string,
  rawData: unknown,
): Promise<VerifyPurchaseResponse> {
  const { purchaseToken } = parseInput(rawData);
  const hash = tokenHash(purchaseToken);
  await assertNotBoundElsewhere(deps, hash, uid);
  const sub = await readPlay(deps, purchaseToken, hash);
  const item = plusLineItem(sub);
  if (!item) {
    throw callableError('failed-precondition', 'WRONG_PRODUCT', 'Not a Plus purchase.');
  }
  if (sub.linkedPurchaseToken) {
    await assertNotBoundElsewhere(deps, tokenHash(sub.linkedPurchaseToken), uid);
  }
  const verdict = await bindAndApply({
    deps,
    uid,
    hash,
    token: purchaseToken,
    verdict: verdictFor(sub, item, deps.now(), false),
  });
  const acknowledged = await acknowledgeIfNeeded({ deps, hash, purchaseToken, sub, verdict });
  const entitlement = (await entitlementRef(deps, uid).get()).data();
  logger.info('verifyPurchase', { purchase: logTag(hash), state: stateName(verdict) });
  return {
    state: stateName(verdict),
    plusActive: isPlusValidAt(entitlement, deps.now()),
    expiresAt:
      verdict.kind === 'entitlement' && verdict.expiresAt
        ? verdict.expiresAt.toISOString()
        : null,
    acknowledged,
  };
}
