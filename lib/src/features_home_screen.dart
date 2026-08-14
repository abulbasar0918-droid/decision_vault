import 'package:flutter/material.dart';

import 'features/decisions/presentation/screens/decision_list_screen.dart';
import 'features_dashboard_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'shared/widgets/premium_app_bar.dart';
import 'shared/widgets/responsive_layout.dart';
import 'core/constants/app_constants.dart';

/// HomeScreen hosts root navigation structure (rail for large screens and
/// bottom navigation for small screens). Each item lives in its own screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => <Widget>[
        const DashboardScreen(),
        const DecisionListScreen(),
        const SettingsScreen(),
      ];

  void _onSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      smallScreen: Scaffold(
        appBar: const PremiumAppBar(title: AppConstants.appName),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onSelect,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Decisions'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
      largeScreen: Scaffold(
        appBar: const PremiumAppBar(title: AppConstants.appName),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onSelect,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CircleAvatar(child: Icon(Icons.lock_outline)),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: Text('Decisions')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
    );
  }
}
