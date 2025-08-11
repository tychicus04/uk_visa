// lib/core/network/network_checker.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class NetworkChecker {
  static final Dio _dio = Dio();

  /// Check if backend is reachable and healthy
  static Future<bool> checkBackendConnection() async {
    try {
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);

      if (kDebugMode) {
        print('🔍 Checking backend connection to: ${ApiConstants.baseUrl}');
      }

      final response = await _dio.get('${ApiConstants.baseUrl}/health');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final isHealthy = data['status'] == 'healthy';
          final isDatabaseConnected = data['database'] == 'connected';

          if (kDebugMode) {
            print('✅ Backend connection successful');
            print('📊 Backend info:');
            print('   - Status: ${data['status']}');
            print('   - Database: ${data['database']}');
            print('   - API Version: ${data['api_version']}');
            print('   - Server Time: ${data['server_time']}');
          }

          return isHealthy && isDatabaseConnected;
        }
      }

      if (kDebugMode) {
        print('❌ Backend connection failed: Invalid response format');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Backend connection failed: $e');
        print('🔧 Troubleshooting:');
        print('   1. Check your API URL: ${ApiConstants.baseUrl}');
        print('   2. Make sure your backend server is running');
        print('   3. Verify XAMPP Apache is started');
        print('   4. Check if /health endpoint is accessible');

        if (e is DioException) {
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
              print('   - Connection timeout - server may be down');
              break;
            case DioExceptionType.connectionError:
              print('   - Connection error - check network/URL');
              break;
            case DioExceptionType.receiveTimeout:
              print('   - Receive timeout - server responding slowly');
              break;
            default:
              print('   - Error type: ${e.type}');
          }
        }
      }
      return false;
    }
  }

  /// Test a specific API endpoint
  static Future<Map<String, dynamic>?> testAPIEndpoint(String endpoint) async {
    try {
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);

      final url = '${ApiConstants.baseUrl}$endpoint';

      if (kDebugMode) {
        print('🔍 Testing endpoint: $url');
      }

      final response = await _dio.get(url);

      if (kDebugMode) {
        print('✅ Endpoint $endpoint: HTTP ${response.statusCode}');
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          print('📊 Response preview: ${data.keys.take(5).join(', ')}');
        }
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Endpoint $endpoint failed: $e');

        if (e is DioException && e.response != null) {
          print('   - HTTP Status: ${e.response!.statusCode}');
          print('   - Response: ${e.response!.data}');
        }
      }
      return null;
    }
  }

  /// Test API endpoint with authentication
  static Future<Map<String, dynamic>?> testAuthenticatedEndpoint(
      String endpoint,
      String token,
      ) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] = 'application/json';

      final url = '${ApiConstants.baseUrl}$endpoint';

      if (kDebugMode) {
        print('🔍 Testing authenticated endpoint: $url');
      }

      final response = await dio.get(url);

      if (kDebugMode) {
        print('✅ Auth endpoint $endpoint: HTTP ${response.statusCode}');
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth endpoint $endpoint failed: $e');
      }
      return null;
    }
  }

  /// Test authentication flow
  static Future<Map<String, dynamic>?> testAuthentication({
    required String email,
    required String password,
  }) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);

      if (kDebugMode) {
        print('🔍 Testing authentication with email: $email');
      }

      final response = await dio.post(
        '${ApiConstants.baseUrl}/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (kDebugMode) {
        print('✅ Authentication test: HTTP ${response.statusCode}');
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['success'] == true) {
            print('   - Login successful');
            print('   - Token received: ${data['data']?['token']?.toString().substring(0, 20)}...');
          }
        }
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Authentication test failed: $e');

        if (e is DioException && e.response != null) {
          print('   - HTTP Status: ${e.response!.statusCode}');
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            print('   - Error message: ${responseData['message']}');
          }
        }
      }
      return null;
    }
  }

  /// Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      // Test with a reliable service
      final response = await dio.get('https://www.google.com');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ No internet connection: $e');
      }
      return false;
    }
  }

  /// Comprehensive network diagnostic
  static Future<NetworkDiagnosticResult> runNetworkDiagnostic() async {
    final result = NetworkDiagnosticResult();

    if (kDebugMode) {
      print('🔍 Running comprehensive network diagnostic...');
    }

    // Test 1: Internet connectivity
    result.hasInternet = await hasInternetConnection();
    if (kDebugMode) {
      print('1. Internet: ${result.hasInternet ? "✅" : "❌"}');
    }

    // Test 2: Backend health
    result.backendHealthy = await checkBackendConnection();
    if (kDebugMode) {
      print('2. Backend Health: ${result.backendHealthy ? "✅" : "❌"}');
    }

    // Test 3: Critical endpoints
    final criticalEndpoints = ['/health', '/test', '/chapters'];
    for (final endpoint in criticalEndpoints) {
      final endpointResult = await testAPIEndpoint(endpoint);
      result.endpointResults[endpoint] = endpointResult != null;
      if (kDebugMode) {
        print('3. Endpoint $endpoint: ${endpointResult != null ? "✅" : "❌"}');
      }
    }

    // Test 4: Measure response time
    final stopwatch = Stopwatch()..start();
    await testAPIEndpoint('/health');
    stopwatch.stop();
    result.responseTimeMs = stopwatch.elapsedMilliseconds;

    if (kDebugMode) {
      print('4. Response Time: ${result.responseTimeMs}ms');
      print('🔍 Network diagnostic complete');
    }

    return result;
  }

  /// Get network status summary
  static Future<String> getNetworkStatusSummary() async {
    final diagnostic = await runNetworkDiagnostic();

    if (!diagnostic.hasInternet) {
      return 'No internet connection';
    }

    if (!diagnostic.backendHealthy) {
      return 'Backend server is unreachable';
    }

    final failedEndpoints = diagnostic.endpointResults.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    if (failedEndpoints.isNotEmpty) {
      return 'Some endpoints are failing: ${failedEndpoints.join(", ")}';
    }

    if (diagnostic.responseTimeMs > 5000) {
      return 'Network is slow (${diagnostic.responseTimeMs}ms)';
    }

    return 'All systems operational';
  }
}

/// Network diagnostic result model
class NetworkDiagnosticResult {
  bool hasInternet = false;
  bool backendHealthy = false;
  Map<String, bool> endpointResults = {};
  int responseTimeMs = 0;

  bool get isHealthy => hasInternet && backendHealthy &&
      endpointResults.values.every((result) => result);

  double get healthScore {
    int total = 2; // internet + backend
    int passed = 0;

    if (hasInternet) passed++;
    if (backendHealthy) passed++;

    total += endpointResults.length;
    passed += endpointResults.values.where((result) => result).length;

    return passed / total;
  }
}