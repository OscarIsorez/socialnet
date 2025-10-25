/// Application-wide constants that do not justify their own configuration
/// class. These values help keep magic numbers and string literals out of the
/// core business logic.
class AppConstants {
  AppConstants._();

  static const String appName = 'Redemton';
  static const String googleMapsApiEnvKey = 'GOOGLE_MAPS_API_KEY';
  static const String defaultLocale = 'en_US';
  static const int passwordMinLength = 6;
  static const int eventDescriptionMaxLength = 200;
}
