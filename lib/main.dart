import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/Event/events_page.dart';
import 'pages/Job/job_page.dart';
import 'pages/Learning/learning_page.dart';
import 'pages/Post/home_page.dart';
import 'pages/Shop/shop_page.dart';
import 'pages/User/profile_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtStation Clone',
      theme: ThemeData(
        primaryColor: const Color(0xFF13AFF0),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
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
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _pageTitles = ['Home', 'Jobs', 'Learning', 'Shop', 'Events', 'Profile'];
  final List<Widget> _pages = [
    HomePage(),
    JobPage(),
    LearningPage(),
    ShopPage(),
    EventPage(),
    UserPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(_pageTitles[_selectedIndex]),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {},
            ),
          ],
        ),
      ),
      drawer: _buildSidebar(),
      body: TabBarView(
        controller: _tabController,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: Container(
        color: const Color(0xFF1A1A1A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'ArtStation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', 0),
            _buildDrawerItem(Icons.work, 'Jobs', 1),
            _buildDrawerItem(Icons.school, 'Learning', 2),
            _buildDrawerItem(Icons.shopping_cart, 'Shop', 3),
            _buildDrawerItem(Icons.event, 'Events', 4),
            _buildDrawerItem(Icons.person, 'Profile', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1A1A1A),
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learning'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}