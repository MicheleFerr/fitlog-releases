import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/validation/template_validator.dart';

void main() {
  group('TemplateValidator - Template Name', () {
    test('should accept valid template name', () {
      final result = TemplateValidator.validateTemplateName('Leg Day Workout');
      expect(result, isNull);
    });

    test('should reject empty template name', () {
      final result = TemplateValidator.validateTemplateName('');
      expect(result, isNotNull);
      expect(result, contains('cannot be empty'));
    });

    test('should reject null template name', () {
      final result = TemplateValidator.validateTemplateName(null);
      expect(result, isNotNull);
      expect(result, contains('cannot be empty'));
    });

    test('should reject whitespace-only template name', () {
      final result = TemplateValidator.validateTemplateName('   ');
      expect(result, isNotNull);
      expect(result, contains('cannot be only whitespace'));
    });

    test('should reject template name exceeding max length', () {
      final longName = 'a' * (TemplateValidator.maxNameLength + 1);
      final result = TemplateValidator.validateTemplateName(longName);

      expect(result, isNotNull);
      expect(result, contains('cannot exceed'));
    });

    test('should accept template name at max length', () {
      final maxName = 'a' * TemplateValidator.maxNameLength;
      final result = TemplateValidator.validateTemplateName(maxName);

      expect(result, isNull);
    });

    test('should detect XSS script tags', () {
      final result = TemplateValidator.validateTemplateName(
        '<script>alert("xss")</script>My Template',
      );

      expect(result, isNotNull);
      expect(result, contains('invalid characters'));
    });

    test('should detect inline event handlers', () {
      final result = TemplateValidator.validateTemplateName(
        'Template onclick=alert(1)',
      );

      expect(result, isNotNull);
      expect(result, contains('invalid characters'));
    });

    test('should detect javascript protocol', () {
      final result = TemplateValidator.validateTemplateName(
        'javascript:alert(1)',
      );

      expect(result, isNotNull);
      expect(result, contains('invalid characters'));
    });

    test('should detect SQL injection patterns', () {
      final result = TemplateValidator.validateTemplateName(
        "Template'; DROP TABLE users--",
      );

      expect(result, isNotNull);
      expect(result, contains('invalid characters'));
    });

    test('should accept special characters in reasonable names', () {
      final result = TemplateValidator.validateTemplateName(
        'Push/Pull/Legs - Week 1 (Heavy)',
      );

      expect(result, isNull);
    });

    test('should accept emoji in template name', () {
      final result = TemplateValidator.validateTemplateName(
        'Leg Day 💪🦵',
      );

      expect(result, isNull);
    });
  });

  group('TemplateValidator - Template Description', () {
    test('should accept valid description', () {
      final result = TemplateValidator.validateTemplateDescription(
        'A comprehensive workout routine for building strength',
      );

      expect(result, isNull);
    });

    test('should accept empty description', () {
      final result = TemplateValidator.validateTemplateDescription('');
      expect(result, isNull); // Description is optional
    });

    test('should accept null description', () {
      final result = TemplateValidator.validateTemplateDescription(null);
      expect(result, isNull); // Description is optional
    });

    test('should reject description exceeding max length', () {
      final longDesc = 'a' * (TemplateValidator.maxDescriptionLength + 1);
      final result = TemplateValidator.validateTemplateDescription(longDesc);

      expect(result, isNotNull);
      expect(result, contains('cannot exceed'));
    });

    test('should accept description at max length', () {
      final maxDesc = 'a' * TemplateValidator.maxDescriptionLength;
      final result = TemplateValidator.validateTemplateDescription(maxDesc);

      expect(result, isNull);
    });

    test('should detect XSS in description', () {
      final result = TemplateValidator.validateTemplateDescription(
        'Good workout <script>alert("xss")</script> for beginners',
      );

      expect(result, isNotNull);
      expect(result, contains('invalid characters'));
    });

    test('should accept markdown-like formatting', () {
      final result = TemplateValidator.validateTemplateDescription(
        '**Focus areas:**\n- Chest\n- Triceps\n- Shoulders',
      );

      expect(result, isNull);
    });
  });

  group('TemplateValidator - Sanitization', () {
    test('should remove HTML tags from template name', () {
      final sanitized = TemplateValidator.sanitizeTemplateName(
        '<b>Bold</b> Template <i>Name</i>',
      );

      expect(sanitized, 'Bold Template Name');
      expect(sanitized, isNot(contains('<')));
      expect(sanitized, isNot(contains('>')));
    });

    test('should remove script tags from template name', () {
      final sanitized = TemplateValidator.sanitizeTemplateName(
        'Template <script>alert(1)</script> Name',
      );

      // HTML tags are removed but content between them remains
      expect(sanitized, 'Template alert(1) Name');
      expect(sanitized, isNot(contains('script')));
      expect(sanitized, isNot(contains('<')));
      expect(sanitized, isNot(contains('>')));
    });

    test('should remove dangerous patterns from template name', () {
      final sanitized = TemplateValidator.sanitizeTemplateName(
        'Template onclick=bad() Name',
      );

      expect(sanitized, isNot(contains('onclick')));
    });

    test('should trim whitespace in template name', () {
      final sanitized = TemplateValidator.sanitizeTemplateName('  Template  ');
      expect(sanitized, 'Template');
    });

    test('should preserve safe characters', () {
      const original = 'Push/Pull/Legs - Week 1 (Heavy) 💪';
      final sanitized = TemplateValidator.sanitizeTemplateName(original);

      expect(sanitized, original);
    });

    test('should sanitize multiple dangerous patterns', () {
      final sanitized = TemplateValidator.sanitizeTemplateName(
        '<script>bad</script> onclick=evil() javascript:alert(1)',
      );

      expect(sanitized, isNot(contains('script')));
      expect(sanitized, isNot(contains('onclick')));
      expect(sanitized, isNot(contains('javascript')));
    });

    test('should remove SQL injection attempts', () {
      final sanitized = TemplateValidator.sanitizeTemplateName(
        "Template'; DROP TABLE users; --",
      );

      expect(sanitized, isNot(contains("'")));
      expect(sanitized, isNot(contains('--')));
      expect(sanitized, isNot(contains(';')));
    });
  });


  group('TemplateValidator - Edge Cases', () {
    test('should handle unicode characters correctly', () {
      final result = TemplateValidator.validateTemplateName(
        'Тренировка ног 🏋️',
      );

      expect(result, isNull);
    });

    test('should handle multiple spaces', () {
      final sanitized = TemplateValidator.sanitizeTemplateName(
        'Template    with    spaces',
      );

      // Whitespace is normalized to single spaces
      expect(sanitized, 'Template with spaces');
    });

    test('should handle newlines in description', () {
      final result = TemplateValidator.validateTemplateDescription(
        'Line 1\nLine 2\nLine 3',
      );

      expect(result, isNull);
    });

    test('should handle mixed case dangerous patterns', () {
      final result = TemplateValidator.validateTemplateName(
        '<ScRiPt>alert(1)</sCrIpT>',
      );

      expect(result, isNotNull);
      expect(result, contains('invalid characters'));
    });

    test('should handle URL-encoded characters', () {
      final result = TemplateValidator.validateTemplateName(
        'Template%20Name',
      );

      expect(result, isNull); // URL encoding is safe
    });

    test('should handle very long single word', () {
      final longWord = 'a' * 200;
      final result = TemplateValidator.validateTemplateName(longWord);

      expect(result, isNotNull);
      expect(result, contains('cannot exceed'));
    });
  });

  group('TemplateValidator - Integration', () {
    test('should validate and sanitize in sequence', () {
      const input = '  <b>Template</b>  ';

      // First validate (should FAIL - contains HTML)
      final validationResult = TemplateValidator.validateTemplateName(input);
      expect(validationResult, isNotNull);
      expect(validationResult, contains('HTML tags'));

      // Then sanitize (removes HTML)
      final sanitized = TemplateValidator.sanitizeTemplateName(input);
      expect(sanitized, 'Template');

      // Validate sanitized version (should PASS)
      final finalValidation = TemplateValidator.validateTemplateName(sanitized);
      expect(finalValidation, isNull);
    });

    test('should handle real-world template names', () {
      final testCases = [
        'Full Body 3x/week',
        // Note: Straight quotes (') are blocked for SQL injection prevention
        // Use typographic apostrophe (') or remove possessive form
        'Arnolds Golden 6',
        'Stronglifts 5x5',
        '5/3/1 BBB',
        'nSuns 5-day LP',
        'GZCLP (3-day)',
      ];

      for (final name in testCases) {
        final result = TemplateValidator.validateTemplateName(name);
        expect(result, isNull, reason: 'Should accept: $name');
      }
    });

    test('should reject all common XSS vectors', () {
      final xssVectors = [
        '<script>alert(1)</script>',
        '<img src=x onerror=alert(1)>',
        '<svg onload=alert(1)>',
        'javascript:alert(1)',
        '<iframe src=evil.com>',
        '<body onload=alert(1)>',
      ];

      for (final vector in xssVectors) {
        final result = TemplateValidator.validateTemplateName(vector);
        expect(result, isNotNull, reason: 'Should reject: $vector');
      }
    });

    test('should reject all common SQL injection vectors', () {
      final sqlVectors = [
        "' OR '1'='1",
        "'; DROP TABLE users; --",
        "1' UNION SELECT * FROM users--",
        "admin'--",
        "' OR 1=1--",
      ];

      for (final vector in sqlVectors) {
        final result = TemplateValidator.validateTemplateName(vector);
        expect(result, isNotNull, reason: 'Should reject: $vector');
      }
    });
  });
}
