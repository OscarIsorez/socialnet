import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardSlide> _slides = const [
    _OnboardSlide(
      title: 'Discover Local Events',
      description:
          'Find and join events happening near you. Explore by category and date.',
      icon: Icons.location_on,
    ),
    _OnboardSlide(
      title: 'Plan & Coordinate',
      description:
          'Create events, invite friends and keep everything in one place.',
      icon: Icons.event,
    ),
    _OnboardSlide(
      title: 'Connect with People',
      description:
          'Meet nearby people with similar interests and grow your local network.',
      icon: Icons.people,
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.signup);
  }

  Future<void> _skipToSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        elevation: 0,
        leading: TextButton(
          onPressed: _skipToSignIn,
          child: Text(
            'Skip',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              'Sign Up',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          slide.icon,
                          size: 96,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator and actions
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _index == i ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _index == i
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_index == _slides.length - 1)
                    TextButton(
                      onPressed: _skipToSignIn,
                      child: const Text('Sign In'),
                    ),
                  TextButton(
                    onPressed: () {
                      if (_index < _slides.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _index < _slides.length - 1 ? 'Next' : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide {
  final String title;
  final String description;
  final IconData icon;
  const _OnboardSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Widget Preview for OnboardingPage
@Preview(name: 'Onboarding Page - Light Mode')
@Preview(name: 'Onboarding Page - Dark Mode', brightness: Brightness.dark)
Widget onboardingPagePreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    home: const OnboardingPage(),
    debugShowCheckedModeBanner: false,
  );
}
