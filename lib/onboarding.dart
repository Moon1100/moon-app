import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authpage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Welcome!",
      "subtitle": "Discover amazing features with our app.",
      "icon": Icons.explore,
      "color": Colors.deepPurple,
    },
    {
      "title": "Stay Connected",
      "subtitle": "Connect with people and share your thoughts.",
      "icon": Icons.people,
      "color": Colors.blueAccent,
    },
    {
      "title": "Get Started",
      "subtitle": "Join us and explore all possibilities.",
      "icon": Icons.rocket_launch,
      "color": Colors.greenAccent,
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_done", true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: page["color"].withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          page["icon"],
                          size: 80,
                          color: page["color"],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        page["title"],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page["subtitle"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: _currentPage == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.deepPurple : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_currentPage == _pages.length - 1) {
                  _finishOnboarding();
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
