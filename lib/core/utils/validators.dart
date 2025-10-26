import '../constants/app_constants.dart';

/// Common validation helpers used throughout forms in the application.
class Validators {
  Validators._();

  static bool isValidEmail(String value) {
    final emailRegex = RegExp(r'^.+@.+\..+$');
    return emailRegex.hasMatch(value.trim());
  }

  static bool isValidPassword(String value) {
    return value.trim().length >= AppConstants.passwordMinLength;
  }

  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  static String? requireField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(value)) {
      return 'Password must be at least '
          '${AppConstants.passwordMinLength} characters';
    }
    return null;
  }
}
