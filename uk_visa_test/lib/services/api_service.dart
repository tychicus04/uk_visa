import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../data/models/Chapter.dart';
import '../data/models/Subscription.dart';
import '../data/models/SubscriptionPlan.dart';
import '../data/models/TestAttempt.dart';
import '../data/models/TestResult.dart';
import '../data/models/User.dart';
import '../data/models/Test.dart';
import '../data/requests/ChangePasswordRequest.dart';
import '../data/requests/LoginRequest.dart';
import '../data/requests/RegisterRequest.dart';
import '../data/requests/StartAttemptRequest.dart';
import '../data/requests/SubmitAttemptRequest.dart';
import '../data/requests/SubscribeRequest.dart';
import '../data/requests/UpdateProfileRequest.dart';
import '../data/responses/AuthResponse.dart';
import '../exceptions/ApiExceptions.dart';
import '../exceptions/ForbiddenException.dart';
import '../exceptions/NotFoundException.dart';
import '../exceptions/ServerException.dart';
import '../exceptions/UnauthorizedException.dart';
import '../exceptions/ValidationException.dart';
import '../utils/secure_storage.dart';
import '../utils/logger.dart';

class ApiService {
  static const String _baseUrl = AppConstants.baseUrl;
  static String? _token;

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Initialize with stored token
  static Future<void> initialize() async {
    _token = await SecureStorage.getToken();
    Logger.info('API Service initialized with token: ${_token != null}');
  }

  // Set authentication token
  static void setToken(String? token) {
    _token = token;
    Logger.info('Token updated: ${token != null}');
  }

  // Clear authentication token
  static void clearToken() {
    _token = null;
    SecureStorage.clearToken();
    Logger.info('Token cleared');
  }

  // Generic request handler
  static Future<Map<String, dynamic>> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      String url = '$_baseUrl$endpoint';

      // Add query parameters
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParams).toString();
      }

      Logger.info('API Request: $method $url');
      if (body != null) Logger.debug('Request body: ${jsonEncode(body)}');

      http.Response response;
      final uri = Uri.parse(url);

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers)
              .timeout(AppConstants.requestTimeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(AppConstants.requestTimeout);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(AppConstants.requestTimeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers)
              .timeout(AppConstants.requestTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      Logger.info('API Response: ${response.statusCode}');
      Logger.debug('Response body: ${response.body}');

      return _handleResponse(response);

    } on SocketException {
      Logger.error('Network error: No internet connection');
      throw ApiException('No internet connection');
    } on HttpException {
      Logger.error('HTTP error occurred');
      throw ApiException('Failed to connect to server');
    } on FormatException {
      Logger.error('Invalid response format');
      throw ApiException('Invalid server response');
    } catch (e) {
      Logger.error('API request failed: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body);
    } catch (e) {
      throw ApiException('Invalid JSON response');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return data;
      case 400:
        throw ApiException(data['message'] ?? 'Bad request');
      case 401:
      // Token expired or invalid
        clearToken();
        throw UnauthorizedException(data['message'] ?? 'Unauthorized');
      case 403:
        throw ForbiddenException(data['message'] ?? 'Forbidden');
      case 404:
        throw NotFoundException(data['message'] ?? 'Not found');
      case 422:
        throw ValidationException(
          data['message'] ?? 'Validation error',
          data['errors'] ?? {},
        );
      case 500:
        throw ServerException(data['message'] ?? 'Internal server error');
      default:
        throw ApiException('Request failed with status: ${response.statusCode}');
    }
  }

  // ==========================================================================
  // AUTHENTICATION ENDPOINTS
  // ==========================================================================

  static Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _request(
      method: 'POST',
      endpoint: ApiEndpoints.register,
      body: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response);
    if (authResponse.token != null) {
      setToken(authResponse.token);
      await SecureStorage.saveToken(authResponse.token!);
      if (authResponse.user != null) {
        await SecureStorage.saveUser(authResponse.user!);
      }
    }

    return authResponse;
  }

  static Future<AuthResponse> login(LoginRequest request) async {
    final response = await _request(
      method: 'POST',
      endpoint: ApiEndpoints.login,
      body: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response);
    if (authResponse.token != null) {
      setToken(authResponse.token);
      await SecureStorage.saveToken(authResponse.token!);
      if (authResponse.user != null) {
        await SecureStorage.saveUser(authResponse.user!);
      }
    }

    return authResponse;
  }

  static Future<User> getProfile() async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.profile,
    );

    return User.fromJson(response['data']['profile']);
  }

  static Future<User> updateProfile(UpdateProfileRequest request) async {
    final response = await _request(
      method: 'PUT',
      endpoint: ApiEndpoints.profile,
      body: request.toJson(),
    );

    final user = User.fromJson(response['data']);
    await SecureStorage.saveUser(user);
    return user;
  }

  static Future<void> changePassword(ChangePasswordRequest request) async {
    await _request(
      method: 'POST',
      endpoint: ApiEndpoints.changePassword,
      body: request.toJson(),
    );
  }

  static Future<void> logout() async {
    try {
      await _request(
        method: 'POST',
        endpoint: ApiEndpoints.logout,
      );
    } catch (e) {
      Logger.warning('Logout request failed: $e');
    } finally {
      clearToken();
      await SecureStorage.clear();
    }
  }

  // ==========================================================================
  // TEST ENDPOINTS
  // ==========================================================================

  static Future<Map<String, List<Test>>> getAvailableTests() async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.availableTests,
    );

    final data = response['data'] as Map<String, dynamic>;
    final result = <String, List<Test>>{};

    data.forEach((key, value) {
      if (value is List) {
        result[key] = value.map((test) => Test.fromJson(test)).toList();
      }
    });

    return result;
  }

  static Future<List<Test>> getFreeTests() async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.freeTests,
    );

    final data = response['data'] as List;
    return data.map((test) => Test.fromJson(test)).toList();
  }

  static Future<Test> getTest(int testId) async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.testById(testId),
    );

    return Test.fromJson(response['data']);
  }

  static Future<List<Test>> searchTests(String query) async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.searchTests,
      queryParams: {'q': query},
    );

    final data = response['data'] as List;
    return data.map((test) => Test.fromJson(test)).toList();
  }

  static Future<List<Test>> getTestsByType(String type) async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.testsByType(type),
    );

    final data = response['data'] as List;
    return data.map((test) => Test.fromJson(test)).toList();
  }

  static Future<List<Test>> getTestsByChapter(int chapterId) async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.testsByChapter(chapterId),
    );

    final data = response['data'] as List;
    return data.map((test) => Test.fromJson(test)).toList();
  }

  // ==========================================================================
  // TEST ATTEMPT ENDPOINTS
  // ==========================================================================

  static Future<TestAttempt> startAttempt(StartAttemptRequest request) async {
    final response = await _request(
      method: 'POST',
      endpoint: ApiEndpoints.startAttempt,
      body: request.toJson(),
    );

    return TestAttempt.fromJson(response['data']);
  }

  static Future<TestResult> submitAttempt(SubmitAttemptRequest request) async {
    final response = await _request(
      method: 'POST',
      endpoint: ApiEndpoints.submitAttempt,
      body: request.toJson(),
    );

    return TestResult.fromJson(response['data']);
  }

  static Future<List<TestAttempt>> getAttemptHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.attemptHistory,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final items = response['data']['items'] as List;
    return items.map((attempt) => TestAttempt.fromJson(attempt)).toList();
  }

  static Future<TestAttempt> getAttemptDetails(int attemptId) async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.attemptDetails(attemptId),
    );

    return TestAttempt.fromJson(response['data']);
  }

  // ==========================================================================
  // CHAPTER ENDPOINTS
  // ==========================================================================

  static Future<List<Chapter>> getChapters() async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.chapters,
    );

    final data = response['data'] as List;
    return data.map((chapter) => Chapter.fromJson(chapter)).toList();
  }

  static Future<Chapter> getChapter(int chapterId) async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.chapterById(chapterId),
    );

    return Chapter.fromJson(response['data']);
  }

  // ==========================================================================
  // SUBSCRIPTION ENDPOINTS
  // ==========================================================================

  static Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final response = await _request(
      method: 'GET',
      endpoint: ApiEndpoints.subscriptionPlans,
    );

    final data = response['data'] as List;
    return data.map((plan) => SubscriptionPlan.fromJson(plan)).toList();
  }

  static Future<Subscription> subscribe(SubscribeRequest request) async {
    final response = await _request(
      method: 'POST',
      endpoint: ApiEndpoints.subscribe,
      body: request.toJson(),
    );

    return Subscription.fromJson(response['data']);
  }

  static Future<Subscription?> getSubscriptionStatus() async {
    try {
      final response = await _request(
        method: 'GET',
        endpoint: ApiEndpoints.subscriptionStatus,
      );

      return Subscription.fromJson(response['data']);
    } on NotFoundException {
      return null; // No active subscription
    }
  }

  // ==========================================================================
  // SYSTEM ENDPOINTS
  // ==========================================================================

  static Future<Map<String, dynamic>> healthCheck() async {
    return await _request(
      method: 'GET',
      endpoint: ApiEndpoints.health,
    );
  }

  static Future<Map<String, dynamic>> testConnection() async {
    return await _request(
      method: 'GET',
      endpoint: ApiEndpoints.test,
    );
  }
}
