import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_checker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/api_test_helper.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/test_repository.dart';
import '../../../data/repositories/chapter_repository.dart';

class ApiTestScreen extends ConsumerStatefulWidget {
  const ApiTestScreen({super.key});

  @override
  ConsumerState<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends ConsumerState<ApiTestScreen> {
  final _scrollController = ScrollController();
  List<String> _logs = [];
  bool _isRunningTests = false;

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
      });
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _logs.clear();
              });
            },
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration Info
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backend Configuration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('URL: ${ApiConstants.baseUrl}'),
                Text('Timeout: ${ApiConstants.timeout.inSeconds}s'),
              ],
            ),
          ),

          // Test Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunningTests ? null : _testBasicConnection,
                  icon: const Icon(Icons.wifi),
                  label: const Text('Basic Connection'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunningTests ? null : _testEndpoints,
                  icon: const Icon(Icons.api),
                  label: const Text('Test Endpoints'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunningTests ? null : _testRepositories,
                  icon: const Icon(Icons.storage),
                  label: const Text('Test Repositories'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunningTests ? null : _runFullTest,
                  icon: const Icon(Icons.science),
                  label: const Text('Full Test Suite'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Test Logs',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isRunningTests)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  Expanded(
                    child: _logs.isEmpty
                        ? const Center(
                      child: Text(
                        'No logs yet. Run a test to see results.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      controller: _scrollController,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color textColor = Colors.white;
                        if (log.contains('✅')) {
                          textColor = Colors.green;
                        } else if (log.contains('❌')) {
                          textColor = Colors.red;
                        } else if (log.contains('⚠️')) {
                          textColor = Colors.orange;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testBasicConnection() async {
    setState(() => _isRunningTests = true);
    _addLog('🧪 Testing basic connection...');

    try {
      final result = await NetworkChecker.checkBackendConnection();
      _addLog(result ? '✅ Backend connection successful' : '❌ Backend connection failed');
    } catch (e) {
      _addLog('❌ Connection error: $e');
    }

    setState(() => _isRunningTests = false);
  }

  Future<void> _testEndpoints() async {
    setState(() => _isRunningTests = true);
    _addLog('🧪 Testing API endpoints...');

    final endpoints = ['/health', '/test', '/chapters'];

    for (final endpoint in endpoints) {
      try {
        final result = await NetworkChecker.testAPIEndpoint(endpoint);
        _addLog(result != null ? '✅ $endpoint working' : '❌ $endpoint failed');
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        _addLog('❌ $endpoint error: $e');
      }
    }

    setState(() => _isRunningTests = false);
  }

  Future<void> _testRepositories() async {
    setState(() => _isRunningTests = true);
    _addLog('🧪 Testing repositories...');

    try {
      // Test Chapter Repository
      _addLog('Testing chapters repository...');
      final chapterRepo = ref.read(chapterRepositoryProvider);
      final chapters = await chapterRepo.getAllChapters();
      _addLog('✅ Chapters loaded: ${chapters.length} chapters');

      // Test Test Repository
      _addLog('Testing test repository...');
      final testRepo = ref.read(testRepositoryProvider);
      final freeTests = await testRepo.getFreeTests();
      _addLog('✅ Free tests loaded: ${freeTests.length} tests');

    } catch (e) {
      _addLog('❌ Repository test failed: $e');
    }

    setState(() => _isRunningTests = false);
  }

  Future<void> _runFullTest() async {
    setState(() => _isRunningTests = true);

    _addLog('🧪 Running full test suite...');
    _addLog('═══════════════════════════════');

    await _testBasicConnection();
    await Future.delayed(const Duration(milliseconds: 500));

    await _testEndpoints();
    await Future.delayed(const Duration(milliseconds: 500));

    await _testRepositories();

    _addLog('═══════════════════════════════');
    _addLog('🏁 Full test suite completed');

    setState(() => _isRunningTests = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}