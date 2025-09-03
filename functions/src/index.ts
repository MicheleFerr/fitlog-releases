/**
 * GymBro Cloud Functions
 * Main entry point for all serverless functions
 */

import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export premium purchase verification functions
export { 
  verifyPremiumPurchase,
  checkExpiredSubscriptions 
} from './premium/verifyPremiumPurchase';

// Export sync functions (if needed in future)
// export { processSync } from './sync/processSync';

// Export analytics functions (if needed in future)
// export { aggregateWorkoutStats } from './analytics/aggregateStats';