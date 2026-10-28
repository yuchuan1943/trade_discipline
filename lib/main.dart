import 'package:flutter/material.dart';

import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.init();
  runApp(const TradeDisciplineApp());
}

class TradeDisciplineApp extends StatelessWidget {
  const TradeDisciplineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFD9404A),
      primary: const Color(0xFFD9404A),
    );
    return MaterialApp(
      title: '交易守则打卡',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF17191C),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    HistoryScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFBEaEB),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today, color: Color(0xFFD9404A)),
            label: '今日',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Color(0xFFD9404A)),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFFD9404A)),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFFD9404A)),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
