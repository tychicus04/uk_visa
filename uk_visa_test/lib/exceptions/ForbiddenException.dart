import 'ApiExceptions.dart';

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 'forbidden');
}