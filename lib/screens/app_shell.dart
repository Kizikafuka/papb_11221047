import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../routes.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    this.hideDateHeader = false,   // bisa sembunyikan header tanggal (mis. di halaman tertentu)
  });

  final Widget child;              // konten halaman di dalam shell
  final bool hideDateHeader;       // kontrol visibilitas header tanggal

  @override
  State<AppShell> createState() => _AppShellState();

  // Helper buat dapat instance state di bawah tree
  static _AppShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppShellState>();
}

class _AppShellState extends State<AppShell> {
  // Notifier yang menyimpan tanggal yang sedang dilihat (viewDate)
  late final ValueNotifier<DateTime> dateNotifier;

  @override
  void initState() {
    super.initState();
    // Set awal = hari ini jam 00:00 (reset ke "tengah malam")
    dateNotifier = ValueNotifier<DateTime>(_mid(DateTime.now()));
  }

  // Utility: “midnight” → buang jam/menit/detik/ms
  static DateTime _mid(DateTime d) => DateTime(d.year, d.month, d.day);

  // Getter cepat
  DateTime get today => _mid(DateTime.now());
  DateTime get viewDate => dateNotifier.value;

  // Ubah tanggal tampilan, dan clamp supaya tidak melewati "hari ini"
  void setViewDate(DateTime d) {
    final clamped = d.isAfter(today) ? today : _mid(d); // jika masa depan → paksa jadi today
    if (dateNotifier.value != clamped) dateNotifier.value = clamped;
  }

  // Mundur 1 hari
  void prevDay() => setViewDate(viewDate.subtract(const Duration(days: 1)));

  // Maju 1 hari (hanya jika belum “today”)
  void nextDay() {
    if (!viewDate.isBefore(today)) return; // sudah hari ini → diam
    setViewDate(viewDate.add(const Duration(days: 1)));
  }

  // Buka bottom sheet pilih kapan check-in
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

    // Navigate ke halaman mulai check-in sambil bawa tanggal target
    context.go(AppRoutes.checkinStart, extra: {'date': target});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar opsional (bisa disembunyikan)
      appBar: widget.hideDateHeader
          ? null
          : AppBar(
        title: ValueListenableBuilder<DateTime>(
          valueListenable: dateNotifier,
          builder: (context, date, _) {
            final canGoNext = date.isBefore(today); // boleh maju jika belum hari ini
            final label = DateFormat('EEEE, d MMM yyyy').format(date);

            // Catatan anti-overflow: pakai Flexible di tengah
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: prevDay,
                  tooltip: 'Previous day',
                ),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // jaga kecil layar
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext ? nextDay : null, // disable jika sudah today
                  tooltip: canGoNext ? 'Next day' : 'Today',
                ),
              ],
            );
          },
        ),
        centerTitle: true,
      ),

      // Body: expose dateNotifier ke anak-2 lewat InheritedWidget
      body: _ShellDateProvider(
        notifier: dateNotifier,
        child: widget.child,
      ),

      // FAB di tengah bawah (dock)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add check-in',
        onPressed: openWhenPicker,
        child: const Icon(Icons.add),
      ),

      // Bottom bar dengan notch (celah) untuk FAB
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SafeArea( // tambahan: biar aman di perangkat dengan gesture bar
          child: Row(
            children: [
              IconButton(
                tooltip: 'Home',
                icon: const Icon(Icons.home),
                onPressed: () => context.go(
                  AppRoutes.home,
                  extra: {'date': viewDate}, // bawa tanggal yang sedang dilihat
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Calendar',
                icon: const Icon(Icons.date_range),
                onPressed: () => context.go(
                  AppRoutes.calendar,
                  extra: {
                    // arahkan kalender ke bulan dari viewDate
                    'initialMonth': DateTime(viewDate.year, viewDate.month, 1),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// InheritedWidget untuk expose ValueNotifier<DateTime> ke subtree.
/// Keuntungannya: child-2 bisa subscribe perubahan tanggal tanpa Provider.
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
      oldWidget.notifier != notifier; // ganti instance → notify
}

/// Extension biar gampang akses: `context.shellDate`
/// Contoh: `context.shellDate.value` atau `context.shellDate.addListener(...)`
extension AppShellX on BuildContext {
  ValueNotifier<DateTime> get shellDate => _ShellDateProvider.of(this);
}

/// Bottom sheet pilihan waktu check-in
class _AddWhenSheet extends StatelessWidget {
  const _AddWhenSheet();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Wrap(
      children: [
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
      ],
    ),
  );
}
