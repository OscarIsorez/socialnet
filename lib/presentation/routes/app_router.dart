import 'package:flutter/material.dart';

import '../../domain/entities/event.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/event/create_event_page.dart';
import '../pages/event/event_detail_page.dart';
import '../pages/main/main_page.dart';
import '../pages/messaging/chat_page.dart';
import '../pages/notifications/notifications_page.dart';
import '../pages/profile/edit_profile_page.dart';
import '../pages/settings/interests_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/splash/splash_page.dart';
import '../pages/onboarding/onboarding_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String createEvent = '/create-event';
  static const String eventDetail = '/event-detail';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String interests = '/interests';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case main:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case createEvent:
        return MaterialPageRoute(builder: (_) => const CreateEventPage());
      case eventDetail:
        final event = routeSettings.arguments;
        return MaterialPageRoute(
          builder: (_) => EventDetailPage(event: event is Event ? event : null),
        );
      case chat:
        final userId = routeSettings.arguments;
        return MaterialPageRoute(
          builder: (_) =>
              ChatPage(userId: userId is String ? userId : 'unknown'),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case interests:
        return MaterialPageRoute(builder: (_) => const InterestsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page not found')),
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
