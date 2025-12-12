/**
 * Type declarations for node-apple-receipt-verify
 */
declare module 'node-apple-receipt-verify' {
  interface ConfigOptions {
    secret: string;
    environment?: ('production' | 'sandbox')[];
    excludeOldTransactions?: boolean;
    extended?: boolean;
  }

  interface ValidateOptions {
    receipt: string;
  }

  interface Product {
    productId: string;
    transactionId: string;
    originalTransactionId: string;
    bundleId: string;
    expiresDate?: string;
    purchaseDate?: string;
    originalPurchaseDate?: string;
    quantity?: number;
    cancellationDate?: string;
  }

  export function config(options: ConfigOptions): void;
  export function validate(options: ValidateOptions): Promise<Product[]>;
}
