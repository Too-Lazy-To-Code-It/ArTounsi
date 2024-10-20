import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import 'sidebar.dart';
import 'app_bar.dart';
import '../Event/events_page.dart';
import '../Job/job_page.dart';
import '../Learning/learning_page.dart';
import '../Post/home_page.dart';
import '../Shop/shop_page.dart';
import '../User/profile_page.dart';
import '../Post/blog_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _pageTitles = [
    'Home',
    'Jobs',
    'Learning',
    'Shop',
    'Events',
    'Profile'
  ];
  final List<Widget> _pages = [
    HomePage(),
    JobPage(),
    LearningPage(),
    ShopPage(),
    EventPage(),
    UserPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: _pageTitles[_selectedIndex],
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: CustomSidebar(
        onItemTapped: _onItemTapped,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}