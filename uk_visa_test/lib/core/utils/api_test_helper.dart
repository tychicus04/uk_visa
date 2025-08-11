// lib/core/utils/api_test_helper.dart
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiTestHelper {
  static void printApiConfiguration() {
    print('🔧 API Configuration:');
    print('   Base URL: ${ApiConstants.baseUrl}');
    print('   Timeout: ${ApiConstants.timeout}');
    print('   Headers: ${ApiConstants.headers}');
    print('');
  }

  static Future<void> runConnectionTests() async {
    print('🧪 Running API Connection Tests...');

    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      headers: ApiConstants.headers,
    );

    // Test 1: Health check
    await _testEndpoint(dio, 'Health Check', '/health');

    // Test 2: Basic API info
    await _testEndpoint(dio, 'API Info', '/');

    // Test 3: Test endpoint
    await _testEndpoint(dio, 'Test Endpoint', '/test');

    print('✅ API Connection Tests Complete');
    print('');
  }

  static Future<void> _testEndpoint(Dio dio, String testName, String endpoint) async {
    try {
      print('🔄 Testing $testName ($endpoint)...');

      final stopwatch = Stopwatch()..start();
      final response = await dio.get(endpoint);
      stopwatch.stop();

      print('   ✅ Success: ${response.statusCode}');
      print('   ⏱️ Time: ${stopwatch.elapsedMilliseconds}ms');

      if (response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('status')) {
            print('   📊 Status: ${data['status']}');
          }
          if (data.containsKey('message')) {
            print('   💬 Message: ${data['message']}');
          }
          if (data.containsKey('name')) {
            print('   📛 API Name: ${data['name']}');
          }
          if (data.containsKey('version')) {
            print('   🔢 Version: ${data['version']}');
          }
        }
      }

    } catch (e) {
      print('   ❌ Failed: $e');
      if (e is DioException) {
        print('   🔍 Type: ${e.type}');
        print('   📝 Response: ${e.response?.data}');
        print('   🔢 Status Code: ${e.response?.statusCode}');
      }
    }
    print('');
  }

  static Future<void> testAuthFlow({
    required String email,
    required String password,
  }) async {
    print('🔐 Testing Auth Flow...');

    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      headers: ApiConstants.headers,
    );

    try {
      // Test login
      print('🔄 Testing login...');
      final loginResponse = await dio.post(
        ApiConstants.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('   ✅ Login Success: ${loginResponse.statusCode}');

      if (loginResponse.data != null && loginResponse.data['success'] == true) {
        final token = loginResponse.data['data']['token'];
        print('   🎫 Token received: ${token.substring(0, 20)}...');

        // Test authenticated request
        dio.options.headers['Authorization'] = 'Bearer $token';

        print('🔄 Testing authenticated request...');
        final profileResponse = await dio.get(ApiConstants.authProfile);

        print('   ✅ Profile Success: ${profileResponse.statusCode}');

        if (profileResponse.data != null && profileResponse.data['success'] == true) {
          final user = profileResponse.data['data']['profile'];
          print('   👤 User: ${user['email']}');
          print('   🏆 Premium: ${user['is_premium']}');
        }
      }

    } catch (e) {
      print('   ❌ Auth Flow Failed: $e');
      if (e is DioException) {
        print('   🔍 Type: ${e.type}');
        print('   📝 Response: ${e.response?.data}');
      }
    }

    print('✅ Auth Flow Test Complete');
    print('');
  }
}