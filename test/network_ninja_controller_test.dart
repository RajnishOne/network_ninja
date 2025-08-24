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

    test('should add interceptor to Dio instance', () {
      // Arrange
      final initialCount = dio.interceptors.length;

      // Act
      NetworkNinjaController.addInterceptor(dio);

      // Assert
      expect(dio.interceptors.length, greaterThan(initialCount));
      expect(
        dio.interceptors.any((interceptor) =>
            interceptor.runtimeType.toString().contains('NetworkNinja')),
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

    test('should remove interceptor from Dio instance', () {
      // Arrange
      NetworkNinjaController.addInterceptor(dio);
      expect(dio.interceptors, isNotEmpty);

      // Act
      NetworkNinjaController.removeInterceptor(dio);

      // Assert
      expect(
        dio.interceptors.any((interceptor) =>
            interceptor.runtimeType.toString().contains('NetworkNinja')),
        isFalse,
      );
    });

    test('should handle removing non-existent interceptor gracefully', () {
      // Arrange
      final initialCount = dio.interceptors.length;

      // Act & Assert
      expect(
          () => NetworkNinjaController.removeInterceptor(dio), returnsNormally);
      expect(dio.interceptors.length, equals(initialCount));
    });
  });
}
