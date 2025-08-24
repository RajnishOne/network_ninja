import 'package:flutter_test/flutter_test.dart';
import 'package:network_ninja/network_ninja.dart';

void main() {
  group('NetworkLogsService', () {
    late NetworkLogsService service;

    setUp(() {
      service = NetworkLogsService.instance;
      service.clearLogs(); // Start with clean state
    });

    tearDown(() {
      // Don't call clearLogs in tearDown as it can cause stream issues
      // The setUp already clears logs for each test
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = NetworkLogsService.instance;
        final instance2 = NetworkLogsService.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Log Management', () {
      test('should start with empty logs', () {
        expect(service.logs, isEmpty);
        expect(service.logCount, equals(0));
      });

      test('should add log correctly', () {
        // Arrange
        final log = NetworkLog(
          id: 'test-1',
          timestamp: DateTime.now(),
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );

        // Act
        service.addLog(log);

        // Assert
        expect(service.logs.length, equals(1));
        expect(service.logs.first, equals(log));
        expect(service.logCount, equals(1));
      });

      test('should add multiple logs', () {
        // Arrange
        final log1 = NetworkLog(
          id: 'test-1',
          timestamp: DateTime.now(),
          method: 'GET',
          endpoint: 'https://api.example.com/test1',
        );
        final log2 = NetworkLog(
          id: 'test-2',
          timestamp: DateTime.now(),
          method: 'POST',
          endpoint: 'https://api.example.com/test2',
        );

        // Act
        service.addLog(log1);
        service.addLog(log2);

        // Assert
        expect(service.logs.length, equals(2));
        expect(service.logs, contains(log1));
        expect(service.logs, contains(log2));
        expect(service.logCount, equals(2));
      });

      test('should clear all logs', () {
        // Arrange
        final log = NetworkLog(
          id: 'test-1',
          timestamp: DateTime.now(),
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );
        service.addLog(log);
        expect(service.logs.length, equals(1));

        // Act
        service.clearLogs();

        // Assert
        expect(service.logs, isEmpty);
        expect(service.logCount, equals(0));
      });
    });

    group('Log Creation', () {
      test('should create log with basic information', () {
        // Act
        final log = service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );

        // Assert
        expect(log.method, equals('GET'));
        expect(log.endpoint, equals('https://api.example.com/test'));
        expect(log.id, isNotEmpty);
        expect(log.timestamp, isA<DateTime>());
        expect(log.requestBody, isNull);
        expect(log.requestHeaders, isNull);
        expect(log.responseStatus, isNull);
        expect(log.responseBody, isNull);
        expect(log.responseHeaders, isNull);
        expect(log.duration, isNull);
        expect(log.error, isNull);
      });

      test('should create log with all information', () {
        // Arrange
        final headers = {'Content-Type': 'application/json'};
        final requestBody = '{"test": "data"}';

        // Act
        final log = service.createLog(
          method: 'POST',
          endpoint: 'https://api.example.com/test',
          requestBody: requestBody,
          requestHeaders: headers,
        );

        // Assert
        expect(log.method, equals('POST'));
        expect(log.endpoint, equals('https://api.example.com/test'));
        expect(log.requestBody, equals(requestBody));
        expect(log.requestHeaders, equals(headers));
      });

      test('should generate unique IDs for different logs', () async {
        // Act
        final log1 = service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test1',
        );

        // Add a small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 1));

        final log2 = service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test2',
        );

        // Assert
        expect(log1.id, isNot(equals(log2.id)));
      });
    });

    group('Log Updates', () {
      test('should update log with response information', () {
        // Arrange
        final log = service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );
        service.addLog(log, requestId: 'test-request');

        // Act
        service.updateLogWithResponse(
          'test-request',
          responseStatus: 200,
          responseBody: '{"success": true}',
          responseHeaders: {'Content-Type': 'application/json'},
          duration: const Duration(milliseconds: 150),
        );

        // Assert
        final updatedLog = service.logs.first;
        expect(updatedLog.responseStatus, equals(200));
        expect(updatedLog.responseBody, equals('{"success": true}'));
        expect(updatedLog.responseHeaders,
            equals({'Content-Type': 'application/json'}));
        expect(updatedLog.duration, equals(const Duration(milliseconds: 150)));
        expect(updatedLog.error, isNull);
      });

      test('should update log with error information', () {
        // Arrange
        final log = service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );
        service.addLog(log, requestId: 'test-request');

        // Act
        service.updateLogWithResponse(
          'test-request',
          responseStatus: 404,
          responseBody: '{"error": "Not found"}',
          responseHeaders: {'Content-Type': 'application/json'},
          duration: const Duration(milliseconds: 100),
          error: 'Resource not found',
        );

        // Assert
        final updatedLog = service.logs.first;
        expect(updatedLog.responseStatus, equals(404));
        expect(updatedLog.responseBody, equals('{"error": "Not found"}'));
        expect(updatedLog.responseHeaders,
            equals({'Content-Type': 'application/json'}));
        expect(updatedLog.duration, equals(const Duration(milliseconds: 100)));
        expect(updatedLog.error, equals('Resource not found'));
      });

      test('should handle updating non-existent log gracefully', () {
        // Act & Assert
        expect(
          () => service.updateLogWithResponse(
            'non-existent-request',
            responseStatus: 200,
          ),
          returnsNormally,
        );
      });
    });

    group('Stream Functionality', () {
      test('should emit logs to stream when added', () async {
        // Arrange
        final log = service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test',
        );

        // Act & Assert
        expectLater(
          service.logsStream,
          emits([log]),
        );

        service.addLog(log);
      });
    });

    group('Log Limits', () {
      test('should limit logs to maximum count', () {
        // Arrange
        const maxLogs = 100;
        final logs = List.generate(
            maxLogs + 10,
            (index) => service.createLog(
                  method: 'GET',
                  endpoint: 'https://api.example.com/test$index',
                ));

        // Act
        for (final log in logs) {
          service.addLog(log);
        }

        // Assert
        expect(service.logs.length, lessThanOrEqualTo(maxLogs));
        expect(service.logs.length, equals(maxLogs));
        expect(service.logCount, equals(maxLogs));
      });

      test('should keep most recent logs when limit is exceeded', () {
        // Arrange
        final logs = List.generate(
            110,
            (index) => service.createLog(
                  method: 'GET',
                  endpoint: 'https://api.example.com/test$index',
                ));

        // Act
        for (final log in logs) {
          service.addLog(log);
        }

        // Assert
        expect(service.logs.length, equals(100));
        // Should keep the last 100 logs (indices 10-109)
        expect(service.logs.first.endpoint, contains('test10'));
        expect(service.logs.last.endpoint, contains('test109'));
      });
    });

    group('Edge Cases', () {
      test('should handle null values in log creation', () {
        // Act
        final log = service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test',
          requestBody: null,
          requestHeaders: null,
        );

        // Assert
        expect(log.requestBody, isNull);
        expect(log.requestHeaders, isNull);
      });

      test('should handle empty strings', () {
        // Act
        final log = service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test',
          requestBody: '',
          requestHeaders: {},
        );

        // Assert
        expect(log.requestBody, equals(''));
        expect(log.requestHeaders, equals({}));
      });

      test('should handle very long request bodies', () {
        // Arrange
        final longBody = 'a' * 10000;

        // Act
        final log = service.createLog(
          method: 'POST',
          endpoint: 'https://api.example.com/test',
          requestBody: longBody,
        );

        // Assert
        expect(log.requestBody, equals(longBody));
      });

      test('should handle special characters in endpoint', () {
        // Arrange
        final specialEndpoint =
            'https://api.example.com/test?param=value&another=param#fragment';

        // Act
        final log = service.createLog(
          method: 'GET',
          endpoint: specialEndpoint,
        );

        // Assert
        expect(log.endpoint, equals(specialEndpoint));
      });
    });

    group('Dispose', () {
      test('should dispose service correctly', () {
        // Act & Assert
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
