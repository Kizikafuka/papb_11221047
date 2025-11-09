import 'package:flutter/material.dart';

// === ENUM MOOD ===
// Enum = tipe data yang punya beberapa pilihan tetap (fixed values)
enum Mood { veryGood, good, neutral, bad, awful }
// cuma bisa pilih mood dari 5 opsi ini aja


// === LABEL MOOD ===
// Fungsi buat ngubah enum jadi teks yang bisa ditampilkan ke user
String moodLabel(Mood m) => switch (m) {
  Mood.veryGood => 'Very Good',
  Mood.good => 'Good',
  Mood.neutral => 'Neutral',
  Mood.bad => 'Bad',
  Mood.awful => 'Awful',
};
// pakai switch expression (fitur Dart modern)
// misalnya: moodLabel(Mood.good) -> "Good"


// === ICON MOOD ===
// Fungsi buat nentuin icon yang cocok sama mood-nya
IconData moodIcon(Mood m) => switch (m) {
  Mood.veryGood => Icons.sentiment_very_satisfied,
  Mood.good => Icons.sentiment_satisfied,
  Mood.neutral => Icons.sentiment_neutral,
  Mood.bad => Icons.sentiment_dissatisfied,
  Mood.awful => Icons.sentiment_very_dissatisfied,
};



// === WARNA MOOD ===
// Fungsi buat kasih warna sesuai level mood
Color moodColor(Mood m) => switch (m) {
  Mood.veryGood => Colors.green,
  Mood.good => Colors.lightGreen,
  Mood.neutral => Colors.amber,
  Mood.bad => Colors.orange,
  Mood.awful => Colors.red,
};
