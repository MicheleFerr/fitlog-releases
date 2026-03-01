/// SecureLogger, SecureLogLevel, and SecureLoggingMixin unit tests.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/services/secure_logger.dart';

void main() {
  group('SecureLogLevel', () {
    test('has 5 values', () {
      expect(SecureLogLevel.values.length, 5);
    });

    test('severity ordering', () {
      expect(SecureLogLevel.debug.severity, 0);
      expect(SecureLogLevel.info.severity, 1);
      expect(SecureLogLevel.warning.severity, 2);
      expect(SecureLogLevel.error.severity, 3);
      expect(SecureLogLevel.performance.severity, 4);
    });

    test('debug has lowest severity', () {
      for (final level in SecureLogLevel.values) {
        expect(
          SecureLogLevel.debug.severity <= level.severity,
          true,
          reason: 'debug should be <= ${level.name}',
        );
      }
    });
  });

  group('SecureLogger - containsSensitiveData', () {
    test('detects email addresses', () {
      expect(SecureLogger.containsSensitiveData('user@example.com'), true);
      expect(SecureLogger.containsSensitiveData('test.user@domain.org'), true);
    });

    test('detects JWT tokens', () {
      const jwt =
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc123';
      expect(SecureLogger.containsSensitiveData(jwt), true);
    });

    test('detects password patterns', () {
      expect(SecureLogger.containsSensitiveData('password: mySecret123'), true);
      expect(SecureLogger.containsSensitiveData('Password: abc'), true);
    });

    test('detects token patterns', () {
      expect(SecureLogger.containsSensitiveData('token: abc123def'), true);
    });

    test('detects api_key patterns', () {
      expect(SecureLogger.containsSensitiveData('api_key: xyz789'), true);
      expect(SecureLogger.containsSensitiveData('apikey: xyz789'), true);
    });

    test('detects authorization patterns', () {
      expect(
        SecureLogger.containsSensitiveData('authorization: Bearer xyz'),
        true,
      );
    });

    test('returns false for safe text', () {
      expect(SecureLogger.containsSensitiveData('Hello world'), false);
      expect(SecureLogger.containsSensitiveData('count: 5'), false);
    });
  });

  group('SecureLogger - redact', () {
    test('returns REDACTED', () {
      expect(SecureLogger.redact('anything'), '[REDACTED]');
      expect(SecureLogger.redact(''), '[REDACTED]');
    });
  });

  group('SecureLogger - partialRedact', () {
    test('long string shows start and end', () {
      final result = SecureLogger.partialRedact('abcdefghijklmnop', show: 3);
      expect(result, 'abc...nop');
    });

    test('default show is 4', () {
      final result = SecureLogger.partialRedact('1234567890abcdef');
      expect(result, '1234...cdef');
    });

    test('short string returns REDACTED', () {
      final result = SecureLogger.partialRedact('abcd', show: 3);
      expect(result, '[REDACTED]');
    });

    test('exact boundary returns REDACTED', () {
      // show=3, boundary is show*2=6, so length 6 returns REDACTED
      final result = SecureLogger.partialRedact('abcdef', show: 3);
      expect(result, '[REDACTED]');
    });

    test('one above boundary shows partial', () {
      // show=3, boundary is 6, so length 7 shows partial
      final result = SecureLogger.partialRedact('abcdefg', show: 3);
      expect(result, 'abc...efg');
    });
  });

  group('SecureLogger - setMinLogLevel', () {
    tearDown(() {
      // Reset to debug after each test
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
    });

    test('can set to error level', () {
      // Should not throw
      SecureLogger.setMinLogLevel(SecureLogLevel.error);
    });

    test('can set to debug level', () {
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
    });
  });

  group('SecureLogger - logging methods', () {
    late List<String> capturedLogs;

    setUp(() {
      capturedLogs = [];
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) capturedLogs.add(message);
      };
    });

    tearDown(() {
      debugPrint = debugPrintThrottled;
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
    });

    test('debug logs message', () {
      SecureLogger.debug('test message');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('DEBUG'));
      expect(capturedLogs[0], contains('test message'));
    });

    test('info logs message', () {
      SecureLogger.info('info message');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('INFO'));
      expect(capturedLogs[0], contains('info message'));
    });

    test('warning logs message', () {
      SecureLogger.warning('warn message');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('WARNING'));
      expect(capturedLogs[0], contains('warn message'));
    });

    test('error logs message', () {
      SecureLogger.error('error message');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('ERROR'));
      expect(capturedLogs[0], contains('error message'));
    });

    test('success logs message', () {
      SecureLogger.success('done');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('SUCCESS'));
      expect(capturedLogs[0], contains('done'));
    });

    test('performance logs message', () {
      SecureLogger.performance('slow query', durationMs: 500);
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('PERF'));
      expect(capturedLogs[0], contains('slow query'));
      expect(capturedLogs[0], contains('500'));
    });

    test('performance logs metrics', () {
      SecureLogger.performance('op', metrics: {'count': 10});
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('count'));
    });

    test('verbose logs message', () {
      SecureLogger.verbose('detail');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('VERBOSE'));
      expect(capturedLogs[0], contains('detail'));
    });

    test('log method outputs message', () {
      SecureLogger.log('simple log');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('simple log'));
    });

    test('log with metadata', () {
      SecureLogger.log('msg', metadata: {'key': 'value'});
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('key'));
      expect(capturedLogs[0], contains('value'));
    });

    test('log without sanitize', () {
      SecureLogger.log('password: secret', sanitize: false);
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('password: secret'));
    });

    test('debug with error object', () {
      SecureLogger.debug('failed', error: Exception('oops'));
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('Error'));
    });

    test('debug with stackTrace', () {
      SecureLogger.debug(
        'failed',
        error: Exception('oops'),
        stackTrace: StackTrace.current,
      );
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('StackTrace'));
    });

    test('debug with metadata', () {
      SecureLogger.debug('msg', metadata: {'count': 5});
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('Metadata'));
      expect(capturedLogs[0], contains('count'));
    });

    test('debug with deprecated data param', () {
      // ignore: deprecated_member_use
      SecureLogger.debug('msg', data: {'key': 'val'});
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('key'));
    });

    test('info with deprecated data param', () {
      // ignore: deprecated_member_use
      SecureLogger.info('msg', data: {'k': 'v'});
      expect(capturedLogs.length, 1);
    });

    test('warning with deprecated data param', () {
      // ignore: deprecated_member_use
      SecureLogger.warning('msg', data: {'k': 'v'});
      expect(capturedLogs.length, 1);
    });

    test('error with deprecated data param', () {
      // ignore: deprecated_member_use
      SecureLogger.error('msg', data: {'k': 'v'});
      expect(capturedLogs.length, 1);
    });

    test('success with deprecated data param', () {
      // ignore: deprecated_member_use
      SecureLogger.success('msg', data: {'k': 'v'});
      expect(capturedLogs.length, 1);
    });

    test('verbose with deprecated data param', () {
      // ignore: deprecated_member_use
      SecureLogger.verbose('msg', data: {'k': 'v'});
      expect(capturedLogs.length, 1);
    });
  });

  group('SecureLogger - sanitization in logs', () {
    late List<String> capturedLogs;

    setUp(() {
      capturedLogs = [];
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) capturedLogs.add(message);
      };
    });

    tearDown(() {
      debugPrint = debugPrintThrottled;
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
    });

    test('sanitizes email in message', () {
      SecureLogger.debug('User user@example.com logged in');
      expect(capturedLogs[0], isNot(contains('user@example.com')));
      expect(capturedLogs[0], contains('REDACTED'));
    });

    test('sanitizes password in message', () {
      SecureLogger.debug('password: mySecret123');
      expect(capturedLogs[0], isNot(contains('mySecret123')));
      expect(capturedLogs[0], contains('REDACTED'));
    });

    test('sanitizes sensitive field names in metadata', () {
      SecureLogger.debug('login', metadata: {'email': 'user@test.com'});
      expect(capturedLogs[0], isNot(contains('user@test.com')));
      expect(capturedLogs[0], contains('REDACTED'));
    });

    test('sanitizes email in error object', () {
      SecureLogger.error(
        'Auth failed',
        error: Exception('Failed for user@example.com'),
      );
      expect(capturedLogs[0], isNot(contains('user@example.com')));
    });

    test('preserves non-sensitive metadata', () {
      SecureLogger.debug('op', metadata: {'count': 5, 'status': 'ok'});
      expect(capturedLogs[0], contains('count'));
      expect(capturedLogs[0], contains('status'));
    });

    test('sanitizes nested map in metadata', () {
      SecureLogger.debug('op', metadata: {
        'user': {'email': 'test@test.com', 'name': 'Test'},
      });
      expect(capturedLogs[0], isNot(contains('test@test.com')));
    });

    test('sanitizes list values in metadata', () {
      SecureLogger.debug('op', metadata: {
        'items': ['safe', 'user@test.com'],
      });
      expect(capturedLogs[0], isNot(contains('user@test.com')));
    });

    test('log method sanitizes by default', () {
      SecureLogger.log('password: secret123');
      expect(capturedLogs[0], isNot(contains('secret123')));
      expect(capturedLogs[0], contains('REDACTED'));
    });

    test('log method sanitizes metadata', () {
      SecureLogger.log('msg', metadata: {'token': 'abc123'});
      expect(capturedLogs[0], isNot(contains('abc123')));
    });
  });

  group('SecureLogger - log level filtering', () {
    late List<String> capturedLogs;

    setUp(() {
      capturedLogs = [];
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) capturedLogs.add(message);
      };
    });

    tearDown(() {
      debugPrint = debugPrintThrottled;
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
    });

    test('error level filters debug and info', () {
      SecureLogger.setMinLogLevel(SecureLogLevel.error);
      SecureLogger.debug('debug msg');
      SecureLogger.info('info msg');
      SecureLogger.warning('warn msg');
      SecureLogger.error('error msg');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('ERROR'));
    });

    test('warning level filters debug and info', () {
      SecureLogger.setMinLogLevel(SecureLogLevel.warning);
      SecureLogger.debug('debug msg');
      SecureLogger.info('info msg');
      SecureLogger.warning('warn msg');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('WARNING'));
    });

    test('info level filters debug', () {
      SecureLogger.setMinLogLevel(SecureLogLevel.info);
      SecureLogger.debug('debug msg');
      SecureLogger.info('info msg');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('INFO'));
    });

    test('debug level allows all', () {
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
      SecureLogger.debug('d');
      SecureLogger.info('i');
      SecureLogger.warning('w');
      SecureLogger.error('e');
      expect(capturedLogs.length, 4);
    });

    test('success uses info level threshold', () {
      SecureLogger.setMinLogLevel(SecureLogLevel.warning);
      SecureLogger.success('done');
      expect(capturedLogs, isEmpty);
    });

    test('verbose uses debug level threshold', () {
      SecureLogger.setMinLogLevel(SecureLogLevel.info);
      SecureLogger.verbose('detail');
      expect(capturedLogs, isEmpty);
    });

    test('performance uses performance level threshold', () {
      SecureLogger.setMinLogLevel(SecureLogLevel.performance);
      SecureLogger.debug('d');
      SecureLogger.info('i');
      SecureLogger.warning('w');
      SecureLogger.error('e');
      SecureLogger.performance('p');
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0], contains('PERF'));
    });
  });

  group('SecureLoggingMixin', () {
    test('mixin methods delegate to SecureLogger', () {
      final logs = <String>[];
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) logs.add(message);
      };
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);

      final service = _TestService();
      service.logDebug('debug');
      service.logInfo('info');
      service.logWarning('warning');
      service.logError('error');
      service.logSuccess('success');
      service.logVerbose('verbose');

      expect(logs.length, 6);
      expect(logs[0], contains('DEBUG'));
      expect(logs[1], contains('INFO'));
      expect(logs[2], contains('WARNING'));
      expect(logs[3], contains('ERROR'));
      expect(logs[4], contains('SUCCESS'));
      expect(logs[5], contains('VERBOSE'));

      debugPrint = debugPrintThrottled;
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
    });

    test('logError with error and stackTrace', () {
      final logs = <String>[];
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) logs.add(message);
      };
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);

      final service = _TestService();
      service.logError('failed', Exception('test'), StackTrace.current);

      expect(logs.length, 1);
      expect(logs[0], contains('ERROR'));
      expect(logs[0], contains('StackTrace'));

      debugPrint = debugPrintThrottled;
      SecureLogger.setMinLogLevel(SecureLogLevel.debug);
    });
  });
}

class _TestService with SecureLoggingMixin {}
