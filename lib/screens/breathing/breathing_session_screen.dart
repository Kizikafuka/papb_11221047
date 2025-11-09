import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/breathing_exercise.dart';

/// Breathing phase during exercise
enum BreathPhase { inhale, holdIn, exhale, holdOut }

/// Interactive breathing exercise session screen with visual guidance
class BreathingSessionScreen extends StatefulWidget {
  const BreathingSessionScreen({super.key, required this.exercise});

  final BreathingExercise exercise;

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _currentCycle = 0; // Current cycle count (0-based)
  BreathPhase _currentPhase = BreathPhase.inhale;
  bool _isRunning = false; // Exercise is actively running
  Timer? _phaseTimer; // Timer for phase transitions

  @override
  void initState() {
    super.initState();
    // Animation controller for circle breathing visualization
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.exercise.inhaleSeconds),
    );

    // Scale animation: grows during inhale, shrinks during exhale
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Start the breathing exercise
  void _startExercise() {
    setState(() {
      _isRunning = true;
      _currentCycle = 0;
      _currentPhase = BreathPhase.inhale;
    });
    _runPhase();
  }

  /// Stop/pause the exercise
  void _stopExercise() {
    setState(() => _isRunning = false);
    _phaseTimer?.cancel();
    _controller.stop();
  }

  /// Execute current breathing phase
  void _runPhase() {
    if (!_isRunning) return;

    final duration = _getPhaseDuration(_currentPhase);
    final isBreathing = _currentPhase == BreathPhase.inhale ||
        _currentPhase == BreathPhase.exhale;

    // Animate circle if breathing (inhale/exhale)
    if (isBreathing) {
      _controller.duration = Duration(seconds: duration);
      if (_currentPhase == BreathPhase.inhale) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
      }
    }

    // Schedule next phase transition
    _phaseTimer = Timer(Duration(seconds: duration), _nextPhase);
  }

  /// Get duration for a specific phase
  int _getPhaseDuration(BreathPhase phase) {
    return switch (phase) {
      BreathPhase.inhale => widget.exercise.inhaleSeconds,
      BreathPhase.holdIn => widget.exercise.holdInSeconds,
      BreathPhase.exhale => widget.exercise.exhaleSeconds,
      BreathPhase.holdOut => widget.exercise.holdOutSeconds,
    };
  }

  /// Transition to next breathing phase
  void _nextPhase() {
    if (!_isRunning) return;

    setState(() {
      // Move to next phase in the cycle
      _currentPhase = switch (_currentPhase) {
        BreathPhase.inhale => BreathPhase.holdIn,
        BreathPhase.holdIn => BreathPhase.exhale,
        BreathPhase.exhale => BreathPhase.holdOut,
        BreathPhase.holdOut => BreathPhase.inhale,
      };

      // If we completed a full cycle, increment cycle count
      if (_currentPhase == BreathPhase.inhale) {
        _currentCycle++;
        // Check if exercise is complete
        if (_currentCycle >= widget.exercise.cycles) {
          _completeExercise();
          return;
        }
      }
    });

    _runPhase();
  }

  /// Handle exercise completion
  void _completeExercise() {
    _stopExercise();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Well Done!'),
        content: const Text(
          'You\'ve completed the breathing exercise. How do you feel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to list
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  /// Get instructional text for current phase
  String get _phaseInstruction {
    return switch (_currentPhase) {
      BreathPhase.inhale => 'Breathe In',
      BreathPhase.holdIn => 'Hold',
      BreathPhase.exhale => 'Breathe Out',
      BreathPhase.holdOut => 'Hold',
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentCycle / widget.exercise.cycles;

    return Scaffold(
      backgroundColor: widget.exercise.color.withOpacity(0.1),
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: progress,
                backgroundColor: widget.exercise.color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(widget.exercise.color),
              ),
              const SizedBox(height: 8),
              Text(
                'Cycle ${_currentCycle + 1} of ${widget.exercise.cycles}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Spacer(),

              // Breathing visualization circle
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.exercise.color.withOpacity(0.15),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _animation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.exercise.color.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Icon(
                              widget.exercise.icon,
                              size: 80,
                              color: widget.exercise.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Phase instruction
              Text(
                _phaseInstruction,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.exercise.color,
                    ),
              ),

              const SizedBox(height: 12),

              // Phase duration counter
              if (_isRunning)
                Text(
                  '${_getPhaseDuration(_currentPhase)}s',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),

              const Spacer(),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRunning)
                    FilledButton.icon(
                      onPressed: _startExercise,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.exercise.color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _stopExercise,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.exercise.color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
