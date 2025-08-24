import 'dart:async';
import '../models/network_log.dart';

class NetworkLogsService {
  static NetworkLogsService? _instance;
  static NetworkLogsService get instance =>
      _instance ??= NetworkLogsService._();
  NetworkLogsService._();

  final List<NetworkLog> _logs = [];
  final Map<String, String> _requestIdToLogId = {}; // Map request ID to log ID
  final StreamController<List<NetworkLog>> _logsController =
      StreamController<List<NetworkLog>>.broadcast();

  static const int _maxLogs = 100; // Keep last 100 logs

  Stream<List<NetworkLog>> get logsStream => _logsController.stream;
  List<NetworkLog> get logs => List.unmodifiable(_logs);
  int get logCount => _logs.length;

  void addLog(NetworkLog log, {String? requestId}) {
    _logs.add(log);

    // Store the mapping if requestId is provided
    if (requestId != null) {
      _requestIdToLogId[requestId] = log.id;
    }

    // Keep only the last _maxLogs entries
    if (_logs.length > _maxLogs) {
      _logs.removeRange(0, _logs.length - _maxLogs);
    }

    _logsController.add(_logs);
  }

  void updateLog(String id, NetworkLog updatedLog) {
    final index = _logs.indexWhere((log) => log.id == id);
    if (index != -1) {
      _logs[index] = updatedLog;
      _logsController.add(_logs);
    }
  }

  void clearLogs() {
    _logs.clear();
    _requestIdToLogId.clear();
    _logsController.add(_logs);
  }

  void dispose() {
    _logsController.close();
  }

  // Helper method to create a new log entry
  NetworkLog createLog({
    required String method,
    required String endpoint,
    String? requestBody,
    Map<String, String>? requestHeaders,
  }) {
    return NetworkLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      method: method,
      endpoint: endpoint,
      requestBody: requestBody,
      requestHeaders: requestHeaders,
    );
  }

  // Helper method to update a log with response data
  void updateLogWithResponse(
    String requestId, {
    int? responseStatus,
    String? responseBody,
    Map<String, String>? responseHeaders,
    Duration? duration,
    String? error,
  }) {
    // Find the log ID using the request ID mapping
    final logId = _requestIdToLogId[requestId];

    if (logId == null) {
      return;
    }

    final index = _logs.indexWhere((log) => log.id == logId);

    if (index != -1) {
      final updatedLog = _logs[index].copyWith(
        responseStatus: responseStatus,
        responseBody: responseBody,
        responseHeaders: responseHeaders,
        duration: duration,
        error: error,
      );
      _logs[index] = updatedLog;
      _logsController.add(_logs);

      // Clean up the mapping after updating
      _requestIdToLogId.remove(requestId);
    }
  }
}
