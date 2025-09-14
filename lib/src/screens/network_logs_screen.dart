import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/network_log.dart';
import '../services/network_logs_service.dart';
import 'network_log_details_screen.dart';

class NetworkLogsScreen extends StatefulWidget {
  const NetworkLogsScreen({super.key});

  @override
  State<NetworkLogsScreen> createState() => _NetworkLogsScreenState();
}

class _NetworkLogsScreenState extends State<NetworkLogsScreen> {
  final NetworkLogsService _logsService = NetworkLogsService.instance;
  final TextEditingController _searchController = TextEditingController();
  List<NetworkLog> _logs = [];
  String _filter = 'all'; // all, success, error, pending
  String _searchQuery = '';
  bool _isSearchActive = false;
  StreamSubscription<List<NetworkLog>>? _logsSubscription;

  // Caching variables for performance optimization
  List<NetworkLog>? _cachedFilteredLogs;
  String? _lastFilter;
  String? _lastSearchQuery;
  int? _lastLogsHash;

  @override
  void initState() {
    super.initState();
    _logs = _logsService.logs;
    _logsSubscription = _logsService.logsStream.listen((logs) {
      if (mounted) {
        setState(() {
          _logs = logs;
          // Clear cache when logs change
          _cachedFilteredLogs = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _logsSubscription?.cancel();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _searchQuery = '';
        // Clear cache when search is disabled
        _cachedFilteredLogs = null;
      }
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      // Clear cache when search query changes
      _cachedFilteredLogs = null;
    });
  }

  List<NetworkLog> get _filteredLogs {
    // Check if we can use cached results
    final logsHash = _logs.length.hashCode;
    if (_cachedFilteredLogs != null &&
        _lastFilter == _filter &&
        _lastSearchQuery == _searchQuery &&
        _lastLogsHash == logsHash) {
      return _cachedFilteredLogs!;
    }

    // Recalculate and cache the results
    List<NetworkLog> filtered;

    // Apply status filter first
    switch (_filter) {
      case 'success':
        filtered = _logs.where((log) => log.isSuccess).toList();
        break;
      case 'error':
        filtered = _logs.where((log) => log.hasError).toList();
        break;
      case 'pending':
        filtered = _logs.where((log) => log.responseStatus == null).toList();
        break;
      default:
        filtered = List.from(_logs); // Create a mutable copy for sorting
    }

    // Apply search filter if active
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((log) {
        final endpoint = log.endpoint.toLowerCase();
        final method = log.method.toLowerCase();
        final statusText = log.statusText.toLowerCase();

        return endpoint.contains(_searchQuery) ||
            method.contains(_searchQuery) ||
            statusText.contains(_searchQuery);
      }).toList();
    }

    // Sort by timestamp (newest first) - only if needed
    if (filtered.isNotEmpty) {
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    // Cache the results
    _cachedFilteredLogs = filtered;
    _lastFilter = _filter;
    _lastSearchQuery = _searchQuery;
    _lastLogsHash = logsHash;

    return filtered;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Network Logs'),
      actions: [
        IconButton(
          icon: Icon(_isSearchActive ? Icons.search_off : Icons.search),
          onPressed: _toggleSearch,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _filter = value;
              // Clear cache when filter changes
              _cachedFilteredLogs = null;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'all', child: Text('All')),
            const PopupMenuItem(value: 'success', child: Text('Success')),
            const PopupMenuItem(value: 'error', child: Text('Errors')),
            const PopupMenuItem(value: 'pending', child: Text('Pending')),
          ],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_filter.toUpperCase()),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear_all),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear Logs'),
                content: const Text(
                  'Are you sure you want to clear all network logs?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _logsService.clearLogs();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
    body: Column(
      children: [
        // Search bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isSearchActive ? 60 : 0,
          child: _isSearchActive
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _updateSearchQuery,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      hintText: 'Search by endpoint, method, or status...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _updateSearchQuery('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                    ),
                    autofocus: true,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Logs list
        Expanded(
          child: _filteredLogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.network_check,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No logs match your search'
                            : 'No network logs found',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try adjusting your search terms'
                            : 'Network activity will appear here',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: ListView.builder(
                    key: ValueKey(_filteredLogs.length),
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                        child: _NetworkLogCard(log: log),
                      );
                    },
                  ),
                ),
        ),
      ],
    ),
  );
}

class _NetworkLogCard extends StatelessWidget {
  final NetworkLog log;

  const _NetworkLogCard({required this.log});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ListTile(
      leading: _StatusIcon(log: log),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                log.method,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log.endpoint,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                DateFormat('HH:mm:ss').format(log.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  log.statusText,
                  key: ValueKey('${log.id}_${log.responseStatus}_${log.error}'),
                  style: TextStyle(
                    color: log.hasError
                        ? Colors.red
                        : log.isSuccess
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (log.durationText.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  log.durationText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NetworkLogDetailsScreen(log: log),
        ),
      ),
    ),
  );
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: Icon(
        icon,
        key: ValueKey('${log.id}_${log.responseStatus}_${log.error}'),
        color: color,
        size: 20,
      ),
    );
  }
}
