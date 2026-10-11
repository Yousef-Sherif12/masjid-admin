import 'package:flutter/material.dart';
import 'package:masjid_admin/core/widgets/adaptive_scaffold.dart';
import 'package:masjid_admin/features/collections/presentation/screens/collections_screen.dart';
import 'package:masjid_admin/features/iqama/presentation/screens/iqama_screen.dart';
import 'package:masjid_admin/features/ticker/presentation/screens/ticker_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<AdaptiveDestination> _destinations = [
    AdaptiveDestination(
      title: 'المحتوى والأذكار',
      subtitle: 'إدارة المجموعات والنصوص والبث',
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories_rounded,
      screen: CollectionsScreen(),
    ),
    AdaptiveDestination(
      title: 'أوقات الإقامة',
      subtitle: 'ضبط دقائق الانتظار للصلوات',
      icon: Icons.access_time_outlined,
      selectedIcon: Icons.access_time_filled_rounded,
      screen: IqamaScreen(),
    ),
    AdaptiveDestination(
      title: 'الشريط والتقويم',
      subtitle: 'الإعلانات السفلية والتاريخ الهجري',
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
      screen: TickerScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: _destinations,
    );
  }
}
