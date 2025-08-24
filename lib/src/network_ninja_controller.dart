import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'services/network_logs_service.dart';
import 'widgets/network_logs_bubble_overlay.dart';
import 'screens/network_logs_screen.dart';

/// Main controller for Network Ninja Library
/// Provides a simple API to display the bubble and manage network logging
class NetworkNinjaController {
  static NetworkNinjaController? _instance;
  static NetworkNinjaController get instance =>
      _instance ??= NetworkNinjaController._();

  NetworkNinjaController._();

  /// Display the network logs bubble overlay
  /// This is the main function that clients will call to show the bubble
  static void showBubble(BuildContext context) {
    NetworkLogsBubbleOverlay.attachTo(context);
  }

  /// Remove the network logs bubble overlay
  static void hideBubble() {
    NetworkLogsBubbleOverlay.removeActiveOverlay();
  }

  /// Navigate to the network logs screen
  static void showNetworkLogs(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NetworkLogsScreen()));
  }

  /// Add a Dio interceptor to automatically log network requests
  /// Call this function and pass your Dio instance to enable automatic logging
  static void addInterceptor(Dio dio) {
    // Check if interceptor already exists to avoid duplicates
    final hasInterceptor = dio.interceptors.any(
      (interceptor) => interceptor is _NetworkNinjaInterceptor,
    );

    if (!hasInterceptor) {
      dio.interceptors.add(_NetworkNinjaInterceptor());
    }
  }

  /// Remove the Network Ninja interceptor from a Dio instance
  /// Call this function to stop automatic logging for a specific Dio instance
  static void removeInterceptor(Dio dio) {
    dio.interceptors.removeWhere(
      (interceptor) => interceptor is _NetworkNinjaInterceptor,
    );
  }

  /// Clear all network logs
  static void clearLogs() {
    NetworkLogsService.instance.clearLogs();
  }

  /// Get the current log count
  static int get logCount => NetworkLogsService.instance.logCount;

  /// Get all logs
  static List<dynamic> get logs => NetworkLogsService.instance.logs;
}

/// Internal interceptor that automatically logs network requests
class _NetworkNinjaInterceptor extends Interceptor {
  final NetworkLogsService _service = NetworkLogsService.instance;
  final Map<String, DateTime> _requestStartTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = _generateUniqueRequestId(options);

    // Store the request ID in the options for later retrieval
    options.extra['networkNinjaRequestId'] = requestId;
    _requestStartTimes[requestId] = DateTime.now();

    // Create and add the log entry
    final log = _service.createLog(
      method: options.method,
      endpoint: options.uri.toString(),
      requestBody: _formatRequestBody(options.data),
      requestHeaders: _formatHeaders(options.headers),
    );

    // Store the request ID in the log for later matching
    _service.addLog(log, requestId: requestId);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId =
        response.requestOptions.extra['networkNinjaRequestId'] as String?;

    if (requestId == null) {
      super.onResponse(response, handler);
      return;
    }

    final startTime = _requestStartTimes[requestId];
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : null;

    // Update the log with response data
    _service.updateLogWithResponse(
      requestId,
      responseStatus: response.statusCode,
      responseBody: _formatResponseBody(response.data),
      responseHeaders: _formatHeaders(response.headers.map),
      duration: duration,
    );

    super.onResponse(response, handler);
    _requestStartTimes.remove(requestId);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId =
        err.requestOptions.extra['networkNinjaRequestId'] as String?;

    if (requestId == null) {
      super.onError(err, handler);
      return;
    }

    final startTime = _requestStartTimes[requestId];
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : null;

    // Update the log with error data
    _service.updateLogWithResponse(
      requestId,
      responseStatus: err.response?.statusCode,
      responseBody: _formatResponseBody(err.response?.data),
      responseHeaders: _formatHeaders(err.response?.headers.map),
      duration: duration,
      error: err.message,
    );

    super.onError(err, handler);
    _requestStartTimes.remove(requestId);
  }

  String _generateUniqueRequestId(RequestOptions options) {
    // Create a unique identifier based on URI, method, data, and timestamp
    String requestHash = options.uri.toString() + options.method;
    if (options.data != null) {
      requestHash += options.data.toString().hashCode.toString();
    }
    // Add timestamp to ensure uniqueness for polling requests
    requestHash += DateTime.now().millisecondsSinceEpoch.toString();
    return requestHash;
  }

  String? _formatRequestBody(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (e) {
        return data.toString();
      }
    }
    return data.toString();
  }

  String? _formatResponseBody(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (e) {
        return data.toString();
      }
    }
    return data.toString();
  }

  Map<String, String>? _formatHeaders(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return null;

    final formattedHeaders = <String, String>{};
    headers.forEach((key, value) {
      // Redact sensitive headers
      if (key.toLowerCase() == 'authorization' ||
          key.toLowerCase() == 'cookie' ||
          key.toLowerCase() == 'set-cookie') {
        formattedHeaders[key] = '[REDACTED]';
      } else {
        formattedHeaders[key] = value.toString();
      }
    });

    return formattedHeaders;
  }
}

/// Extension to make it easier to use Network Ninja in your app
extension NetworkNinjaExtension on BuildContext {
  /// Show the Network Ninja bubble
  void showNetworkNinjaBubble() {
    NetworkNinjaController.showBubble(this);
  }

  /// Navigate to network logs
  void showNetworkLogs() {
    NetworkNinjaController.showNetworkLogs(this);
  }
}
