import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/storage_service.dart';
import 'core/services/streak_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = StorageService();
  await storage.init();

  // Initialize streak service
  final streakService = StreakService(storage);

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp(
    storage: storage,
    streakService: streakService,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storage;
  final StreakService streakService;

  const MyApp({
    super.key,
    required this.storage,
    required this.streakService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy: Smash Mode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode
      home: HomeScreen(
        storage: storage,
        streakService: streakService,
      ),
    );
  }
}
