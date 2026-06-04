import 'package:flutter/material.dart';
import 'package:habitfire/app/app.dart';
class UpperNav extends StatelessWidget implements PreferredSizeWidget {
  const UpperNav({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Removes default back button space if needed, or handles it automatically
      automaticallyImplyLeading: false, 
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Your custom Row goes into the title property
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'HABIT',
                  style: TextStyle(color: Colors.red),
                ),
                TextSpan(
                  text: 'FIRE',
                  style: TextStyle(
                    color: Color.fromRGBO(249, 168, 37, 1),
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.local_fire_department,
                    size: 34,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
  icon: const Icon(Icons.menu, size: 32),
  onSelected: (value) {
    switch (value) {
      case 'darkmode':
        // TOGGLE LOGIC: If it's light, change to dark. If it's dark, change to light.
        themeNotifier.value = themeNotifier.value == ThemeMode.light 
            ? ThemeMode.dark 
            : ThemeMode.light;
        break;
      case 'settings':
        break;
      case 'about':
        break;
    }
  },
  itemBuilder: (context) => const [
    PopupMenuItem(value: 'settings', child: Text('Settings')),
    PopupMenuItem(value: 'darkmode', child: Text('Toggle Dark Mode')), // Updated text label
    PopupMenuItem(value: 'about', child: Text('About')),
  ],
)

        ],
      ),
    );
  }

  // This defines the height of your header area
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
