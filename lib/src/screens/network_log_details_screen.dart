import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/network_log.dart';

class NetworkLogDetailsScreen extends StatelessWidget {
  final NetworkLog log;

  const NetworkLogDetailsScreen({super.key, required this.log});

  String _formatJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return '';

    try {
      // Try to parse and format the JSON
      final dynamic parsed = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (e) {
      // If parsing fails, return the original string
      return jsonString;
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'copy_curl':
        _copyCurlToClipboard(context);
        break;
      case 'copy_url':
        _copyToClipboard(context, log.endpoint, 'URL copied to clipboard');
        break;
      case 'copy_request':
        _copyRequestToClipboard(context);
        break;
      case 'copy_response':
        _copyResponseToClipboard(context);
        break;
      case 'share':
        _shareLog(context);
        break;
      case 'open_url':
        _openUrlInBrowser(context);
        break;
      case 'export_json':
        _exportAsJson(context);
        break;
    }
  }

  void _copyCurlToClipboard(BuildContext context) {
    final curlCommand = _generateCurlCommand();
    _copyToClipboard(context, curlCommand, 'cURL command copied to clipboard');
  }

  String _generateCurlCommand() {
    final buffer = StringBuffer();
    buffer.write('curl -X ${log.method.toUpperCase()} ');

    // Add headers
    if (log.requestHeaders != null) {
      for (final entry in log.requestHeaders!.entries) {
        if (entry.key.toLowerCase() != 'host') {
          buffer.write('-H "${entry.key}: ${entry.value}" ');
        }
      }
    }

    // Add body if present
    if (log.requestBody != null && log.requestBody!.isNotEmpty) {
      buffer.write('-d \'${log.requestBody!.replaceAll("'", r"\'")}\' ');
    }

    buffer.write('"${log.endpoint}"');
    return buffer.toString();
  }

  void _copyRequestToClipboard(BuildContext context) {
    final requestData = {
      'method': log.method,
      'url': log.endpoint,
      'headers': log.requestHeaders,
      'body': log.requestBody,
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(requestData);
    _copyToClipboard(context, jsonString, 'Request data copied to clipboard');
  }

  void _copyResponseToClipboard(BuildContext context) {
    final responseData = {
      'status': log.responseStatus,
      'headers': log.responseHeaders,
      'body': log.responseBody,
      'error': log.error,
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(responseData);
    _copyToClipboard(context, jsonString, 'Response data copied to clipboard');
  }

  void _shareLog(BuildContext context) {
    final shareText =
        '''
Network Log: ${log.method} ${log.endpoint}
Status: ${log.statusText}
Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.timestamp)}
Duration: ${log.durationText}
''';
    _copyToClipboard(context, shareText, 'Log details copied to clipboard');
  }

  Future<void> _openUrlInBrowser(BuildContext context) async {
    try {
      final uri = Uri.parse(log.endpoint);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not open URL')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid URL')));
      }
    }
  }

  void _exportAsJson(BuildContext context) {
    final exportData = {
      'method': log.method,
      'endpoint': log.endpoint,
      'timestamp': log.timestamp.toIso8601String(),
      'status': log.responseStatus,
      'duration': log.duration?.inMilliseconds,
      'request': {'headers': log.requestHeaders, 'body': log.requestBody},
      'response': {
        'headers': log.responseHeaders,
        'body': log.responseBody,
        'error': log.error,
      },
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    _copyToClipboard(context, jsonString, 'Log exported as JSON to clipboard');
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${log.method} ${log.endpoint}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy_curl',
                child: Row(
                  children: [
                    Icon(Icons.content_copy),
                    SizedBox(width: 8),
                    Text('Copy cURL'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_url',
                child: Row(
                  children: [
                    Icon(Icons.link),
                    SizedBox(width: 8),
                    Text('Copy URL'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_request',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('Copy Request'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_response',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Copy Response'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'open_url',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new),
                    SizedBox(width: 8),
                    Text('Open in Browser'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_json',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Export as JSON'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusIcon(log: log),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _copyToClipboard(
                                  context,
                                  log.endpoint,
                                  'URL copied to clipboard',
                                ),
                                child: Text(
                                  '${log.method} ${log.endpoint}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(log.timestamp),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              log.statusText,
                              style: TextStyle(
                                color: log.hasError
                                    ? Colors.red
                                    : log.isSuccess
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (log.durationText.isNotEmpty)
                              Text(
                                log.durationText,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Request Details
            _DetailSection(
              title: 'Request',
              onTitleTap: () => _copyRequestToClipboard(context),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (log.requestHeaders != null &&
                      log.requestHeaders!.isNotEmpty) ...[
                    const Text(
                      'Headers:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...log.requestHeaders!.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('${e.key}: ${e.value}'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (log.requestBody != null &&
                      log.requestBody!.isNotEmpty) ...[
                    const Text(
                      'Body:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _formatJsonString(log.requestBody!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (log.responseStatus != null || log.error != null) ...[
              const SizedBox(height: 24),
              _DetailSection(
                title: 'Response',
                onTitleTap: () => _copyResponseToClipboard(context),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (log.responseStatus != null) ...[
                      Text('Status: ${log.responseStatus}'),
                      const SizedBox(height: 16),
                    ],
                    if (log.responseHeaders != null &&
                        log.responseHeaders!.isNotEmpty) ...[
                      const Text(
                        'Headers:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...log.responseHeaders!.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${e.key}: ${e.value}'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (log.responseBody != null &&
                        log.responseBody!.isNotEmpty) ...[
                      const Text(
                        'Body:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _formatJsonString(log.responseBody!),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                    if (log.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Error: ${log.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final NetworkLog log;

  const _StatusIcon({required this.log});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (log.hasError) {
      icon = Icons.error;
      color = Colors.red;
    } else if (log.isSuccess) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (log.responseStatus == null) {
      icon = Icons.hourglass_empty;
      color = Colors.orange;
    } else {
      icon = Icons.info;
      color = Colors.blue;
    }

    return Icon(icon, color: color, size: 20);
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback? onTitleTap;

  const _DetailSection({
    required this.title,
    required this.content,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTitleTap,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: content,
        ),
      ],
    );
  }
}
