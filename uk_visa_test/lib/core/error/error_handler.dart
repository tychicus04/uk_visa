class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    final String errorString = error.toString();

    // Remove "Exception: " prefix if present
    String cleanError = errorString.replaceAll('Exception: ', '');

    // Handle common API errors
    if (cleanError.contains('Invalid email or password')) {
      return 'Invalid email or password. Please check your credentials.';
    }

    if (cleanError.contains('Network error')) {
      return 'Network error. Please check your internet connection.';
    }

    if (cleanError.contains('Connection timeout')) {
      return 'Connection timeout. Please try again.';
    }

    if (cleanError.contains('Server error')) {
      return 'Server error. Please try again later.';
    }

    if (cleanError.contains('Email already exists')) {
      return 'This email is already registered. Please use a different email or try logging in.';
    }

    if (cleanError.contains('Validation failed')) {
      return 'Please check your input and try again.';
    }

    // Return cleaned error message
    return cleanError.isNotEmpty ? cleanError : 'An unexpected error occurred. Please try again.';
  }

  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    print('🚨 ERROR in $context:');
    print('   Message: $error');
    if (stackTrace != null) {
      print('   Stack trace: $stackTrace');
    }
  }
}