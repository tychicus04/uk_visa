import 'ApiExceptions.dart' show ApiException;

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 'unauthorized');
}