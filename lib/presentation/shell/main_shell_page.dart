import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/task_change_notifier.dart';
import '../date/date_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../task/task_list_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  int _refreshTick = 0;

  late final VoidCallback _taskChangeListener;

  @override
  void initState() {
    super.initState();
    _taskChangeListener = () {
      if (!mounted) return;
      setState(() => _refreshTick++);
    };
    TaskChangeNotifier().addListener(_taskChangeListener);
  }

  @override
  void dispose() {
    TaskChangeNotifier().removeListener(_taskChangeListener);
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomePage(key: ValueKey('home_$_refreshTick')),
      const TaskListPage(),
      DatePage(key: ValueKey('date_$_refreshTick')),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Date',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
