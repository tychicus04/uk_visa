import 'ApiExceptions.dart';

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 'not_found');
}