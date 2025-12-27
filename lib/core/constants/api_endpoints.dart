/// Central place to document HTTP endpoints used by the application.
///
/// Even though the prototype uses in-memory data sources, keeping the
/// definition of API endpoints isolated makes it trivial to swap in real
/// network clients later on.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.redemton.com';
  static const String auth = '$baseUrl/auth';
  static const String events = '$baseUrl/events';
  static const String social = '$baseUrl/social';
  static const String messaging = '$baseUrl/messaging';
  static const String notifications = '$baseUrl/notifications';
  static const String scroll = '$baseUrl/scroll';
}
