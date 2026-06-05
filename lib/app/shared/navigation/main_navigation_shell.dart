import 'package:flutter/material.dart';

import '../../pages/home/presentation/home_page.dart';
import '../../pages/streak/presentation/streak_page.dart';
import '../../pages/analytics/presentation/analytics_page.dart';
import '../../pages/calendar/presentation/calendar_page.dart';
import '../../pages/journeys/presentation/journeys_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int currentIndex = 0;

  final pages = const [
    HomePage(),
    CalendarPage(),
    StreaksPage(),
    AnalyticsPage(),
    AchievementsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'Streaks',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_rounded),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Journeys',
          ),
        ],
      ),
    );
  }
}
