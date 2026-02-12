"use strict";
/**
 * Generate Exercise Popularity Bundle - Scheduled Cloud Function
 *
 * Scheduled: Daily at 3am UTC+1 (Europe/Rome)
 * Purpose: Generate Firestore Data Bundle with exercise popularity counts
 * Output: Upload bundle to Firebase Storage at /bundles/latest.bundle
 *
 * Data Bundles provide:
 * - Zero read costs for clients (bundle is cached)
 * - Offline-first support
 * - Single download instead of batch queries
 *
 * @see docs/design/EXERCISE_POPULARITY_RANKING.md
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.generatePopularityBundle = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firebase_functions_1 = require("firebase-functions");
const admin = __importStar(require("firebase-admin"));
/**
 * Generate popularity data bundle and upload to Storage
 *
 * Execution:
 * - Fetches all documents from /exercise_popularity collection
 * - Creates Firestore Data Bundle with named query
 * - Uploads bundle to Storage with 24h cache
 *
 * Cost: ~$0.011/month (30 executions × ~1000 docs × $0.036/100k reads)
 * Bundle size: ~100KB for 1000 exercises
 */
exports.generatePopularityBundle = (0, scheduler_1.onSchedule)({
    schedule: '0 3 * * *', // Every day at 3am
    timeZone: 'Europe/Rome',
    timeoutSeconds: 540, // 9 minutes (sufficient for 10k+ exercises)
    memory: '1GiB',
}, async () => {
    const db = admin.firestore();
    const storage = admin.storage();
    try {
        firebase_functions_1.logger.info('📊 Starting popularity bundle generation...');
        // 1. Fetch all popularity counts
        const popularitySnapshot = await db
            .collection('exercise_popularity')
            .get();
        firebase_functions_1.logger.info(`✅ Fetched ${popularitySnapshot.size} popularity documents`);
        if (popularitySnapshot.empty) {
            firebase_functions_1.logger.warn('⚠️  No popularity data found, skipping bundle generation');
            return;
        }
        // 2. Create Firestore Data Bundle
        const bundleId = `popularity_${new Date().toISOString().split('T')[0]}`;
        const bundle = db.bundle(bundleId);
        // Add named query to bundle (clients will use this query name)
        bundle.add('exercise_popularity', popularitySnapshot);
        // 3. Build bundle buffer
        const bundleBuffer = bundle.build();
        firebase_functions_1.logger.info(`📦 Bundle created: ${bundleId}`);
        firebase_functions_1.logger.info(`   Size: ${bundleBuffer.length} bytes (${(bundleBuffer.length / 1024).toFixed(2)} KB)`);
        // 4. Upload to Firebase Storage
        const bucket = storage.bucket();
        const file = bucket.file('bundles/latest.bundle');
        await file.save(bundleBuffer, {
            contentType: 'application/firestore-bundle',
            metadata: {
                cacheControl: 'public, max-age=86400', // Cache 24 hours
                customMetadata: {
                    generatedAt: new Date().toISOString(),
                    documentCount: String(popularitySnapshot.size),
                    bundleId: bundleId,
                    sizeBytes: String(bundleBuffer.length),
                },
            },
        });
        firebase_functions_1.logger.info('✅ Bundle uploaded to Storage: bundles/latest.bundle');
        firebase_functions_1.logger.info(`   Documents: ${popularitySnapshot.size}`);
        firebase_functions_1.logger.info(`   Size: ${(bundleBuffer.length / 1024).toFixed(2)} KB`);
        firebase_functions_1.logger.info(`   Cache: 24h`);
    }
    catch (error) {
        firebase_functions_1.logger.error('❌ Bundle generation failed:', error);
        // Log detailed error for debugging
        if (error instanceof Error) {
            firebase_functions_1.logger.error('   Error message:', error.message);
            firebase_functions_1.logger.error('   Stack trace:', error.stack);
        }
        // Re-throw to mark function execution as failed in Cloud Console
        throw error;
    }
});
//# sourceMappingURL=generatePopularityBundle.js.map