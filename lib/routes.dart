import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/checkin/checkin_start_screen.dart';
import 'screens/checkin/checkin_detail_screen.dart';

import 'screens/app_shell.dart';
import 'screens/home_body.dart';
import 'screens/calendar_body.dart';

import 'models/mood.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const checkinStart = '/checkin/start';
  static const checkinDetail = '/checkin/detail';
  static const shell = '/app';
  static const home = '/app/home';
  static const calendar = '/app/calendar';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.welcome, builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),

      GoRoute(path: AppRoutes.checkinStart, builder: (_, state) {
        final date = (state.extra as Map?)?['date'] as DateTime? ?? DateTime.now();
        return CheckInStartScreen(date: date);
      }),
      GoRoute(path: AppRoutes.checkinDetail, builder: (_, state) {
        final m = state.extra as Map?;
        return CheckInDetailScreen(
          date: (m?['date'] as DateTime?) ?? DateTime.now(),
          mood: (m?['mood'] as Mood?) ?? Mood.neutral,
        );
      }),

      // —— Shared shell (persistent header & bottom bar)
      ShellRoute(
        builder: (context, state, child) {
          // detect current location; go_router ^14 provides state.uri
          final loc = state.uri.toString();
          final isCalendar = loc.startsWith(AppRoutes.calendar);
          return AppShell(
            child: child,
            hideDateHeader: isCalendar, // hide on Calendar
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, state) {
              final d = (state.extra as Map?)?['date'] as DateTime?;
              return NoTransitionPage(child: HomeBody(initialDate: d));
            },
          ),
          GoRoute(
            path: AppRoutes.calendar,
            pageBuilder: (_, state) {
              final m = (state.extra as Map?)?['initialMonth'] as DateTime?;
              return NoTransitionPage(child: CalendarBody(initialMonth: m));
            },
          ),
        ],
      ),
    ],
  );
}
