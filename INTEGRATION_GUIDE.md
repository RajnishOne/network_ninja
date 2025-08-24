# Network Ninja Library Integration Guide for qBitConnect

This guide shows how to integrate the Network Ninja Library into your existing qBitConnect app.

## Step 1: Add Network Ninja Library to Your Project

Add the `network_ninja_lib` package to your `pubspec.yaml`:

```yaml
dependencies:
  network_ninja_lib:
    path: ../network_ninja_lib  # For local development
    # Or use: network_ninja_lib: ^1.0.0  # When published
```

## Step 2: Integrate with Your Existing HTTP Client

Modify your `lib/src/api/client/http_client.dart` to include the Network Ninja interceptor:

```dart
import 'package:network_ninja_lib/network_ninja_lib.dart';

class HttpClientFactory {
  static Dio createClient({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    bool enableLogging = true,
  }) {
    final dio = Dio(
      HttpClientConfig.createBaseOptions(baseUrl, defaultHeaders),
    );

    // Add cookie management
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    // Add Network Ninja interceptor for automatic logging
    if (enableLogging) {
      NetworkNinjaController.addInterceptor(dio);
    }

    // Keep your existing logging interceptors if needed
    if (enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: false,
          error: true,
          logPrint: (obj) => print(obj),
        ),
      );

      // You can keep or remove the existing ApiLoggingInterceptor
      // dio.interceptors.add(ApiLoggingInterceptor());
    }

    return dio;
  }
}
```

## Step 3: Add the Bubble Trigger

You can add the bubble trigger in several ways. Here are some options:

### Option A: Add to Settings Screen

In your `lib/src/screens/settings_screen.dart`, add a button to show the bubble:

```dart
import 'package:network_ninja_lib/network_ninja_lib.dart';

// In your settings list, add:
ListTile(
  leading: const Icon(Icons.network_check),
  title: const Text('Show Network Logs Bubble'),
  subtitle: const Text('Display floating network monitor'),
  onTap: () {
    context.showNetworkNinjaBubble();
  },
),
```

### Option B: Add to App Bar

In your main screens, add a button to the app bar:

```dart
import 'package:network_ninja_lib/network_ninja_lib.dart';

// In your AppBar actions:
AppBar(
  title: const Text('qBitConnect'),
  actions: [
    IconButton(
      icon: const Icon(Icons.network_check),
      onPressed: () {
        context.showNetworkNinjaBubble();
      },
    ),
  ],
),
```

### Option C: Add to Floating Action Button

In your `lib/src/screens/torrents_screen.dart`, modify the FAB:

```dart
import 'package:network_ninja_lib/network_ninja_lib.dart';

// Replace or modify your existing FAB:
floatingActionButton: Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      heroTag: "network_logs",
      onPressed: () {
        context.showNetworkNinjaBubble();
      },
      child: const Icon(Icons.network_check),
    ),
    const SizedBox(width: 16),
    const AddTorrentFab(),
  ],
),
```

## Step 4: Test the Integration

1. Run your app
2. Make some API calls (connect to qBittorrent, fetch torrents, etc.)
3. Trigger the bubble using one of the methods above
4. Look for the floating bubble in the bottom-right corner
5. Tap the bubble to see the network logs screen
6. Tap on any log entry to see detailed request/response information

## Step 5: Optional - Add Navigation to Network Logs

You can also add direct navigation to the network logs screen:

```dart
import 'package:network_ninja_lib/network_ninja_lib.dart';

// In your settings or anywhere else:
ListTile(
  leading: const Icon(Icons.list),
  title: const Text('Network Logs'),
  subtitle: const Text('View all API request logs'),
  onTap: () {
    context.showNetworkLogs();
  },
),
```

## Features You'll Get

- **Real-time Network Monitoring**: See all your qBittorrent API calls in real-time
- **Request/Response Details**: View headers, data, timing, and status codes
- **Error Tracking**: Easily identify failed API calls
- **Performance Monitoring**: Track response times for optimization
- **Security**: Sensitive data is automatically redacted
- **Filtering**: Filter logs by status, method, or URL patterns

## API Usage Examples

### Show the Bubble

```dart
// Method 1: Using the controller
NetworkNinjaController.showBubble(context);

// Method 2: Using the extension
context.showNetworkNinjaBubble();
```

### Navigate to Logs

```dart
// Method 1: Using the controller
NetworkNinjaController.showNetworkLogs(context);

// Method 2: Using the extension
context.showNetworkLogs();
```

### Programmatic Access

```dart
// Clear all logs
NetworkNinjaController.clearLogs();

// Get log count
final count = NetworkNinjaController.logCount;

// Hide the bubble
NetworkNinjaController.hideBubble();
```

## Migration from Existing Network Logging

If you're currently using the existing network logging components in your app, you can:

1. **Keep Both**: Run both systems side by side for comparison
2. **Gradual Migration**: Replace the old system gradually
3. **Complete Replacement**: Remove the old components and use only the library

### To Remove Old Components

If you decide to completely replace the old system, you can remove these files:

- `lib/src/widgets/network_logs_bubble.dart`
- `lib/src/widgets/network_logs_bubble_overlay.dart`
- `lib/src/screens/network_logs_screen.dart`
- `lib/src/screens/network_log_details_screen.dart`
- `lib/src/services/network_logs_service.dart`
- `lib/src/models/network_log.dart`

And remove any references to them in your settings screen and other places.

## Customization

### Customize Log Entry Limit

The library keeps the last 1000 logs by default. You can modify this in the `NetworkLogsService` if needed.

### Enable/Disable Logging

```dart
// In your HTTP client factory, you can conditionally enable logging
bool enableLogging = kDebugMode; // Only enable in debug mode

if (enableLogging) {
  NetworkNinjaController.addInterceptor(dio);
}
```

## Troubleshooting

### Bubble Not Appearing
- Make sure you've called `NetworkNinjaController.showBubble(context)` or `context.showNetworkNinjaBubble()`
- Check that the bubble is not being hidden behind other widgets

### No Logs Showing
- Verify that the interceptor is added to your Dio instance
- Make sure you're making actual API calls
- Check that logging is enabled

### Performance Issues
- The library is designed to be lightweight, but you can disable it in production builds
- Clear logs periodically if needed using `NetworkNinjaController.clearLogs()`

## Next Steps

Once integrated, you can:

1. **Monitor API Performance**: Track which qBittorrent endpoints are slow
2. **Debug Issues**: Easily see failed requests and their details
3. **Optimize Network Calls**: Identify redundant or unnecessary API calls
4. **Security Auditing**: Review what data is being sent/received
5. **User Support**: Help users debug connection issues by viewing their network logs

The Network Ninja Library provides a clean, simple API that integrates seamlessly with your existing qBitConnect app while providing powerful network monitoring capabilities.
