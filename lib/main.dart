import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/app_db.dart';
import 'routes.dart';
import 'state/journal_state.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ThemeData _theme = ThemeData(
    primarySwatch: Colors.green,
    fontFamily: 'Poppins',
  );

  @override
  Widget build(BuildContext context) {
    final router = createRouter(); // Configure navigation stack once per build.

    return Provider<AppDb>(
      create: (_) => AppDb(), // Provide database instance to the widget tree.
      dispose: (_, db) => db.close(), // Ensure database is closed on teardown.
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => JournalState(db: ctx.read<AppDb>()),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Coowdi',
          routerConfig: router,
          theme: _theme, // Apply shared theme configuration.
        ),
      ),
    );
  }
}
