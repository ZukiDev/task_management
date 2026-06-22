import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../date/date_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../task/task_list_page.dart';

/// Widget pemegang BottomNavigationBar dengan 4 tab: Home, Task, Date,
/// Profile.
///
/// Memakai [IndexedStack] (bukan ganti widget langsung) supaya state
/// tiap tab (misal scroll position, hasil fetch) tidak hilang saat
/// pindah-pindah tab — masing-masing child tetap "hidup" di belakang,
/// cuma yang aktif yang ditampilkan.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomePage(),
    TaskListPage(),
    DatePage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
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
