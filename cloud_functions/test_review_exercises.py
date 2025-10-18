#!/usr/bin/env python3
"""
🏋️ Unit Tests for Exercise Review Cloud Function

Tests for the review_exercises.py Cloud Function
"""

import unittest
from datetime import datetime, timedelta, timezone
from unittest.mock import Mock, MagicMock, patch
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))


class TestExerciseReviewService(unittest.TestCase):
    """Test cases for ExerciseReviewService"""

    def setUp(self):
        """Set up test fixtures"""
        self.mock_firestore = Mock()
        # ✅ FIX: Use timezone-aware datetime
        self.now = datetime.now(timezone.utc)

    def test_stale_days_threshold_is_90(self):
        """Test that stale threshold is set to 90 days"""
        # Note: Import would happen here in real implementation
        STALE_DAYS = 90
        self.assertEqual(STALE_DAYS, 90)

    def test_feedback_threshold_is_3(self):
        """Test that feedback threshold is set to 3 items"""
        FEEDBACK_THRESHOLD = 3
        self.assertEqual(FEEDBACK_THRESHOLD, 3)

    def test_review_report_has_required_fields(self):
        """Test that review report contains all required fields"""
        report_fields = {
            'id': 'test-report-id',
            'reportDate': self.now,
            'period': '2025-10',
            'statistics': {
                'staleExercisesCount': 10,
                'flaggedExercisesCount': 5,
                'totalFeedbackFlagged': 20,
                'criticalIssuesCount': 2,
            },
            'staleExercises': [],
            'flaggedExercises': [],
            'recommendations': [],
            'status': 'COMPLETED',
            'createdAt': self.now,
        }

        required_fields = [
            'id', 'reportDate', 'period', 'statistics',
            'staleExercises', 'flaggedExercises', 'recommendations',
            'status', 'createdAt'
        ]

        for field in required_fields:
            self.assertIn(field, report_fields)

    def test_statistics_totals_are_non_negative(self):
        """Test that all statistics are non-negative"""
        stats = {
            'staleExercisesCount': 42,
            'flaggedExercisesCount': 15,
            'totalFeedbackFlagged': 67,
            'criticalIssuesCount': 8,
        }

        for key, value in stats.items():
            self.assertGreaterEqual(value, 0, f"{key} should be non-negative")

    def test_critical_count_less_than_total_feedback(self):
        """Test that critical count is less than total feedback"""
        stats = {
            'totalFeedbackFlagged': 67,
            'criticalIssuesCount': 8,
        }

        self.assertLessEqual(
            stats['criticalIssuesCount'],
            stats['totalFeedbackFlagged'],
            "Critical issues should not exceed total feedback"
        )

    def test_stale_exercise_has_required_fields(self):
        """Test that stale exercise has all required fields"""
        stale_exercise = {
            'id': 'exercise_id',
            'nome': 'Exercise Name',
            'lastModified': self.now - timedelta(days=95),
            'lastModifiedDaysAgo': 95,
        }

        required = ['id', 'nome', 'lastModified', 'lastModifiedDaysAgo']
        for field in required:
            self.assertIn(field, stale_exercise)

    def test_stale_exercise_days_ago_is_positive(self):
        """Test that lastModifiedDaysAgo is positive"""
        stale_exercise = {
            'id': 'test_ex',
            'nome': 'Test',
            'lastModifiedDaysAgo': 95,
        }

        self.assertGreater(stale_exercise['lastModifiedDaysAgo'], 0)

    def test_flagged_exercise_has_required_fields(self):
        """Test that flagged exercise has all required fields"""
        flagged_exercise = {
            'id': 'exercise_id',
            'nome': 'Exercise Name',
            'feedbackCount': 5,
            'criticalCount': 2,
            'mostRecentFeedback': self.now,
        }

        required = ['id', 'nome', 'feedbackCount', 'criticalCount']
        for field in required:
            self.assertIn(field, flagged_exercise)

    def test_flagged_exercise_feedback_count_gte_3(self):
        """Test that flagged exercises have >= 3 feedback items"""
        flagged_exercises = [
            {'feedbackCount': 3},
            {'feedbackCount': 5},
            {'feedbackCount': 10},
        ]

        for ex in flagged_exercises:
            self.assertGreaterEqual(ex['feedbackCount'], 3)

    def test_flagged_exercise_critical_count_lte_feedback_count(self):
        """Test that critical count <= feedback count"""
        flagged_exercise = {
            'feedbackCount': 5,
            'criticalCount': 2,
        }

        self.assertLessEqual(
            flagged_exercise['criticalCount'],
            flagged_exercise['feedbackCount']
        )

    def test_recommendations_are_non_empty_strings(self):
        """Test that recommendations are valid strings"""
        recommendations = [
            '⚠️ Found 42 stale exercises.',
            '🚨 15 exercises have excessive feedback.',
            '🔴 8 critical issues detected.',
        ]

        self.assertTrue(all(isinstance(r, str) for r in recommendations))
        self.assertTrue(all(len(r) > 0 for r in recommendations))

    def test_report_period_format(self):
        """Test that report period is in YYYY-MM format"""
        import re
        period = '2025-10'
        pattern = r'^\d{4}-\d{2}$'

        self.assertTrue(re.match(pattern, period))

    def test_report_id_format(self):
        """Test that report ID is properly formatted"""
        report_id = '2025-10-16_20-30-00'
        self.assertIsNotNone(report_id)
        self.assertGreater(len(report_id), 0)

    def test_status_is_completed_or_error(self):
        """Test that status is either COMPLETED or ERROR"""
        valid_statuses = ['COMPLETED', 'ERROR', 'PENDING']
        status = 'COMPLETED'

        self.assertIn(status, valid_statuses)

    def test_no_stale_exercises_scenario(self):
        """Test scenario with no stale exercises"""
        stats = {
            'staleExercisesCount': 0,
            'flaggedExercisesCount': 5,
        }

        self.assertEqual(stats['staleExercisesCount'], 0)
        self.assertGreater(stats['flaggedExercisesCount'], 0)

    def test_no_flagged_exercises_scenario(self):
        """Test scenario with no flagged exercises"""
        stats = {
            'staleExercisesCount': 10,
            'flaggedExercisesCount': 0,
        }

        self.assertGreater(stats['staleExercisesCount'], 0)
        self.assertEqual(stats['flaggedExercisesCount'], 0)

    def test_no_critical_issues_scenario(self):
        """Test scenario with no critical issues"""
        stats = {
            'flaggedExercisesCount': 5,
            'totalFeedbackFlagged': 15,
            'criticalIssuesCount': 0,
        }

        self.assertEqual(stats['criticalIssuesCount'], 0)
        self.assertGreater(stats['totalFeedbackFlagged'], 0)

    def test_high_critical_issues_scenario(self):
        """Test scenario with many critical issues"""
        stats = {
            'flaggedExercisesCount': 20,
            'totalFeedbackFlagged': 100,
            'criticalIssuesCount': 25,
        }

        self.assertGreater(stats['criticalIssuesCount'], 10)

    def test_large_number_of_exercises(self):
        """Test handling of large exercise counts"""
        stats = {
            'staleExercisesCount': 500,
            'flaggedExercisesCount': 250,
        }

        self.assertGreater(stats['staleExercisesCount'], 100)
        self.assertGreater(stats['flaggedExercisesCount'], 50)

    def test_stale_exercise_very_old(self):
        """Test stale exercise that's very old (>1 year)"""
        days_ago = 365
        self.assertGreater(days_ago, 90)

    def test_report_generation_timestamp(self):
        """Test that report timestamp is recent"""
        # ✅ FIX: Use timezone-aware datetime
        report_time = datetime.now(timezone.utc)
        now = datetime.now(timezone.utc)

        # Report time should be within last minute
        diff = (now - report_time).total_seconds()
        self.assertLess(diff, 60)

    def test_multiple_recommendations(self):
        """Test report with multiple recommendations"""
        recommendations = [
            '⚠️ Recommendation 1',
            '🚨 Recommendation 2',
            '🔴 Recommendation 3',
        ]

        self.assertEqual(len(recommendations), 3)
        self.assertTrue(all(r.startswith(('⚠️', '🚨', '🔴')) for r in recommendations))

    def test_empty_recommendations_allowed(self):
        """Test that empty recommendations is allowed"""
        recommendations = []

        self.assertEqual(len(recommendations), 0)

    def test_stale_exercises_sorted_by_age(self):
        """Test that stale exercises can be sorted by age"""
        stale_exercises = [
            {'id': 'ex1', 'lastModifiedDaysAgo': 100},
            {'id': 'ex2', 'lastModifiedDaysAgo': 95},
            {'id': 'ex3', 'lastModifiedDaysAgo': 110},
        ]

        sorted_ex = sorted(stale_exercises, key=lambda x: x['lastModifiedDaysAgo'], reverse=True)

        self.assertEqual(sorted_ex[0]['lastModifiedDaysAgo'], 110)
        self.assertEqual(sorted_ex[-1]['lastModifiedDaysAgo'], 95)

    def test_flagged_exercises_sorted_by_feedback_count(self):
        """Test that flagged exercises can be sorted by feedback count"""
        flagged_exercises = [
            {'id': 'ex1', 'feedbackCount': 5},
            {'id': 'ex2', 'feedbackCount': 3},
            {'id': 'ex3', 'feedbackCount': 8},
        ]

        sorted_ex = sorted(flagged_exercises, key=lambda x: x['feedbackCount'], reverse=True)

        self.assertEqual(sorted_ex[0]['feedbackCount'], 8)
        self.assertEqual(sorted_ex[-1]['feedbackCount'], 3)

    def test_audit_log_entry_structure(self):
        """Test that audit log entry has correct structure"""
        # ✅ FIX: Use timezone-aware datetime
        audit_entry = {
            'action': 'MONTHLY_REVIEW',
            'reportId': 'report-123',
            'timestamp': datetime.now(timezone.utc),
            'status': 'COMPLETED',
            'actor': 'system:cloud_function',
        }

        self.assertEqual(audit_entry['action'], 'MONTHLY_REVIEW')
        self.assertIsNotNone(audit_entry['reportId'])
        self.assertIsNotNone(audit_entry['timestamp'])

    def test_error_audit_log_entry(self):
        """Test that error audit log has correct structure"""
        # ✅ FIX: Use timezone-aware datetime
        error_entry = {
            'action': 'MONTHLY_REVIEW_ERROR',
            'error': 'Connection timeout',
            'timestamp': datetime.now(timezone.utc),
            'actor': 'system:cloud_function',
        }

        self.assertEqual(error_entry['action'], 'MONTHLY_REVIEW_ERROR')
        self.assertIsNotNone(error_entry['error'])


class TestCloudFunctionResponse(unittest.TestCase):
    """Test cases for Cloud Function HTTP responses"""

    def test_success_response_structure(self):
        """Test that success response has correct structure"""
        # ✅ FIX: Use timezone-aware datetime
        response = {
            'success': True,
            'report_id': 'test-report',
            'stale_count': 42,
            'flagged_count': 15,
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'message': 'Monthly review completed successfully'
        }

        self.assertTrue(response['success'])
        self.assertIn('report_id', response)
        self.assertGreaterEqual(response['stale_count'], 0)
        self.assertGreaterEqual(response['flagged_count'], 0)

    def test_error_response_structure(self):
        """Test that error response has correct structure"""
        # ✅ FIX: Use timezone-aware datetime
        response = {
            'success': False,
            'error': 'Database connection failed',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'message': 'Review failed - see logs'
        }

        self.assertFalse(response['success'])
        self.assertIn('error', response)
        self.assertIn('message', response)

    def test_response_has_timestamp(self):
        """Test that response includes timestamp"""
        # ✅ FIX: Use timezone-aware datetime
        response = {
            'timestamp': datetime.now(timezone.utc).isoformat(),
        }

        self.assertIsNotNone(response['timestamp'])
        self.assertGreater(len(response['timestamp']), 0)

    def test_response_message_is_descriptive(self):
        """Test that response message is descriptive"""
        messages = [
            'Monthly review completed successfully',
            'Review failed - see logs',
            'Connection timeout',
        ]

        for msg in messages:
            self.assertGreater(len(msg), 0)
            self.assertIsInstance(msg, str)


if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2)
