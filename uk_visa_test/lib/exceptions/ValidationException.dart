import 'ApiExceptions.dart';

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;

  ValidationException(String message, this.errors) : super(message, 'validation');
}