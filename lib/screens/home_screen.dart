import 'package:flutter/material.dart';
import 'webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.home_rounded,
      'label': 'Accueil',
      'url': 'https://excellencedigital.alwaysdata.net',
    },
    {
      'icon': Icons.build_rounded,
      'label': 'Services',
      'url': 'https://excellencedigital.alwaysdata.net/services',
    },
    {
      'icon': Icons.school_rounded,
      'label': 'Formations',
      'url': 'https://excellencedigital.alwaysdata.net/formations',
    },
    {
      'icon': Icons.article_rounded,
      'label': 'Blog',
      'url': 'https://excellencedigital.alwaysdata.net/blog',
    },
    {
      'icon': Icons.person_rounded,
      'label': 'Connexion',
      'url': 'https://excellencedigital.alwaysdata.net/login',
    },
  ];

  // Garder les WebViews en mémoire pour ne pas les recharger
  final Map<int, WebViewScreen> _screens = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          _screens[index] ??= WebViewScreen(url: tab['url']);
          return _screens[index]!;
        }).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0B0F1A),
          selectedItemColor: const Color(0xFF3B82F6),
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 11,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 0,
          items: _tabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab['icon'], size: 22),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(tab['icon'], size: 22, color: const Color(0xFF3B82F6)),
              ),
              label: tab['label'],
            );
          }).toList(),
        ),
      ),
    );
  }
}
