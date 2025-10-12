import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'state/journal_state.dart';
import 'db/app_db.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();
    return Provider<AppDb>(
      create: (_) => AppDb(),
      dispose: (_, db) => db.close(),
      child: ChangeNotifierProvider(
        create: (ctx) => JournalState(db: ctx.read<AppDb>()),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Coowdi',
          routerConfig: router,
          theme: ThemeData(
            primarySwatch: Colors.green,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
