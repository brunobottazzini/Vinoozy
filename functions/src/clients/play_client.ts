// The Google Play Developer API behind an interface, so tests inject a fake
// (freemium-plus D4). Credentials: only the runtime service account through
// Application Default Credentials, never a key file (NFR1).
import { PACKAGE_NAME } from '../config.js';
import { PlaySubscription } from '../domain/play_state.js';

/** Play does not know the token (fake, other package, expired long ago). */
export class PlayPurchaseNotFoundError extends Error {
  constructor() {
    super('Play does not know this purchase token');
    this.name = 'PlayPurchaseNotFoundError';
  }
}

/** Play could not be reached or failed: retry later. */
export class PlayUnavailableError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'PlayUnavailableError';
  }
}

export interface PlayClient {
  /** `purchases.subscriptionsv2.get` for [PACKAGE_NAME]. */
  getSubscription(purchaseToken: string): Promise<PlaySubscription>;

  /** `purchases.subscriptions.acknowledge`. */
  acknowledge(productId: string, purchaseToken: string): Promise<void>;
}

function httpStatusOf(error: unknown): number | undefined {
  const candidate = error as {
    status?: unknown;
    code?: unknown;
    response?: { status?: unknown };
  };
  for (const value of [candidate?.response?.status, candidate?.status, candidate?.code]) {
    if (typeof value === 'number') return value;
  }
  return undefined;
}

/** Maps a Play API failure to the two errors the handlers understand. */
export function mapPlayError(error: unknown): Error {
  const status = httpStatusOf(error);
  if (status === 400 || status === 404 || status === 410) {
    return new PlayPurchaseNotFoundError();
  }
  // The message of a googleapis error never contains the token.
  return new PlayUnavailableError(`Play API failed (status ${status ?? 'unknown'})`);
}

/** The real client (googleapis androidpublisher v3), loaded lazily. */
export class GooglePlayClient implements PlayClient {
  private api: Promise<any> | null = null;

  private publisher(): Promise<any> {
    if (!this.api) {
      this.api = import('googleapis').then(({ google }) => {
        const auth = new google.auth.GoogleAuth({
          scopes: ['https://www.googleapis.com/auth/androidpublisher'],
        });
        return google.androidpublisher({ version: 'v3', auth });
      });
    }
    return this.api;
  }

  async getSubscription(purchaseToken: string): Promise<PlaySubscription> {
    const api = await this.publisher();
    try {
      const response = await api.purchases.subscriptionsv2.get({
        packageName: PACKAGE_NAME,
        token: purchaseToken,
      });
      return response.data as PlaySubscription;
    } catch (error) {
      throw mapPlayError(error);
    }
  }

  async acknowledge(productId: string, purchaseToken: string): Promise<void> {
    const api = await this.publisher();
    try {
      await api.purchases.subscriptions.acknowledge({
        packageName: PACKAGE_NAME,
        subscriptionId: productId,
        token: purchaseToken,
        requestBody: {},
      });
    } catch (error) {
      throw mapPlayError(error);
    }
  }
}

/**
 * The client of the Functions emulator: Play is never called from a local
 * run (tests inject their own fake).
 */
export class EmulatorPlayClient implements PlayClient {
  async getSubscription(): Promise<PlaySubscription> {
    throw new PlayUnavailableError('Play API is not available in the emulator');
  }

  async acknowledge(): Promise<void> {
    throw new PlayUnavailableError('Play API is not available in the emulator');
  }
}
