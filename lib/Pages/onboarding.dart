import 'package:flutter/material.dart';
import 'package:teamup/Pages/homePage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: "Create Your Team",
      description:
          "Build amazing projects with your crew. Collaborate seamlessly and bring your ideas to life.",
      icon: Icons.group_add,
      color: Colors.black,
    ),
    OnboardingContent(
      title: "Share & Collaborate",
      description:
          "Share files, communicate in real-time, and keep everyone on the same page effortlessly.",
      icon: Icons.share,
      color: Colors.black,
    ),
    OnboardingContent(
      title: "Track Progress",
      description:
          "Monitor your team's progress, set milestones, and celebrate achievements together.",
      icon: Icons.analytics,
      color: Colors.black,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToDashboard();
    }
  }

  void _skipToEnd() {
    _goToDashboard();
  }

  void _goToDashboard() {
    // Navigate to dashboard/main app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome to TeamUp!'),
        backgroundColor: Colors.black,
      ),
    );
    // Replace this with your actual navigation
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _currentPage < 1
                ? null
                : _skipToEnd, // Disable skip until page 2
            child: Text(
              'Skip',
              style: TextStyle(
                color: _currentPage < 1 ? Colors.grey : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return OnboardingSlide(content: _pages[index]);
              },
            ),
          ),

          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index ? Colors.black : Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          SizedBox(height: 40),

          // Next/Get Started button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: _nextPage,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  elevation: WidgetStatePropertyAll(0),
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingSlide({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Icon(
              content.icon,
              size: 60,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 40),

          // Title
          Text(
            content.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),

          // Description
          Text(
            content.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 60),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}