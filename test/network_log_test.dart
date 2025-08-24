import 'package:flutter_test/flutter_test.dart';
import 'package:network_ninja/network_ninja.dart';

void main() {
  group('NetworkLog', () {
    late NetworkLog log;

    setUp(() {
      log = NetworkLog(
        id: 'test-id',
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        method: 'GET',
        endpoint: 'https://api.example.com/test',
        requestBody: '{"test": "data"}',
        requestHeaders: {'Content-Type': 'application/json'},
        responseStatus: 200,
        responseBody: '{"success": true}',
        responseHeaders: {'Content-Type': 'application/json'},
        duration: const Duration(milliseconds: 150),
        error: null,
      );
    });

    test('should create NetworkLog with all properties', () {
      // Assert
      expect(log.id, equals('test-id'));
      expect(log.timestamp, equals(DateTime(2024, 1, 1, 12, 0, 0)));
      expect(log.method, equals('GET'));
      expect(log.endpoint, equals('https://api.example.com/test'));
      expect(log.requestBody, equals('{"test": "data"}'));
      expect(log.requestHeaders, equals({'Content-Type': 'application/json'}));
      expect(log.responseStatus, equals(200));
      expect(log.responseBody, equals('{"success": true}'));
      expect(log.responseHeaders, equals({'Content-Type': 'application/json'}));
      expect(log.duration, equals(const Duration(milliseconds: 150)));
      expect(log.error, isNull);
    });

    test('should identify successful requests correctly', () {
      // Arrange
      final successLog = log.copyWith(responseStatus: 200);
      final errorLog = log.copyWith(responseStatus: 404);
      final pendingLog = log.copyWith(responseStatus: null);

      // Assert
      expect(successLog.isSuccess, isTrue);
      expect(errorLog.isSuccess, isFalse);
      expect(pendingLog.isSuccess, isFalse);
    });

    test('should identify error requests correctly', () {
      // Arrange
      final successLog = log.copyWith(responseStatus: 200);
      final errorLog = log.copyWith(responseStatus: 500);
      final pendingLog = log.copyWith(responseStatus: null);
      final errorWithMessageLog = log.copyWith(
        responseStatus: 400,
        error: 'Bad Request',
      );

      // Assert
      expect(successLog.hasError, isFalse);
      expect(errorLog.hasError, isTrue);
      expect(pendingLog.hasError, isFalse);
      expect(errorWithMessageLog.hasError, isTrue);
    });

    test('should generate correct status text', () {
      // Arrange & Assert
      expect(log.copyWith(responseStatus: 200).statusText, equals('200 OK'));
      expect(log.copyWith(responseStatus: 404).statusText, equals('404 Not Found'));
      expect(log.copyWith(responseStatus: 500).statusText, equals('500 Internal Server Error'));
      expect(log.copyWith(responseStatus: null).statusText, equals('Pending'));
      expect(log.copyWith(responseStatus: 400, error: 'Bad Request').statusText, equals('400 Bad Request'));
    });

    test('should generate correct duration text', () {
      // Arrange & Assert
      expect(log.copyWith(duration: const Duration(milliseconds: 150)).durationText, equals('150ms'));
      expect(log.copyWith(duration: const Duration(seconds: 2)).durationText, equals('2.0s'));
      expect(log.copyWith(duration: const Duration(milliseconds: 2500)).durationText, equals('2.5s'));
      expect(log.copyWith(duration: null).durationText, equals(''));
    });

    test('should copy with new values correctly', () {
      // Arrange
      final newTimestamp = DateTime(2024, 1, 2, 12, 0, 0);
      final newDuration = const Duration(milliseconds: 300);

      // Act
      final copiedLog = log.copyWith(
        timestamp: newTimestamp,
        duration: newDuration,
      );

      // Assert
      expect(copiedLog.timestamp, equals(newTimestamp));
      expect(copiedLog.duration, equals(newDuration));
      // Other properties should remain the same
      expect(copiedLog.id, equals(log.id));
      expect(copiedLog.method, equals(log.method));
      expect(copiedLog.endpoint, equals(log.endpoint));
    });

    test('should handle equality correctly', () {
      // Arrange
      final sameLog = NetworkLog(
        id: 'test-id',
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        method: 'GET',
        endpoint: 'https://api.example.com/test',
        requestBody: '{"test": "data"}',
        requestHeaders: {'Content-Type': 'application/json'},
        responseStatus: 200,
        responseBody: '{"success": true}',
        responseHeaders: {'Content-Type': 'application/json'},
        duration: const Duration(milliseconds: 150),
        error: null,
      );

      final differentLog = log.copyWith(id: 'different-id');

      // Assert
      expect(log, equals(sameLog));
      expect(log, isNot(equals(differentLog)));
    });

    test('should handle hash code correctly', () {
      // Arrange
      final sameLog = NetworkLog(
        id: 'test-id',
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        method: 'GET',
        endpoint: 'https://api.example.com/test',
        requestBody: '{"test": "data"}',
        requestHeaders: {'Content-Type': 'application/json'},
        responseStatus: 200,
        responseBody: '{"success": true}',
        responseHeaders: {'Content-Type': 'application/json'},
        duration: const Duration(milliseconds: 150),
        error: null,
      );

      // Assert
      expect(log.hashCode, equals(sameLog.hashCode));
    });
  });
}
