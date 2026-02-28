"use strict";
/**
 * Increment Exercise Popularity - Firestore Trigger
 *
 * Trigger: onCreate on /workoutTemplates/{templateId}
 * Purpose: Increment popularity count for each exercise in template
 *
 * When user saves a template, this increments the global usage counter
 * for each exercise in that template. Popular exercises get boosted
 * in search results.
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
exports.onTemplateCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firebase_functions_1 = require("firebase-functions");
const admin = __importStar(require("firebase-admin"));
/**
 * Increment popularity count for each exercise when template is created
 *
 * Execution:
 * - Triggered automatically when workout_templates/{templateId} is created
 * - Batch writes popularity increments (atomic operation)
 * - Graceful error handling (template save should not fail)
 *
 * Cost: ~$0.011/month (10k templates × avg 5 exercises × $0.108/100k writes)
 */
exports.onTemplateCreated = (0, firestore_1.onDocumentCreated)('workoutTemplates/{templateId}', async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        firebase_functions_1.logger.warn('No data in snapshot');
        return;
    }
    const template = snapshot.data();
    const exercises = template.exercises || [];
    if (exercises.length === 0) {
        firebase_functions_1.logger.info('Template has no exercises, skipping popularity update');
        return;
    }
    const templateId = event.params.templateId;
    const db = admin.firestore();
    const batch = db.batch();
    firebase_functions_1.logger.info(`📊 Incrementing popularity for template ${templateId} (${exercises.length} exercises)`);
    // Increment popularity for each exercise in template
    exercises.forEach((exercise) => {
        const popularityRef = db
            .collection('exercise_popularity')
            .doc(exercise.exerciseId);
        // Use merge: true to create document if it doesn't exist
        batch.set(popularityRef, {
            count: admin.firestore.FieldValue.increment(1),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
    });
    try {
        await batch.commit();
        firebase_functions_1.logger.info(`✅ Popularity incremented for ${exercises.length} exercises`);
    }
    catch (error) {
        firebase_functions_1.logger.error('❌ Popularity increment failed:', error);
        // Log error details for debugging
        if (error instanceof Error) {
            firebase_functions_1.logger.error('   Error message:', error.message);
            firebase_functions_1.logger.error('   Template ID:', templateId);
            firebase_functions_1.logger.error('   Exercise count:', exercises.length);
        }
        // IMPORTANT: Don't throw error - template save should succeed
        // even if popularity increment fails (graceful degradation)
    }
});
//# sourceMappingURL=onTemplateCreated.js.map