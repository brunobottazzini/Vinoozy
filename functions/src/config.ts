// Constants shared by every Vinoozy Cloud Function (freemium-plus D4).

/** Region of the Firestore database (docs/firebase-setup.md, FR9.3). */
export const FUNCTIONS_REGION = 'europe-west8';

/**
 * Android application id checked against Play (FR3.3): the Google Play
 * package, `applicationId` of android/app/build.gradle.kts. It is not the
 * Kotlin namespace `com.vinoozy.vinoozy`.
 */
export const PACKAGE_NAME = 'com.vinoozy.app';

/**
 * The Plus subscription product and its base plans. The owner creates them
 * in Play Console with exactly these ids (docs/plus-setup.md).
 */
export const PLUS_PRODUCT_ID = 'vinoozy_plus';
export const PLUS_BASE_PLANS: readonly string[] = ['monthly', 'annual'];

/** Firestore collections (firestore.rules: client never writes them). */
export const Collections = {
  entitlements: 'entitlements',
  config: 'config',
  usage: 'usage',
  periods: 'periods',
  devices: 'devices',
  adSlots: 'adSlots',
  days: 'days',
  purchases: 'purchases',
  playEvents: 'playEvents',
  billingEvents: 'billingEvents',
} as const;

/** Document id of the product policy inside `config`. */
export const POLICY_DOC_ID = 'policy';

/**
 * Pub/Sub topics. They can be renamed per project with `functions/.env`
 * (PLAY_RTDN_TOPIC, BUDGET_ALERT_TOPIC); the defaults are the names
 * docs/blaze-switch.md and docs/plus-setup.md tell the owner to create.
 */
export const PLAY_RTDN_TOPIC = process.env.PLAY_RTDN_TOPIC ?? 'play-rtdn';
export const BUDGET_ALERT_TOPIC =
  process.env.BUDGET_ALERT_TOPIC ?? 'budget-alerts';

/** Measurement details are kept for 90 days (NFR6, study §7.6). */
export const DETAIL_RETENTION_DAYS = 90;

/**
 * Minimum time between two accepted new reports of one installation. The
 * app uploads at most every 15 minutes plus at the end of a session and at
 * the first crossing (NFR3); anything faster is refused, not counted.
 */
export const MIN_REPORT_INTERVAL_MS = 10_000;
