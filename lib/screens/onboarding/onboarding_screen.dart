// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Track Your Daily Moods",
      "desc": "Easily log your emotions and activities every day.",
      "img": "assets/images/welcome.png"
    },
    {
      "title": "Gain Valuable Insights",
      "desc": "See weekly mood charts and track your progress.",
      "img": "assets/images/welcome.png"
    },
    {
      "title": "Keep Calm and Motivated",
      "desc": "Breathing technique and quotes for you.",
      "img": "assets/images/welcome.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (ctx, i) {
                final page = _pages[i];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(page["img"]!, height: 250),
                      const SizedBox(height: 30),
                      Text(
                        page["title"]!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page["desc"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
                  (i) => Container(
                margin: const EdgeInsets.all(4),
                width: _index == i ? 12 : 8,
                height: _index == i ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _index == i ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_index == _pages.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: PrimaryButton(
                text: "Let's Get Started",
                onPressed: () => context.go(AppRoutes.checkinStart),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextButton(
                child: const Text("Skip"),
                onPressed: () => context.go(AppRoutes.checkinStart),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
