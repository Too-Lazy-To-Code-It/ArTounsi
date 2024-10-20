// lib/pages/main_screen.dart

import 'package:Artounsi/entities/Shop/Cart.dart';
import 'package:Artounsi/pages/Event/events_page.dart';
import 'package:Artounsi/pages/Job/job_page.dart';
import 'package:Artounsi/pages/Learning/learning_page.dart';
import 'package:Artounsi/pages/Post/home_page.dart';
import 'package:Artounsi/pages/Shop/shop_page.dart';
import 'package:Artounsi/pages/User/profile_page.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import 'sidebar.dart';
import 'app_bar.dart';
class MainScreen extends StatefulWidget {
  final Cart cart;

  const MainScreen({Key? key, required this.cart}) : super(key: key);

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
        children: [
          HomePage(),
          JobPage(),
          LearningPage(),
          ShopPage(cart: widget.cart),
          EventPage(),
          UserPage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}