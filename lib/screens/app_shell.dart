import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../routes.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    this.hideDateHeader = false,   // NEW: allow hiding the header
  });

  final Widget child;
  final bool hideDateHeader;       // NEW

  @override
  State<AppShell> createState() => _AppShellState();

  static _AppShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppShellState>();
}

class _AppShellState extends State<AppShell> {
  late final ValueNotifier<DateTime> dateNotifier;

  @override
  void initState() {
    super.initState();
    dateNotifier = ValueNotifier<DateTime>(_mid(DateTime.now()));
  }

  static DateTime _mid(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime get today => _mid(DateTime.now());
  DateTime get viewDate => dateNotifier.value;

  void setViewDate(DateTime d) {
    final clamped = d.isAfter(today) ? today : _mid(d);
    if (dateNotifier.value != clamped) dateNotifier.value = clamped;
  }

  void prevDay() => setViewDate(viewDate.subtract(const Duration(days: 1)));

  void nextDay() {
    if (!viewDate.isBefore(today)) return; // already today → do nothing
    setViewDate(viewDate.add(const Duration(days: 1)));
  }

  Future<void> openWhenPicker() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const _AddWhenSheet(),
    );
    if (choice == null) return;

    DateTime target = today;
    if (choice == 'yesterday') {
      target = today.subtract(const Duration(days: 1));
    } else if (choice == 'pick') {
      final picked = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked == null) return;
      target = picked;
    }
    if (!mounted) return;
    context.go(AppRoutes.checkinStart, extra: {'date': target});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideDateHeader
          ? null
          : AppBar(
        title: ValueListenableBuilder<DateTime>(
          valueListenable: dateNotifier,
          builder: (context, date, _) {
            final canGoNext = date.isBefore(today);
            final label = DateFormat('EEEE, d MMM yyyy').format(date);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: prevDay),
                Flexible(child: Text(label, textAlign: TextAlign.center)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext ? nextDay : null, // disabled if today
                ),
              ],
            );
          },
        ),
        centerTitle: true,
      ),
      body: _ShellDateProvider(
        notifier: dateNotifier, // expose to children
        child: widget.child,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add check-in',
        onPressed: openWhenPicker,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home),
              onPressed: () => context.go(AppRoutes.home, extra: {'date': viewDate}),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Calendar',
              icon: const Icon(Icons.date_range),
              onPressed: () => context.go(
                AppRoutes.calendar,
                extra: {'initialMonth': DateTime(viewDate.year, viewDate.month, 1)},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// InheritedWidget to provide the shell's date notifier to children.
class _ShellDateProvider extends InheritedWidget {
  const _ShellDateProvider({
    required this.notifier,
    required super.child,
    super.key,
  });

  final ValueNotifier<DateTime> notifier;

  static ValueNotifier<DateTime> of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<_ShellDateProvider>()!).notifier;

  @override
  bool updateShouldNotify(_ShellDateProvider oldWidget) =>
      oldWidget.notifier != notifier;
}

/// Convenient extension: anywhere below AppShell, call `context.shellDate`.
extension AppShellX on BuildContext {
  ValueNotifier<DateTime> get shellDate => _ShellDateProvider.of(this);
}

class _AddWhenSheet extends StatelessWidget {
  const _AddWhenSheet();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Wrap(children: [
      ListTile(
        leading: const Icon(Icons.today),
        title: const Text('Today'),
        onTap: () => Navigator.pop(context, 'today'),
      ),
      ListTile(
        leading: const Icon(Icons.calendar_view_day),
        title: const Text('Yesterday'),
        onTap: () => Navigator.pop(context, 'yesterday'),
      ),
      ListTile(
        leading: const Icon(Icons.event),
        title: const Text('Pick a date…'),
        onTap: () => Navigator.pop(context, 'pick'),
      ),
    ]),
  );
}
