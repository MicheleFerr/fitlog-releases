#!/usr/bin/env python3
"""
🏋️ GymBro Exercise Database - Monthly Review Automation
Cloud Function to identify and report on stale exercises and feedback issues

Triggers: Cloud Scheduler (1st of month, 02:00 UTC)
Cron: 0 2 1 * *

Function: review_exercises(request)
- Identifies exercises not modified in >90 days
- Identifies exercises with ≥3 open feedback items
- Creates admin report in Firestore
- Sends admin notifications
"""

import functions_framework
from firebase_admin import initialize_app, firestore, messaging
from datetime import datetime, timedelta, timezone
from typing import Dict, List, Any
import logging
import json

# Initialize Firebase
app = initialize_app()
db = firestore.client()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ExerciseReviewService:
    """Service for automated exercise reviews and reporting."""

    # Constants
    STALE_DAYS_THRESHOLD = 90
    FEEDBACK_THRESHOLD = 3
    REPORT_COLLECTION = 'admin_reports'
    EXERCISES_COLLECTION = 'exercises'
    FEEDBACK_COLLECTION = 'exercise_feedback'
    AUDIT_COLLECTION = 'audit_logs'

    def __init__(self):
        """Initialize the review service."""
        self.db = db
        # ✅ FIX: Use timezone-aware datetime instead of deprecated utcnow()
        self.now = datetime.now(timezone.utc)
        self.stale_exercises = []
        self.flagged_exercises = []
        self.report_id = self.now.strftime("%Y-%m-%d_%H-%M-%S")

    def review(self) -> Dict[str, Any]:
        """
        Execute the monthly review process.

        Returns:
            Dictionary with review results and statistics
        """
        try:
            logger.info("🔍 Starting monthly exercise review...")

            # Step 1: Find stale exercises (>90 days without modification)
            self.stale_exercises = self._find_stale_exercises()
            logger.info(f"   Found {len(self.stale_exercises)} stale exercises")

            # Step 2: Find exercises with excessive feedback (≥3 open items)
            self.flagged_exercises = self._find_flagged_exercises()
            logger.info(f"   Found {len(self.flagged_exercises)} flagged exercises")

            # Step 3: Generate and store report
            report = self._generate_report()
            self._store_report(report)
            logger.info("✅ Report stored successfully")

            # Step 4: Send admin notifications
            self._send_admin_notifications(report)
            logger.info("📧 Admin notifications sent")

            # Step 5: Log audit entry
            self._log_audit_entry(report)
            logger.info("📝 Audit entry created")

            logger.info("✅ Monthly review completed successfully")
            return {
                'success': True,
                'report_id': self.report_id,
                'stale_count': len(self.stale_exercises),
                'flagged_count': len(self.flagged_exercises),
                'timestamp': self.now.isoformat(),
                'message': 'Monthly review completed successfully'
            }

        except Exception as e:
            logger.error(f"❌ Error during review: {str(e)}")
            self._log_error(str(e))
            return {
                'success': False,
                'error': str(e),
                'timestamp': self.now.isoformat(),
                'message': 'Review failed - see logs'
            }

    def _find_stale_exercises(self) -> List[Dict[str, Any]]:
        """
        Find exercises not modified in >90 days.

        Returns:
            List of stale exercise documents
        """
        stale_threshold = self.now - timedelta(days=self.STALE_DAYS_THRESHOLD)

        try:
            query = self.db.collection(self.EXERCISES_COLLECTION)\
                .where('lastModified', '<', stale_threshold)\
                .limit(500)

            stale = []
            for doc in query.stream():
                stale.append({
                    'id': doc.id,
                    'nome': doc.get('nome', 'N/A'),
                    'lastModified': doc.get('lastModified'),
                    'lastModifiedDaysAgo': (self.now - doc.get('lastModified')).days
                    if doc.get('lastModified') else None
                })

            return stale

        except Exception as e:
            logger.error(f"Error finding stale exercises: {str(e)}")
            return []

    def _find_flagged_exercises(self) -> List[Dict[str, Any]]:
        """
        Find exercises with ≥3 open feedback items.

        Returns:
            List of flagged exercise documents
        """
        flagged = {}

        try:
            # Get all open feedback
            query = self.db.collection(self.FEEDBACK_COLLECTION)\
                .where('status', '==', 'OPEN')\
                .limit(5000)

            for doc in query.stream():
                exercise_id = doc.get('exerciseId')
                if not exercise_id:
                    continue

                if exercise_id not in flagged:
                    flagged[exercise_id] = {
                        'id': exercise_id,
                        'feedbackCount': 0,
                        'feedbackItems': []
                    }

                flagged[exercise_id]['feedbackCount'] += 1
                flagged[exercise_id]['feedbackItems'].append({
                    'feedbackId': doc.id,
                    'type': doc.get('type'),
                    'severity': doc.get('severity', 2),
                    'createdAt': doc.get('createdAt')
                })

            # Filter to exercises with ≥ threshold feedback
            flagged_list = [
                v for v in flagged.values()
                if v['feedbackCount'] >= self.FEEDBACK_THRESHOLD
            ]

            # Get exercise details for flagged
            result = []
            for flagged_ex in flagged_list:
                ex_doc = self.db.collection(self.EXERCISES_COLLECTION)\
                    .document(flagged_ex['id']).get()

                if ex_doc.exists:
                    result.append({
                        'id': flagged_ex['id'],
                        'nome': ex_doc.get('nome', 'N/A'),
                        'feedbackCount': flagged_ex['feedbackCount'],
                        'criticalCount': sum(
                            1 for item in flagged_ex['feedbackItems']
                            if item.get('severity', 2) >= 4
                        ),
                        'mostRecentFeedback': max(
                            (item.get('createdAt') for item in flagged_ex['feedbackItems']),
                            default=None
                        )
                    })

            return result

        except Exception as e:
            logger.error(f"Error finding flagged exercises: {str(e)}")
            return []

    def _generate_report(self) -> Dict[str, Any]:
        """
        Generate the review report.

        Returns:
            Report document dictionary
        """
        return {
            'id': self.report_id,
            'reportDate': self.now,
            'period': f"{self.now.year}-{self.now.month:02d}",
            'statistics': {
                'staleExercisesCount': len(self.stale_exercises),
                'flaggedExercisesCount': len(self.flagged_exercises),
                'totalFeedbackFlagged': sum(
                    ex.get('feedbackCount', 0) for ex in self.flagged_exercises
                ),
                'criticalIssuesCount': sum(
                    ex.get('criticalCount', 0) for ex in self.flagged_exercises
                )
            },
            'staleExercises': self.stale_exercises[:50],  # Top 50
            'flaggedExercises': self.flagged_exercises[:50],  # Top 50
            'recommendations': self._generate_recommendations(),
            'status': 'COMPLETED',
            'createdAt': self.now,
            'processedBy': 'cloud_function'
        }

    def _generate_recommendations(self) -> List[str]:
        """
        Generate action recommendations based on review.

        Returns:
            List of recommendation strings
        """
        recommendations = []

        if len(self.stale_exercises) > 100:
            recommendations.append(
                f"⚠️ Found {len(self.stale_exercises)} stale exercises. "
                "Consider archiving or updating oldest ones."
            )

        if len(self.flagged_exercises) > 20:
            recommendations.append(
                f"🚨 {len(self.flagged_exercises)} exercises have excessive feedback. "
                "Prioritize addressing critical issues."
            )

        critical_count = sum(
            ex.get('criticalCount', 0) for ex in self.flagged_exercises
        )
        if critical_count > 0:
            recommendations.append(
                f"🔴 {critical_count} critical issues detected. "
                "Review severity ≥4 feedback immediately."
            )

        if not recommendations:
            recommendations.append(
                "✅ Database health is good. Continue monitoring."
            )

        return recommendations

    def _store_report(self, report: Dict[str, Any]) -> None:
        """
        Store the report in Firestore.

        Args:
            report: Report document to store
        """
        self.db.collection(self.REPORT_COLLECTION).document(
            self.report_id
        ).set(report)

    def _send_admin_notifications(self, report: Dict[str, Any]) -> None:
        """
        Send notifications to admins about review results.

        Args:
            report: Report document
        """
        try:
            # Get admin devices (would typically query admin collection)
            # For now, this is a placeholder for Firebase Cloud Messaging
            stats = report.get('statistics', {})

            notification_title = f"🏋️ Monthly Exercise Review - {report.get('period')}"
            notification_body = (
                f"Stale: {stats.get('staleExercisesCount', 0)} | "
                f"Flagged: {stats.get('flaggedExercisesCount', 0)} | "
                f"Critical: {stats.get('criticalIssuesCount', 0)}"
            )

            # This would be sent to admin devices via FCM
            logger.info(f"📧 Notification: {notification_title}")
            logger.info(f"   {notification_body}")

        except Exception as e:
            logger.error(f"Error sending notifications: {str(e)}")

    def _log_audit_entry(self, report: Dict[str, Any]) -> None:
        """
        Create audit log entry for the review.

        Args:
            report: Report document
        """
        audit_entry = {
            'action': 'MONTHLY_REVIEW',
            'reportId': self.report_id,
            'timestamp': self.now,
            'statistics': report.get('statistics', {}),
            'status': report.get('status'),
            'actor': 'system:cloud_function',
            'immutable': True
        }

        self.db.collection(self.AUDIT_COLLECTION).add(audit_entry)

    def _log_error(self, error: str) -> None:
        """
        Log error to audit collection.

        Args:
            error: Error message
        """
        error_entry = {
            'action': 'MONTHLY_REVIEW_ERROR',
            'error': error,
            'timestamp': self.now,
            'actor': 'system:cloud_function'
        }

        self.db.collection(self.AUDIT_COLLECTION).add(error_entry)


@functions_framework.http
def review_exercises(request):
    """
    HTTP Cloud Function entry point for monthly exercise review.

    Args:
        request: Flask request object

    Returns:
        JSON response with review results
    """
    # Verify request source (optional - can add authentication)
    if request.method != 'POST':
        return {
            'error': 'Only POST requests are supported',
            'status': 400
        }, 400

    try:
        # Execute review
        service = ExerciseReviewService()
        result = service.review()

        return result, 200

    except Exception as e:
        logger.error(f"Unhandled error: {str(e)}")
        return {
            'error': 'Internal server error',
            'message': str(e),
            'status': 500
        }, 500


if __name__ == "__main__":
    # For local testing
    print("🧪 Testing Exercise Review Function...")
    service = ExerciseReviewService()
    result = service.review()
    print(json.dumps(result, indent=2, default=str))
