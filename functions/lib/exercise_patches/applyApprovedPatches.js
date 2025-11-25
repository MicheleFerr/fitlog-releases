"use strict";
/**
 * GymBro Cloud Functions - Exercise Patches
 * Automatically apply approved patches to exercise database
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
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.applyApprovedPatches = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
/**
 * Cloud Function: Apply approved patches to exercises
 *
 * **Trigger**: Firestore onUpdate for exercise_patches collection
 * **Condition**: status changes from 'pending' to 'approved'
 *
 * **Workflow**:
 * 1. Detect status change to 'approved'
 * 2. Get exercise document from appropriate collection (exercises_en or exercises_it)
 * 3. Apply patch field update
 * 4. Verify update succeeded
 * 5. Log success/failure
 *
 * **Error Handling**:
 * - If exercise not found: Log warning, patch remains approved (orphaned)
 * - If update fails: Log error, patch status unchanged
 * - If field invalid: Log error, skip update
 */
exports.applyApprovedPatches = functions.firestore
    .document('exercise_patches/{patchId}')
    .onUpdate(async (change, context) => {
    var _a;
    const before = change.before.data();
    const after = change.after.data();
    const patchId = context.params.patchId;
    // Only process if status changed to 'approved'
    if (before.status === 'approved' || after.status !== 'approved') {
        console.log(`Patch ${patchId}: Status is ${after.status}, skipping auto-apply`);
        return null;
    }
    console.log(`Patch ${patchId}: Status changed to 'approved', applying patch`);
    const { exerciseId, fieldName, newValue, language, } = after;
    // Validate required fields
    if (!exerciseId || !fieldName || !language) {
        console.error(`Patch ${patchId}: Missing required fields`, {
            exerciseId,
            fieldName,
            language,
        });
        return null;
    }
    // Determine collection based on language
    const collectionName = language === 'it' ? 'exercises_it' : 'exercises_en';
    const exerciseRef = admin.firestore()
        .collection(collectionName)
        .doc(exerciseId);
    try {
        // Get exercise document
        const exerciseDoc = await exerciseRef.get();
        if (!exerciseDoc.exists) {
            console.warn(`Patch ${patchId}: Exercise ${exerciseId} not found in ${collectionName}`);
            return null;
        }
        // Apply patch: Update single field
        await exerciseRef.update({
            [fieldName]: newValue,
            lastModified: admin.firestore.FieldValue.serverTimestamp(),
            lastModifiedBy: 'patch_system',
        });
        console.log(`Patch ${patchId}: Successfully applied to ${exerciseId}.${fieldName}`, {
            collection: collectionName,
            oldValue: (_a = exerciseDoc.data()) === null || _a === void 0 ? void 0 : _a[fieldName],
            newValue,
        });
        return { success: true, patchId, exerciseId, fieldName };
    }
    catch (error) {
        console.error(`Patch ${patchId}: Failed to apply patch`, {
            error: error instanceof Error ? error.message : String(error),
            exerciseId,
            fieldName,
            collection: collectionName,
        });
        // Don't throw - let patch remain approved for manual investigation
        return { success: false, patchId, error };
    }
});
//# sourceMappingURL=applyApprovedPatches.js.map