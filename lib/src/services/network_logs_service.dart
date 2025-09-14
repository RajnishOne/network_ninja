import 'dart:async';
import 'dart:collection';
import '../models/network_log.dart';

class NetworkLogsService {
  static NetworkLogsService? _instance;

  static NetworkLogsService get instance =>
      _instance ??= NetworkLogsService._();

  NetworkLogsService._();

  final LinkedHashMap<String, NetworkLog> _logs = LinkedHashMap();
  final Map<String, String> _requestIdToLogId = {}; // Map request ID to log ID
  final StreamController<List<NetworkLog>> _logsController =
      StreamController<List<NetworkLog>>.broadcast();

  static const int _maxLogs = 100; // Keep last 100 logs
  int _logCounter = 0; // Counter to ensure unique IDs

  Stream<List<NetworkLog>> get logsStream => _logsController.stream;

  List<NetworkLog> get logs => List.unmodifiable(_logs.values);

  int get logCount => _logs.length;

  void addLog(NetworkLog log, {String? requestId}) {
    _logs[log.id] = log;

    // Store the mapping if requestId is provided
    if (requestId != null) {
      _requestIdToLogId[requestId] = log.id;
    }

    // Keep only the last _maxLogs entries - remove oldest entries
    if (_logs.length > _maxLogs) {
      final keysToRemove = _logs.keys.take(_logs.length - _maxLogs).toList();
      for (final key in keysToRemove) {
        _logs.remove(key);
      }
    }

    _logsController.add(_logs.values.toList());
  }

  void updateLog(String id, NetworkLog updatedLog) {
    if (_logs.containsKey(id)) {
      _logs[id] = updatedLog;
      _logsController.add(_logs.values.toList());
    }
  }

  void clearLogs() {
    _logs.clear();
    _requestIdToLogId.clear();
    _logsController.add(_logs.values.toList());
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
    final now = DateTime.now();
    // Use counter to ensure uniqueness even for rapid creation
    final id = '${now.millisecondsSinceEpoch}_${++_logCounter}';
    return NetworkLog(
      id: id,
      timestamp: now,
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

    // Direct O(1) access using LinkedHashMap
    final existingLog = _logs[logId];

    if (existingLog != null) {
      final updatedLog = existingLog.copyWith(
        responseStatus: responseStatus,
        responseBody: responseBody,
        responseHeaders: responseHeaders,
        duration: duration,
        error: error,
      );
      _logs[logId] = updatedLog;
      _logsController.add(_logs.values.toList());

      // Clean up the mapping after updating
      _requestIdToLogId.remove(requestId);
    }
  }
}
