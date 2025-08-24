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

    print('statusText: "${log.statusText}"');
    print('responseStatus: ${log.responseStatus}');
    print('error: ${log.error}');

    expect(log.statusText, equals('Error'));
  });
}
