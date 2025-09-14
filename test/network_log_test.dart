import 'package:flutter_test/flutter_test.dart';
import 'package:network_ninja/network_ninja.dart';

void main() {
  group('NetworkLog', () {
    late NetworkLog baseLog;

    setUp(() {
      baseLog = NetworkLog(
        id: 'test-123',
        timestamp: DateTime(2024, 1, 1, 12),
        method: 'GET',
        endpoint: 'https://api.example.com/test',
        requestBody: '{"test": "data"}',
        requestHeaders: {'Content-Type': 'application/json'},
        responseStatus: 200,
        responseBody: '{"success": true}',
        responseHeaders: {'Content-Type': 'application/json'},
        duration: const Duration(milliseconds: 150),
      );
    });

    group('Constructor and Properties', () {
      test('should create NetworkLog with all required properties', () {
        final log = NetworkLog(
          id: 'test-id',
          timestamp: DateTime(2024),
          method: 'POST',
          endpoint: 'https://api.example.com',
        );

        expect(log.id, equals('test-id'));
        expect(log.timestamp, equals(DateTime(2024)));
        expect(log.method, equals('POST'));
        expect(log.endpoint, equals('https://api.example.com'));
        expect(log.requestBody, isNull);
        expect(log.requestHeaders, isNull);
        expect(log.responseStatus, isNull);
        expect(log.responseBody, isNull);
        expect(log.responseHeaders, isNull);
        expect(log.duration, isNull);
        expect(log.error, isNull);
      });

      test('should create NetworkLog with all optional properties', () {
        final log = NetworkLog(
          id: 'test-id',
          timestamp: DateTime(2024),
          method: 'POST',
          endpoint: 'https://api.example.com',
          requestBody: '{"data": "test"}',
          requestHeaders: {'Authorization': 'Bearer token'},
          responseStatus: 201,
          responseBody: '{"id": 123}',
          responseHeaders: {'Content-Type': 'application/json'},
          duration: const Duration(seconds: 2),
          error: 'Connection timeout',
        );

        expect(log.requestBody, equals('{"data": "test"}'));
        expect(log.requestHeaders, equals({'Authorization': 'Bearer token'}));
        expect(log.responseStatus, equals(201));
        expect(log.responseBody, equals('{"id": 123}'));
        expect(
          log.responseHeaders,
          equals({'Content-Type': 'application/json'}),
        );
        expect(log.duration, equals(const Duration(seconds: 2)));
        expect(log.error, equals('Connection timeout'));
      });
    });

    group('isSuccess Property', () {
      test('should return true for 2xx status codes', () {
        expect(baseLog.copyWith(responseStatus: 200).isSuccess, isTrue);
        expect(baseLog.copyWith(responseStatus: 201).isSuccess, isTrue);
        expect(baseLog.copyWith(responseStatus: 204).isSuccess, isTrue);
        expect(baseLog.copyWith(responseStatus: 299).isSuccess, isTrue);
      });

      test('should return false for 4xx status codes', () {
        expect(baseLog.copyWith(responseStatus: 400).isSuccess, isFalse);
        expect(baseLog.copyWith(responseStatus: 401).isSuccess, isFalse);
        expect(baseLog.copyWith(responseStatus: 404).isSuccess, isFalse);
        expect(baseLog.copyWith(responseStatus: 499).isSuccess, isFalse);
      });

      test('should return false for 5xx status codes', () {
        expect(baseLog.copyWith(responseStatus: 500).isSuccess, isFalse);
        expect(baseLog.copyWith(responseStatus: 502).isSuccess, isFalse);
        expect(baseLog.copyWith(responseStatus: 503).isSuccess, isFalse);
        expect(baseLog.copyWith(responseStatus: 599).isSuccess, isFalse);
      });

      test('should return false for null status', () {
        // Create a new log with null responseStatus
        final logWithNullStatus = NetworkLog(
          id: 'test-null-status',
          timestamp: DateTime(2024, 1, 1, 12),
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );
        expect(logWithNullStatus.isSuccess, isFalse);
      });

      test('should return false for 3xx status codes', () {
        expect(baseLog.copyWith(responseStatus: 300).isSuccess, isFalse);
        expect(baseLog.copyWith(responseStatus: 301).isSuccess, isFalse);
        expect(baseLog.copyWith(responseStatus: 399).isSuccess, isFalse);
      });
    });

    group('hasError Property', () {
      test('should return false for 2xx status codes without error', () {
        expect(baseLog.copyWith(responseStatus: 200).hasError, isFalse);
        expect(baseLog.copyWith(responseStatus: 201).hasError, isFalse);
        expect(baseLog.copyWith(responseStatus: 299).hasError, isFalse);
      });

      test('should return true for 4xx status codes', () {
        expect(baseLog.copyWith(responseStatus: 400).hasError, isTrue);
        expect(baseLog.copyWith(responseStatus: 401).hasError, isTrue);
        expect(baseLog.copyWith(responseStatus: 404).hasError, isTrue);
        expect(baseLog.copyWith(responseStatus: 499).hasError, isTrue);
      });

      test('should return true for 5xx status codes', () {
        expect(baseLog.copyWith(responseStatus: 500).hasError, isTrue);
        expect(baseLog.copyWith(responseStatus: 502).hasError, isTrue);
        expect(baseLog.copyWith(responseStatus: 503).hasError, isTrue);
        expect(baseLog.copyWith(responseStatus: 599).hasError, isTrue);
      });

      test('should return true when error message is present', () {
        expect(
          baseLog
              .copyWith(responseStatus: 200, error: 'Network error')
              .hasError,
          isTrue,
        );
        expect(
          baseLog.copyWith(error: 'Timeout').hasError,
          isTrue,
        );
      });

      test('should return false for null status without error', () {
        expect(baseLog.copyWith().hasError, isFalse);
      });
    });

    group('statusText Property', () {
      test('should return status code as string for common status codes', () {
        expect(baseLog.copyWith(responseStatus: 200).statusText, equals('200'));
        expect(baseLog.copyWith(responseStatus: 201).statusText, equals('201'));
        expect(baseLog.copyWith(responseStatus: 204).statusText, equals('204'));
        expect(baseLog.copyWith(responseStatus: 400).statusText, equals('400'));
        expect(baseLog.copyWith(responseStatus: 401).statusText, equals('401'));
        expect(baseLog.copyWith(responseStatus: 403).statusText, equals('403'));
        expect(baseLog.copyWith(responseStatus: 404).statusText, equals('404'));
        expect(baseLog.copyWith(responseStatus: 500).statusText, equals('500'));
        expect(baseLog.copyWith(responseStatus: 502).statusText, equals('502'));
        expect(baseLog.copyWith(responseStatus: 503).statusText, equals('503'));
      });

      test('should return "Error" when error is present', () {
        expect(
          baseLog
              .copyWith(responseStatus: 400, error: 'Bad Request')
              .statusText,
          equals('Error'),
        );
        expect(
          baseLog
              .copyWith(responseStatus: 500, error: 'Internal Error')
              .statusText,
          equals('Error'),
        );
      });

      test('should return "Pending" for null status', () {
        // Create a new log with null responseStatus
        final logWithNullStatus = NetworkLog(
          id: 'test-null-status',
          timestamp: DateTime(2024, 1, 1, 12),
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );
        expect(logWithNullStatus.statusText, equals('Pending'));
      });

      test('should return status code as string for unknown status codes', () {
        expect(baseLog.copyWith(responseStatus: 418).statusText, equals('418'));
        expect(baseLog.copyWith(responseStatus: 999).statusText, equals('999'));
      });
    });

    group('durationText Property', () {
      test('should return milliseconds for durations less than 1 second', () {
        expect(
          baseLog
              .copyWith(duration: const Duration(milliseconds: 100))
              .durationText,
          equals('100ms'),
        );
        expect(
          baseLog
              .copyWith(duration: const Duration(milliseconds: 999))
              .durationText,
          equals('999ms'),
        );
      });

      test(
        'should return seconds with decimal for durations 1 second or more',
        () {
          expect(
            baseLog.copyWith(duration: const Duration(seconds: 1)).durationText,
            equals('1.0s'),
          );
          expect(
            baseLog
                .copyWith(duration: const Duration(milliseconds: 1500))
                .durationText,
            equals('1.5s'),
          );
          expect(
            baseLog.copyWith(duration: const Duration(seconds: 2)).durationText,
            equals('2.0s'),
          );
          expect(
            baseLog
                .copyWith(duration: const Duration(milliseconds: 2500))
                .durationText,
            equals('2.5s'),
          );
        },
      );

      test('should return empty string for null duration', () {
        // Create a new log with null duration
        final logWithNullDuration = NetworkLog(
          id: baseLog.id,
          timestamp: baseLog.timestamp,
          method: baseLog.method,
          endpoint: baseLog.endpoint,
          requestBody: baseLog.requestBody,
          requestHeaders: baseLog.requestHeaders,
          responseStatus: baseLog.responseStatus,
          responseBody: baseLog.responseBody,
          responseHeaders: baseLog.responseHeaders,
          error: baseLog.error,
        );
        expect(logWithNullDuration.durationText, equals(''));
      });
    });

    group('shortEndpoint Property', () {
      test('should return full endpoint when length is 50 or less', () {
        const shortEndpoint = 'https://api.example.com/short';
        final log = baseLog.copyWith(endpoint: shortEndpoint);
        expect(log.shortEndpoint, equals(shortEndpoint));
      });

      test('should truncate endpoint when length is more than 50', () {
        const longEndpoint =
            'https://api.example.com/very/long/endpoint/that/exceeds/fifty/characters';
        final log = baseLog.copyWith(endpoint: longEndpoint);
        expect(
          log.shortEndpoint,
          equals('https://api.example.com/very/long/endpoint/that...'),
        );
        expect(log.shortEndpoint.length, equals(50));
      });

      test('should handle endpoint exactly 50 characters', () {
        const exactEndpoint =
            'https://api.example.com/endpoint/exactly/fifty/characters/here';
        final log = baseLog.copyWith(endpoint: exactEndpoint);
        expect(
          log.shortEndpoint,
          equals('https://api.example.com/endpoint/exactly/fifty/...'),
        );
      });
    });

    group('copyWith Method', () {
      test('should create new instance with updated values', () {
        final newTimestamp = DateTime(2024, 1, 2, 12);
        const newDuration = Duration(seconds: 5);
        const newStatus = 404;

        final copiedLog = baseLog.copyWith(
          timestamp: newTimestamp,
          duration: newDuration,
          responseStatus: newStatus,
        );

        expect(copiedLog.timestamp, equals(newTimestamp));
        expect(copiedLog.duration, equals(newDuration));
        expect(copiedLog.responseStatus, equals(newStatus));
      });

      test('should keep original values for unspecified parameters', () {
        final copiedLog = baseLog.copyWith(responseStatus: 500);

        expect(copiedLog.id, equals(baseLog.id));
        expect(copiedLog.timestamp, equals(baseLog.timestamp));
        expect(copiedLog.method, equals(baseLog.method));
        expect(copiedLog.endpoint, equals(baseLog.endpoint));
        expect(copiedLog.requestBody, equals(baseLog.requestBody));
        expect(copiedLog.requestHeaders, equals(baseLog.requestHeaders));
        expect(copiedLog.responseBody, equals(baseLog.responseBody));
        expect(copiedLog.responseHeaders, equals(baseLog.responseHeaders));
        expect(copiedLog.error, equals(baseLog.error));
        expect(copiedLog.responseStatus, equals(500));
      });

      test('should handle null values correctly', () {
        // Create a new log with null values
        final copiedLog = NetworkLog(
          id: 'test-null-values',
          timestamp: DateTime(2024, 1, 1, 12),
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );

        expect(copiedLog.responseStatus, isNull);
        expect(copiedLog.error, isNull);
        expect(copiedLog.duration, isNull);
      });
    });

    group('Equality and HashCode', () {
      test('should be equal to identical instance', () {
        final identicalLog = baseLog.copyWith();

        expect(baseLog, equals(identicalLog));
        expect(baseLog.hashCode, equals(identicalLog.hashCode));
      });

      test('should not be equal to different instances', () {
        final differentLog = baseLog.copyWith(id: 'different-id');
        expect(baseLog, isNot(equals(differentLog)));
        expect(baseLog.hashCode, isNot(equals(differentLog.hashCode)));
      });

      test('should not be equal to different types', () {
        expect(baseLog, isNot(equals('string')));
        expect(baseLog, isNot(equals(123)));
        expect(baseLog, isNot(equals(null)));
      });

      test('should be equal to itself', () {
        expect(baseLog, equals(baseLog));
        expect(baseLog.hashCode, equals(baseLog.hashCode));
      });

      test('should have different hash codes for different values', () {
        final log1 = baseLog.copyWith(id: 'id1');
        final log2 = baseLog.copyWith(id: 'id2');
        final log3 = baseLog.copyWith(responseStatus: 404);

        expect(log1.hashCode, isNot(equals(log2.hashCode)));
        expect(log1.hashCode, isNot(equals(log3.hashCode)));
        expect(log2.hashCode, isNot(equals(log3.hashCode)));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        final log = baseLog.copyWith(requestBody: '', error: '', endpoint: '');

        expect(log.requestBody, equals(''));
        expect(log.error, equals(''));
        expect(log.endpoint, equals(''));
        expect(log.shortEndpoint, equals(''));
      });

      test('should handle very long endpoints', () {
        final veryLongEndpoint = 'https://api.example.com/${'a' * 100}';
        final log = baseLog.copyWith(endpoint: veryLongEndpoint);

        expect(log.shortEndpoint.length, equals(50));
        expect(log.shortEndpoint.endsWith('...'), isTrue);
      });

      test('should handle zero duration', () {
        final log = baseLog.copyWith(duration: Duration.zero);
        expect(log.durationText, equals('0ms'));
      });

      test('should handle very long durations', () {
        final log = baseLog.copyWith(duration: const Duration(hours: 1));
        expect(log.durationText, equals('3600.0s'));
      });
    });
  });
}
