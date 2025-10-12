import 'package:flutter/material.dart';

enum Mood { veryGood, good, neutral, bad, awful }

String moodLabel(Mood m) => switch (m) {
  Mood.veryGood => 'Very Good',
  Mood.good => 'Good',
  Mood.neutral => 'Neutral',
  Mood.bad => 'Bad',
  Mood.awful => 'Awful',
};

IconData moodIcon(Mood m) => switch (m) {
  Mood.veryGood => Icons.sentiment_very_satisfied,
  Mood.good => Icons.sentiment_satisfied,
  Mood.neutral => Icons.sentiment_neutral,
  Mood.bad => Icons.sentiment_dissatisfied,
  Mood.awful => Icons.sentiment_very_dissatisfied,
};

Color moodColor(Mood m) => switch (m) {
  Mood.veryGood => Colors.green,
  Mood.good => Colors.lightGreen,
  Mood.neutral => Colors.amber,
  Mood.bad => Colors.orange,
  Mood.awful => Colors.red,
};
