import 'package:flutter/material.dart';
import 'pages/Post/home_page.dart';
import 'pages/Shop/shop_page.dart';
import 'pages/Learning/learning_page.dart';
import 'pages/Job/job_page.dart';
import 'pages/Event/events_page.dart';
import 'pages/User/profile_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtStation Clone',
      theme: ThemeData(
        primaryColor: const Color(0xFF13AFF0), // ArtStation blue
        scaffoldBackgroundColor: const Color(0xFF222222), // Dark background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final List<Widget> _pages = [
    HomePage(),
    ShopPage(),
    LearningPage(),
    JobPage(),
    EventPage(),
    UserPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_isSidebarOpen) {
        _toggleSidebar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('ArtStation Clone'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleSidebar,
        ),
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(
                color: Colors.black54,
              ),
            ),
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Drawer(
                child: Container(
                  color: const Color(0xFF333333),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        child: const Text(
                          'ArtStation Clone',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Home', style: TextStyle(color: Colors.white)),
                        onTap: () => _onItemTapped(0),
                      ),
                      ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: const Text('Shop', style: TextStyle(color: Colors.white)),
                        onTap: () => _onItemTapped(1),
                      ),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text('Learning', style: TextStyle(color: Colors.white)),
                        onTap: () => _onItemTapped(2),
                      ),
                      ListTile(
                        leading: const Icon(Icons.work),
                        title: const Text('Job', style: TextStyle(color: Colors.white)),
                        onTap: () => _onItemTapped(3),
                      ),
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Events', style: TextStyle(color: Colors.white)),
                        onTap: () => _onItemTapped(4),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Profile', style: TextStyle(color: Colors.white)),
                        onTap: () => _onItemTapped(5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Job'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF333333),
      ),
    );
  }
}