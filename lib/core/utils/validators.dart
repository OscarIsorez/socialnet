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
}
