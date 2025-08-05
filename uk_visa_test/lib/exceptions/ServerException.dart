import 'ApiExceptions.dart';

class ServerException extends ApiException {
  ServerException(String message) : super(message, 'server_error');
}