import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHomePage(),
                  _buildCommunityPage(),
                  _buildSearchPage(),
                  _buildNotificationsPage(),
                  _buildMorePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            'https://www.artstation.com/assets/logo-icon-white-5ba3bd87a12bc82c5a078c252e1f2f7f.png',
            height: 32,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return ListView(
      children: [
        _buildStorySection(),
        _buildFeedItem(),
        _buildFeedItem(),
      ],
    );
  }

  Widget _buildStorySection() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF13AFF0), Color(0xFFFF00FF)],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage('https://picsum.photos/200'),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'User $index',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedItem() {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://picsum.photos/200'),
            ),
            title: const Text('Artist Name'),
            subtitle: const Text('2 hours ago'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          Image.network(
            'https://picsum.photos/400/300',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border),
                    SizedBox(width: 8),
                    Icon(Icons.chat_bubble_outline),
                    SizedBox(width: 8),
                    Icon(Icons.send),
                  ],
                ),
                Icon(Icons.bookmark_border),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Liked by User1 and 1,234 others',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Artist caption goes here...'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityPage() {
    return const Center(child: Text('Community Page'));
  }

  Widget _buildSearchPage() {
    return const Center(child: Text('Search Page'));
  }

  Widget _buildNotificationsPage() {
    return const Center(child: Text('Notifications Page'));
  }

  Widget _buildMorePage() {
    return const Center(child: Text('More Page'));
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.transparent,
        tabs: [
          Tab(icon: Icon(Icons.home, color: _selectedIndex == 0 ? Theme.of(context).primaryColor : Colors.grey)),
          Tab(icon: Icon(Icons.people, color: _selectedIndex == 1 ? Theme.of(context).primaryColor : Colors.grey)),
          Tab(icon: Icon(Icons.search, color: _selectedIndex == 2 ? Theme.of(context).primaryColor : Colors.grey)),
          Tab(icon: Icon(Icons.notifications, color: _selectedIndex == 3 ? Theme.of(context).primaryColor : Colors.grey)),
          Tab(icon: Icon(Icons.menu, color: _selectedIndex == 4 ? Theme.of(context).primaryColor : Colors.grey)),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}