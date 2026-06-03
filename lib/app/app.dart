import 'package:flutter/material.dart';
import 'package:habitfire/app/shared/navigation/main_navigation_shell.dart';

class HabitFireApp extends StatelessWidget {
  const HabitFireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainNavigationPage(),
    );
  }
}