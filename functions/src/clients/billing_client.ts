// Cloud Billing behind an interface (freemium-plus FR9.2). The runtime
// service account needs the Billing Account Administrator (or Project
// Billing Manager) role on the project, set up by docs/blaze-switch.md.
import { logger } from 'firebase-functions';

export interface BillingClient {
  /** Whether a billing account is linked to `projects/{projectId}`. */
  isBillingEnabled(projectId: string): Promise<boolean>;

  /** Unlinks the billing account: the project falls back to free quotas. */
  disableBilling(projectId: string): Promise<void>;
}

/** The real client (@google-cloud/billing), loaded lazily. */
export class GoogleBillingClient implements BillingClient {
  private client: Promise<any> | null = null;

  private billing(): Promise<any> {
    if (!this.client) {
      this.client = import('@google-cloud/billing').then(
        ({ CloudBillingClient }) => new CloudBillingClient(),
      );
    }
    return this.client;
  }

  async isBillingEnabled(projectId: string): Promise<boolean> {
    const client = await this.billing();
    const [info] = await client.getProjectBillingInfo({
      name: `projects/${projectId}`,
    });
    return info?.billingEnabled === true;
  }

  async disableBilling(projectId: string): Promise<void> {
    const client = await this.billing();
    await client.updateProjectBillingInfo({
      name: `projects/${projectId}`,
      projectBillingInfo: { billingAccountName: '' },
    });
  }
}

/** The emulator never touches a real billing account: it only logs. */
export class EmulatorBillingClient implements BillingClient {
  async isBillingEnabled(): Promise<boolean> {
    return true;
  }

  async disableBilling(projectId: string): Promise<void> {
    logger.warn('Emulator: billing would be disabled', { projectId });
  }
}
