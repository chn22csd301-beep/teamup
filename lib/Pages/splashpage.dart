import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/Pages/mainPage.dart';
import 'package:teamup/Pages/onboarding.dart';

class TeamUpSplash extends StatefulWidget {
  const TeamUpSplash({super.key});

  @override
  State<TeamUpSplash> createState() => _TeamUpSplashState();
}

class _TeamUpSplashState extends State<TeamUpSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool("teamLeader") == null;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isFirstTime ? const OnboardingPage() : const Mainpage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Container
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD6D6D6),
                  ),
                  child: Center(
                    child: Image.asset("assets/logo/logo.png"),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "TeamUP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JuliusSansOne', // Custom font
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
