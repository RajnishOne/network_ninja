class NetworkLog {
  final String id;
  final DateTime timestamp;
  final String method;
  final String endpoint;
  final String? requestBody;
  final Map<String, String>? requestHeaders;
  final int? responseStatus;
  final String? responseBody;
  final Map<String, String>? responseHeaders;
  final Duration? duration;
  final String? error;

  NetworkLog({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.endpoint,
    this.requestBody,
    this.requestHeaders,
    this.responseStatus,
    this.responseBody,
    this.responseHeaders,
    this.duration,
    this.error,
  });

  bool get isSuccess =>
      responseStatus != null && responseStatus! >= 200 && responseStatus! < 300;
  bool get hasError =>
      error != null || (responseStatus != null && responseStatus! >= 400);

  String get statusText {
    if (error != null) return 'Error';
    if (responseStatus == null) return 'Pending';
    return responseStatus.toString();
  }

  String get durationText {
    if (duration == null) return '';
    if (duration!.inMilliseconds < 1000) {
      return '${duration!.inMilliseconds}ms';
    }
    return '${(duration!.inMilliseconds / 1000).toStringAsFixed(1)}s';
  }

  String get shortEndpoint {
    if (endpoint.length <= 50) return endpoint;
    return '${endpoint.substring(0, 47)}...';
  }

  NetworkLog copyWith({
    String? id,
    DateTime? timestamp,
    String? method,
    String? endpoint,
    String? requestBody,
    Map<String, String>? requestHeaders,
    int? responseStatus,
    String? responseBody,
    Map<String, String>? responseHeaders,
    Duration? duration,
    String? error,
  }) =>
      NetworkLog(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        method: method ?? this.method,
        endpoint: endpoint ?? this.endpoint,
        requestBody: requestBody ?? this.requestBody,
        requestHeaders: requestHeaders ?? this.requestHeaders,
        responseStatus: responseStatus ?? this.responseStatus,
        responseBody: responseBody ?? this.responseBody,
        responseHeaders: responseHeaders ?? this.responseHeaders,
        duration: duration ?? this.duration,
        error: error ?? this.error,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkLog &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.method == method &&
        other.endpoint == endpoint &&
        other.requestBody == requestBody &&
        other.requestHeaders == requestHeaders &&
        other.responseStatus == responseStatus &&
        other.responseBody == responseBody &&
        other.responseHeaders == responseHeaders &&
        other.duration == duration &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
      id,
      timestamp,
      method,
      endpoint,
      requestBody,
      requestHeaders,
      responseStatus,
      responseBody,
      responseHeaders,
      duration,
      error,
    );
}
