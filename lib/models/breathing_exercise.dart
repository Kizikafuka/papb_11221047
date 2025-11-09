import 'package:flutter/material.dart';

/// Different breathing exercise types for various situations
enum BreathingType {
  anxiety, // Calming breath for anxiety relief
  focus, // Box breathing for improved focus
  relaxation, // Deep breathing for general relaxation
  sleep, // Slow breathing to prepare for sleep
  energy, // Energizing breath technique
}

/// Model for breathing exercise configuration
class BreathingExercise {
  const BreathingExercise({
    required this.type,
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdInSeconds,
    required this.exhaleSeconds,
    required this.holdOutSeconds,
    required this.cycles,
    required this.icon,
    required this.color,
  });

  final BreathingType type;
  final String name;
  final String description;
  final int inhaleSeconds; // Duration to breathe in
  final int holdInSeconds; // Hold after inhaling
  final int exhaleSeconds; // Duration to breathe out
  final int holdOutSeconds; // Hold after exhaling
  final int cycles; // Number of repetitions
  final IconData icon;
  final Color color;

  /// Total duration of one cycle in seconds
  int get cycleDuration =>
      inhaleSeconds + holdInSeconds + exhaleSeconds + holdOutSeconds;

  /// Total exercise duration in seconds
  int get totalDuration => cycleDuration * cycles;
}

/// Pre-configured breathing exercises
class BreathingExercises {
  static const anxiety = BreathingExercise(
    type: BreathingType.anxiety,
    name: '4-7-8 Breathing',
    description: 'Calming technique to reduce anxiety and stress',
    inhaleSeconds: 4,
    holdInSeconds: 7,
    exhaleSeconds: 8,
    holdOutSeconds: 0,
    cycles: 4,
    icon: Icons.self_improvement,
    color: Colors.blue,
  );

  static const focus = BreathingExercise(
    type: BreathingType.focus,
    name: 'Box Breathing',
    description: 'Enhance concentration and mental clarity',
    inhaleSeconds: 4,
    holdInSeconds: 4,
    exhaleSeconds: 4,
    holdOutSeconds: 4,
    cycles: 5,
    icon: Icons.center_focus_strong,
    color: Colors.purple,
  );

  static const relaxation = BreathingExercise(
    type: BreathingType.relaxation,
    name: 'Deep Breathing',
    description: 'General relaxation and stress relief',
    inhaleSeconds: 5,
    holdInSeconds: 2,
    exhaleSeconds: 5,
    holdOutSeconds: 2,
    cycles: 6,
    icon: Icons.spa,
    color: Colors.green,
  );

  static const sleep = BreathingExercise(
    type: BreathingType.sleep,
    name: 'Sleep Breathing',
    description: 'Slow breathing to prepare for restful sleep',
    inhaleSeconds: 4,
    holdInSeconds: 4,
    exhaleSeconds: 6,
    holdOutSeconds: 2,
    cycles: 8,
    icon: Icons.bedtime,
    color: Colors.indigo,
  );

  static const energy = BreathingExercise(
    type: BreathingType.energy,
    name: 'Energizing Breath',
    description: 'Quick technique to boost energy and alertness',
    inhaleSeconds: 3,
    holdInSeconds: 1,
    exhaleSeconds: 3,
    holdOutSeconds: 1,
    cycles: 6,
    icon: Icons.bolt,
    color: Colors.orange,
  );

  /// Get all available exercises
  static List<BreathingExercise> get all => [
        anxiety,
        focus,
        relaxation,
        sleep,
        energy,
      ];

  /// Get exercise by type
  static BreathingExercise fromType(BreathingType type) {
    return all.firstWhere((e) => e.type == type);
  }
}
