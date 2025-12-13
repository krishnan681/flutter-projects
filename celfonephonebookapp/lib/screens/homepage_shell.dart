import 'package:flutter/material.dart';
import './homepage.dart';
import './offers_page.dart';
import './ search_page.dart';
import './promotion_page.dart';
import 'settings_page.dart';

class HomePageShell extends StatefulWidget {
  const HomePageShell({super.key});

  @override
  State<HomePageShell> createState() => _HomePageShellState();
}

class _HomePageShellState extends State<HomePageShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    OffersPage(),
    SearchPage(category: ''),
    PromotionPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: "Offers",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: "Promotion",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
