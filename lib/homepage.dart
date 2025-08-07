import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/chatpage.dart';
import 'package:my_app/newsfeed.dart';
import 'package:my_app/sunflower.dart';
import 'settings.dart';
import 'package:my_app/billsplitpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 3;

  // Pages for bottom navigation
  final List<Widget> _pages = const [
    NewsFeedPage1(), // Replace with your news feed page
    Sunflower(), // Replace with your search or other page
    SimpleChat(), // Replace with your chat page
    
    BillSplitPage()
  ];
  final List<String> _titles = const [
   'News', // Replace with your news feed page
    'Sunflower', // Replace with your search or other page
    'Chat',
    'SplitBill',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background~
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Darker AppBar
        title:  Text(_titles[_selectedIndex], style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage1()),
              );
            },
          ),
        ],
      ),
    body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: Colors.green.withOpacity(0.3),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.newspaper_rounded, color: Colors.white),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_nature_outlined, color: Colors.white),
            label: 'SunFlower',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined, color: Colors.white),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline, color: Colors.white),
            label: 'Bill Split',
          ),
        ],
      ),
    );
  }
}
