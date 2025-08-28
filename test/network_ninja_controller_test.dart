import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:network_ninja/network_ninja.dart';

void main() {
  group('NetworkNinjaController', () {
    late Dio dio;

    setUp(() {
      dio = Dio();
    });

    tearDown(() {
      // Clean up any interceptors
      dio.interceptors.clear();
    });

    group('addInterceptor', () {
      test('should add interceptor to Dio instance', () {
        // Arrange
        final initialCount = dio.interceptors.length;

        // Act
        NetworkNinjaController.addInterceptor(dio);

        // Assert
        expect(dio.interceptors.length, greaterThan(initialCount));
        expect(
          dio.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isTrue,
        );
      });

      test('should not add duplicate interceptors', () {
        // Arrange
        NetworkNinjaController.addInterceptor(dio);
        final initialCount = dio.interceptors.length;

        // Act
        NetworkNinjaController.addInterceptor(dio);

        // Assert
        expect(dio.interceptors.length, equals(initialCount));
      });

      test('should add interceptor to Dio with existing interceptors', () {
        // Arrange
        dio.interceptors.add(LogInterceptor());
        final initialCount = dio.interceptors.length;

        // Act
        NetworkNinjaController.addInterceptor(dio);

        // Assert
        expect(dio.interceptors.length, equals(initialCount + 1));
        expect(
          dio.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isTrue,
        );
      });
    });

    group('removeInterceptor', () {
      test('should remove interceptor from Dio instance', () {
        // Arrange
        NetworkNinjaController.addInterceptor(dio);
        expect(
          dio.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isTrue,
        );

        // Act
        NetworkNinjaController.removeInterceptor(dio);

        // Assert
        expect(
          dio.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isFalse,
        );
      });

      test('should handle removing non-existent interceptor gracefully', () {
        // Arrange
        final initialCount = dio.interceptors.length;

        // Act & Assert
        expect(
          () => NetworkNinjaController.removeInterceptor(dio),
          returnsNormally,
        );
        expect(dio.interceptors.length, equals(initialCount));
      });

      test('should remove only NetworkNinja interceptors', () {
        // Arrange
        final logInterceptor = LogInterceptor();
        dio.interceptors.add(logInterceptor);
        NetworkNinjaController.addInterceptor(dio);
        final initialCount = dio.interceptors.length;

        // Act
        NetworkNinjaController.removeInterceptor(dio);

        // Assert
        expect(dio.interceptors.length, equals(initialCount - 1));
        expect(dio.interceptors.contains(logInterceptor), isTrue);
        expect(
          dio.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isFalse,
        );
      });

      test('should remove multiple NetworkNinja interceptors', () {
        // Arrange
        NetworkNinjaController.addInterceptor(dio);
        NetworkNinjaController.addInterceptor(
          dio,
        ); // This should not add duplicate
        final initialCount = dio.interceptors.length;

        // Act
        NetworkNinjaController.removeInterceptor(dio);

        // Assert
        expect(dio.interceptors.length, equals(initialCount - 1));
        expect(
          dio.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isFalse,
        );
      });
    });

    group('clearLogs', () {
      test('should clear all network logs', () {
        // Act
        expect(() => NetworkNinjaController.clearLogs(), returnsNormally);
      });
    });

    group('logCount', () {
      test('should return current log count', () {
        // Act & Assert
        expect(NetworkNinjaController.logCount, isA<int>());
        expect(NetworkNinjaController.logCount, greaterThanOrEqualTo(0));
      });
    });

    group('logs', () {
      test('should return all logs', () {
        // Act & Assert
        expect(NetworkNinjaController.logs, isA<List>());
      });
    });

    group('Integration Tests', () {
      test('should add and remove interceptor correctly', () {
        // Arrange
        final initialCount = dio.interceptors.length;

        // Act - Add interceptor
        NetworkNinjaController.addInterceptor(dio);
        expect(dio.interceptors.length, greaterThan(initialCount));

        // Act - Remove interceptor
        NetworkNinjaController.removeInterceptor(dio);
        expect(dio.interceptors.length, equals(initialCount));

        // Act - Add again
        NetworkNinjaController.addInterceptor(dio);
        expect(dio.interceptors.length, greaterThan(initialCount));
      });

      test('should handle multiple Dio instances', () {
        // Arrange
        final dio1 = Dio();
        final dio2 = Dio();

        // Act & Assert
        NetworkNinjaController.addInterceptor(dio1);
        NetworkNinjaController.addInterceptor(dio2);

        expect(
          dio1.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isTrue,
        );
        expect(
          dio2.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isTrue,
        );

        NetworkNinjaController.removeInterceptor(dio1);
        expect(
          dio1.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isFalse,
        );
        expect(
          dio2.interceptors.any(
            (interceptor) =>
                interceptor.runtimeType.toString().contains('NetworkNinja'),
          ),
          isTrue,
        );

        // Cleanup
        dio1.interceptors.clear();
        dio2.interceptors.clear();
      });
    });
  });
}
