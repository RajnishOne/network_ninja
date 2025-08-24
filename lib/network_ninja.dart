/// A powerful network logger library with floating bubble UI for monitoring API calls.
///
/// This library provides a comprehensive solution for monitoring and debugging
/// network requests in Flutter applications. It includes a floating bubble UI,
/// detailed logs, and various export options.
///
/// ## Features
///
/// * **Floating Bubble UI**: Easy access to network logs from anywhere in your app
/// * **Real-time Monitoring**: Track all API calls with automatic request/response matching
/// * **Search & Filter**: Find specific requests by endpoint, method, or status
/// * **Detailed Views**: Comprehensive request and response information
/// * **Export Options**: Copy as cURL, JSON, or share logs
/// * **Performance Optimized**: Fast animations suitable for high-frequency polling
///
/// ## Getting Started
///
/// ```dart
/// import 'package:network_ninja/network_ninja.dart';
///
/// // Add the interceptor to your Dio client
/// NetworkNinjaController.addInterceptor(dio);
///
/// // Show the bubble UI
/// context.showNetworkNinjaBubble();
/// ```
library network_ninja;

export 'src/network_ninja_controller.dart';
export 'src/models/network_log.dart';
export 'src/services/network_logs_service.dart';
