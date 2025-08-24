import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:network_ninja/network_ninja.dart';

void main() {
  runApp(const NetworkNinjaExampleApp());
}

class NetworkNinjaExampleApp extends StatelessWidget {
  const NetworkNinjaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Ninja Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  late final Dio _dio;
  bool _isLoading = false;
  String _lastResponse = '';

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    // Add Network Ninja interceptor
    NetworkNinjaController.addInterceptor(_dio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Network Ninja Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => context.showNetworkNinjaBubble(),
            tooltip: 'Show Network Ninja Bubble',
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.showNetworkLogs(),
            tooltip: 'View Network Logs',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Ninja Demo',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This example demonstrates the Network Ninja package features. '
                          'Make some API requests and then check the network logs!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  _buildApiSection(),
                  const SizedBox(height: 16),
                  _buildResponseSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _makeGetRequest,
                  icon: const Icon(Icons.download),
                  label: const Text('GET Request'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _makePostRequest,
                  icon: const Icon(Icons.upload),
                  label: const Text('POST Request'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _makePutRequest,
                  icon: const Icon(Icons.edit),
                  label: const Text('PUT Request'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _makeDeleteRequest,
                  icon: const Icon(Icons.delete),
                  label: const Text('DELETE Request'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _makeErrorRequest,
                  icon: const Icon(Icons.error),
                  label: const Text('Error Request'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _makeSlowRequest,
                  icon: const Icon(Icons.timer),
                  label: const Text('Slow Request'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseSection() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Last Response',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (_lastResponse.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _lastResponse = ''),
                      tooltip: 'Clear Response',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : _lastResponse.isEmpty
                      ? Center(
                    child: Text(
                      'Make an API request to see the response here',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .outline,
                      ),
                    ),
                  )
                      : SingleChildScrollView(
                    child: SelectableText(
                      _lastResponse,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makeGetRequest() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/posts/1');
      setState(() {
        _lastResponse = _formatResponse(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makePostRequest() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.post(
        '/posts',
        data: {
          'title': 'Network Ninja Test Post',
          'body': 'This is a test post from Network Ninja example app',
          'userId': 1,
        },
      );
      setState(() {
        _lastResponse = _formatResponse(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makePutRequest() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.put(
        '/posts/1',
        data: {
          'id': 1,
          'title': 'Updated Network Ninja Test Post',
          'body': 'This post was updated by Network Ninja example app',
          'userId': 1,
        },
      );
      setState(() {
        _lastResponse = _formatResponse(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makeDeleteRequest() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.delete('/posts/1');
      setState(() {
        _lastResponse = _formatResponse(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makeErrorRequest() async {
    setState(() => _isLoading = true);
    try {
      await _dio.get('/nonexistent-endpoint');
    } catch (e) {
      setState(() {
        _lastResponse = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makeSlowRequest() async {
    setState(() => _isLoading = true);
    try {
      // Simulate a slow request
      await Future.delayed(const Duration(seconds: 2));
      final response = await _dio.get('/posts/2');
      setState(() {
        _lastResponse = _formatResponse(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResponse = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatResponse(Response response) {
    return '''
Status: ${response.statusCode}
Headers: ${response.headers.map}
Data: ${response.data}
''';
  }
}
