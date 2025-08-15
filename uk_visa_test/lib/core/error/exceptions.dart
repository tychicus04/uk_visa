class ServerException implements Exception {

  const ServerException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Code: $statusCode)' : ''}';
}

class NetworkException implements Exception {

  const NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {

  const AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {

  const ValidationException(this.message, [this.errors]);
  final String message;
  final Map<String, List<String>>? errors;

  @override
  String toString() => 'ValidationException: $message';
}

class CacheException implements Exception {

  const CacheException(this.message);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}
