import 'package:flutter_test/flutter_test.dart';
import 'package:network_ninja/network_ninja.dart';

void main() {
  test('debug statusText', () {
    final log = NetworkLog(
      id: 'test',
      timestamp: DateTime.now(),
      method: 'GET',
      endpoint: 'https://api.example.com/test',
      responseStatus: 400,
      error: 'Bad Request',
    );

    // Debug output removed for production

    expect(log.statusText, equals('Error'));
  });
}
