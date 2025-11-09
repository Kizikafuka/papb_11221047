// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _langs = const ['Indonesia', 'English'];
  String _selected = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Nurture Your Mind,\nOne Emoji at a Time',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'Capture your moods and experiences through the language of emojis without any writing. '
                'Uncover patterns, delve into your feelings, and appreciate every moment, big or small.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 24),

              // Language selector (Dropdown)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Language',
                  border: UnderlineInputBorder(),
                  prefixIcon: Icon(Icons.public),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selected,
                    isExpanded: true,
                    items: _langs
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selected = v!),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Illustration
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/welcome.png',
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // CTA button
              PrimaryButton(
                text: "Let's Begin",
                onPressed: () => context.go(AppRoutes.onboarding),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
