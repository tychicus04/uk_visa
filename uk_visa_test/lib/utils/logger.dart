import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'UKVisaTest';

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 500, // Debug level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 800, // Info level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 1200, // WTF level
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Structured logging for API calls
  static void apiRequest(String method, String url, {Map<String, dynamic>? body}) {
    debug('API $method: $url${body != null ? ' Body: $body' : ''}');
  }

  static void apiResponse(String method, String url, int statusCode, {String? body}) {
    debug('API $method Response: $url [$statusCode]${body != null ? ' Body: $body' : ''}');
  }

  static void apiError(String method, String url, dynamic error) {
    Logger.error('API $method Error: $url', error);
  }

  // User actions logging
  static void userAction(String action, {Map<String, dynamic>? data}) {
    info('User Action: $action${data != null ? ' Data: $data' : ''}');
  }

  // Performance logging
  static void performance(String operation, Duration duration) {
    info('Performance: $operation took ${duration.inMilliseconds}ms');
  }

  // Navigation logging
  static void navigation(String from, String to) {
    debug('Navigation: $from -> $to');
  }
}