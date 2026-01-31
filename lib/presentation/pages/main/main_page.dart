import 'package:flutter/material.dart';

import '../../widgets/common/app_bottom_navigation_bar.dart';
import '../map/map_home_page.dart';
import '../messaging/conversations_page.dart';
import '../profile/profile_page.dart';
import '../scroll/scroll_page.dart';
import '../search/search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      MapHomePage(embedded: true),
      SearchPage(),
      ScrollPage(),
      ConversationsPage(),
      ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Camera gap
          Container(
            height: MediaQuery.of(context).padding.top + 10,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
