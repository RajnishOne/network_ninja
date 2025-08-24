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
      service.clearLogs();
    });

    test('should be singleton', () {
      // Act
      final instance1 = NetworkLogsService.instance;
      final instance2 = NetworkLogsService.instance;

      // Assert
      expect(identical(instance1, instance2), isTrue);
    });

    test('should start with empty logs', () {
      // Assert
      expect(service.logs, isEmpty);
    });

    test('should add log and emit to stream', () async {
      // Arrange
      final log = service.createLog(
        method: 'GET',
        endpoint: 'https://api.example.com/test',
        requestBody: 'test body',
        requestHeaders: {'Content-Type': 'application/json'},
      );

      // Act
      service.addLog(log);

      // Assert
      expect(service.logs.length, equals(1));
      expect(service.logs.first, equals(log));
    });

    test('should update log with response data', () {
      // Arrange
      final log = service.createLog(
        method: 'GET',
        endpoint: 'https://api.example.com/test',
      );
      service.addLog(log, requestId: 'test-request-id');

      // Act
      service.updateLogWithResponse(
        'test-request-id',
        responseStatus: 200,
        responseBody: '{"success": true}',
        responseHeaders: {'Content-Type': 'application/json'},
        duration: const Duration(milliseconds: 150),
      );

      // Assert
      final updatedLog = service.logs.first;
      expect(updatedLog.responseStatus, equals(200));
      expect(updatedLog.responseBody, equals('{"success": true}'));
      expect(updatedLog.responseHeaders, equals({'Content-Type': 'application/json'}));
      expect(updatedLog.duration, equals(const Duration(milliseconds: 150)));
    });

    test('should handle update with non-existent request ID gracefully', () {
      // Act & Assert
      expect(() => service.updateLogWithResponse(
        'non-existent-id',
        responseStatus: 200,
      ), returnsNormally);
    });

    test('should clear all logs', () {
      // Arrange
      final log1 = service.createLog(
        method: 'GET',
        endpoint: 'https://api.example.com/test1',
      );
      final log2 = service.createLog(
        method: 'POST',
        endpoint: 'https://api.example.com/test2',
      );
      service.addLog(log1);
      service.addLog(log2);
      expect(service.logs.length, equals(2));

      // Act
      service.clearLogs();

      // Assert
      expect(service.logs, isEmpty);
    });

    test('should limit logs to maximum count', () {
      // Arrange
      const maxLogs = 1000;
      final logs = List.generate(
        maxLogs + 10,
        (index) => service.createLog(
          method: 'GET',
          endpoint: 'https://api.example.com/test$index',
        ),
      );

      // Act
      for (final log in logs) {
        service.addLog(log);
      }

      // Assert
      expect(service.logs.length, equals(maxLogs));
      // Should keep the most recent logs
      expect(service.logs.first.endpoint, contains('test${maxLogs + 9}'));
    });

    test('should emit logs to stream when added', () async {
      // Arrange
      final log = service.createLog(
        method: 'GET',
        endpoint: 'https://api.example.com/test',
      );

      // Act
      service.addLog(log);

      // Assert
      await expectLater(
        service.logsStream,
        emits([contains(log)]),
      );
    });

    test('should create log with correct properties', () {
      // Arrange
      const method = 'POST';
      const endpoint = 'https://api.example.com/create';
      const requestBody = '{"name": "test"}';
      const requestHeaders = {'Authorization': 'Bearer token'};

      // Act
      final log = service.createLog(
        method: method,
        endpoint: endpoint,
        requestBody: requestBody,
        requestHeaders: requestHeaders,
      );

      // Assert
      expect(log.method, equals(method));
      expect(log.endpoint, equals(endpoint));
      expect(log.requestBody, equals(requestBody));
      expect(log.requestHeaders, equals(requestHeaders));
      expect(log.id, isNotEmpty);
      expect(log.timestamp, isA<DateTime>());
    });
  });
}
