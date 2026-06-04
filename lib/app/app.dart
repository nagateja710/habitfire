import 'package:flutter/material.dart';
import 'package:habitfire/app/shared/navigation/main_navigation_shell.dart';
import 'package:habitfire/app/shared/navigation/upper_nav.dart';

// 1. Global controller that anyone can access to toggle dark/light mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class HabitFireApp extends StatelessWidget {
  const HabitFireApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Wrap with a listener to automatically swap styles across the application
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          // 3. Bind the live state selection
          themeMode: currentThemeMode,
          
          // Light Theme configuration
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          
          // 4. Added Dark Theme setup so colors flip correctly on dark backgrounds
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange.shade300,
              brightness: Brightness.dark,
            ),
          ),
          
          debugShowCheckedModeBanner: false,
          home: const Scaffold(
            appBar: UpperNav(),
            body: MainNavigationPage(),
          ),
        );
      },
    );
  }
}
