import 'package:flutter/material.dart';

import 'screens/history_screen.dart';
import 'screens/library_screen.dart';
import 'screens/listen_screen.dart';
import 'services/store.dart';
import 'theme.dart';

final store = Store();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const SintoniaApp());
}

class SintoniaApp extends StatelessWidget {
  const SintoniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sintonia',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: tab, children: const [
          ListenScreen(),
          HistoryScreen(),
          LibraryScreen(),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic_none), label: 'Ouvir'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Histórico'),
          NavigationDestination(
              icon: Icon(Icons.download_outlined), label: 'Minhas músicas'),
        ],
      ),
    );
  }
}
