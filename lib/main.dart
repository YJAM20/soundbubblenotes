import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/notes_provider.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/archived_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(const SoundBubbleNotesApp());
}

class SoundBubbleNotesApp extends StatelessWidget {
  const SoundBubbleNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // DI container using MultiProvider
    return MultiProvider(
      providers: [
        Provider<AudioService>(
          create: (_) => AudioService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        ChangeNotifierProvider<NotesProvider>(
          create: (context) => NotesProvider(
            audioService: context.read<AudioService>(),
            storageService: context.read<StorageService>(),
          ),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.tealAccent,
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
    );

    return MaterialApp(
      title: 'Sound Bubble Notes',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0 ? 'Sound Bubbles' : 'Archived',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Use Consumer to handle global loading/error states if needed,
        // though individual screens can handle their own content.
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            HomeScreen(),
            ArchivedScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bubble_chart_outlined),
              selectedIcon: Icon(Icons.bubble_chart),
              label: 'Bubbles',
            ),
            NavigationDestination(
              icon: Icon(Icons.archive_outlined),
              selectedIcon: Icon(Icons.archive),
              label: 'Archived',
            ),
          ],
        ),
      ),
    );
  }
}
