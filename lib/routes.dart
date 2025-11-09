import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/checkin/checkin_start_screen.dart';
import 'screens/checkin/checkin_detail_screen.dart';
import 'screens/breathing/breathing_list_screen.dart';
import 'screens/breathing/breathing_session_screen.dart';

import 'screens/app_shell.dart';
import 'screens/home_body.dart';
import 'screens/calendar_body.dart';

import 'models/mood.dart';
import 'models/breathing_exercise.dart';

// KUMPULAN PATH statis
class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const checkinStart = '/checkin/start';
  static const checkinDetail = '/checkin/detail';
  static const breathingList = '/breathing'; // Breathing exercise list
  static const breathingSession =
      '/breathing/session'; // Active breathing session
  static const shell = '/app';
  static const home = '/app/home';
  static const calendar = '/app/calendar';
}

// Factory router utama aplikasi
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash, // pertama kali ke splash
    routes: [
      // ——— ROUTE HALAMAN LEPAS (di luar shell) ———
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Check-in step 1: pilih mood
      GoRoute(
        path: AppRoutes.checkinStart,
        builder: (_, state) {
          // Ambil DateTime dari state.extra (opsional), default: now
          final date =
              (state.extra as Map?)?['date'] as DateTime? ?? DateTime.now();
          return CheckInStartScreen(date: date);
        },
      ),

      // Check-in step 2: isi detail (tags/note)
      GoRoute(
        path: AppRoutes.checkinDetail,
        builder: (_, state) {
          // Ambil date+mood dari extra (opsional), kasih default aman
          final m = state.extra as Map?;
          return CheckInDetailScreen(
            date: (m?['date'] as DateTime?) ?? DateTime.now(),
            mood: (m?['mood'] as Mood?) ?? Mood.neutral,
          );
        },
      ),

      // Breathing exercises list
      GoRoute(
        path: AppRoutes.breathingList,
        builder: (_, __) => const BreathingListScreen(),
      ),

      // Breathing exercise session (active breathing)
      GoRoute(
        path: AppRoutes.breathingSession,
        builder: (_, state) {
          // Get the breathing exercise from extra
          final exercise = state.extra as BreathingExercise?;
          if (exercise == null) {
            // Fallback to a default exercise if none provided
            return BreathingSessionScreen(
              exercise: BreathingExercises.relaxation,
            );
          }
          return BreathingSessionScreen(exercise: exercise);
        },
      ),

      // ——— ROUTE DENGAN SHELL PERSISTEN (AppShell) ———
      // ShellRoute: punya AppBar (tanggal) + FAB + BottomAppBar
      ShellRoute(
        builder: (context, state, child) {
          // Deteksi lokasi saat ini (go_router ^14 → state.uri)
          final loc = state.uri.toString();
          final isCalendar = loc.startsWith(AppRoutes.calendar);

          return AppShell(
            child: child,
            hideDateHeader:
                isCalendar, // di Calendar, sembunyikan header tanggal
          );
        },
        routes: [
          // HOME di dalam shell
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, state) {
              // Kirim initialDate ke HomeBody (opsional)
              final d = (state.extra as Map?)?['date'] as DateTime?;
              // NoTransitionPage: pindah halaman tanpa animasi (halus di dalam shell)
              return NoTransitionPage(child: HomeBody(initialDate: d));
            },
          ),

          // CALENDAR di dalam shell
          GoRoute(
            path: AppRoutes.calendar,
            pageBuilder: (_, state) {
              // Kirim initialMonth ke CalendarBody (opsional)
              final m = (state.extra as Map?)?['initialMonth'] as DateTime?;
              return NoTransitionPage(child: CalendarBody(initialMonth: m));
            },
          ),
        ],
      ),
    ],
  );
}
