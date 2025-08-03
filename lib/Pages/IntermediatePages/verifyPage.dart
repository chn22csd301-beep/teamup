
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Verifypage extends StatefulWidget {
  const Verifypage({super.key});

  @override
  State<Verifypage> createState() => _VerifypageState();
}

class _VerifypageState extends State<Verifypage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // 2️⃣ Wait 5 seconds, then go to TeamLeaderPage
         
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "VERIFYING...",
            style: TextStyle(fontSize: 24, letterSpacing: 6),
          ),
          const SizedBox(height: 10),
          Center(
            child: Lottie.asset(
              'assets/animation/verify1.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration =
                    composition.duration * 0.50; // 🔥 2x speed
                _controller.repeat();
              },
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
