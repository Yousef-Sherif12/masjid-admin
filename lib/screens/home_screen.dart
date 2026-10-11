import 'package:flutter/material.dart';
import 'package:masjid_admin/screens/collections_screen.dart';
import 'package:masjid_admin/screens/iqama_screen.dart';
import 'package:masjid_admin/screens/ticker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _screens = [
    {
      'title': 'النصوص',
      'icon': Icons.menu_book,
      'screen': const CollectionsScreen(),
    },
    {
      'title': 'أوقات الإقامة',
      'icon': Icons.access_time_filled_outlined,
      'screen': const IqamaScreen(),
    },
    {
      'title': 'الشريط السفلي',
      'icon': Icons.view_headline,
      'screen': const TickerScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // ✅ Side Menu للديسكتوب
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'لوحة التحكم',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              destinations: _screens
                  .map(
                    (s) => NavigationRailDestination(
                      icon: Icon(s['icon'] as IconData),
                      label: Text(s['title'] as String),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _screens[_selectedIndex]['screen'] as Widget),
          ],
        ),
      );
    }

    // ✅ Bottom Nav للموبايل
    return Scaffold(
      body: _screens[_selectedIndex]['screen'] as Widget,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _screens
            .map(
              (s) => NavigationDestination(
                icon: Icon(s['icon'] as IconData),
                label: s['title'] as String,
              ),
            )
            .toList(),
      ),
    );
  }
}
