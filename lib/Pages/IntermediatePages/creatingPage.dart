import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Creatingpage extends StatefulWidget {
  const Creatingpage({super.key});

  @override
  State<Creatingpage> createState() => _CreatingpageState();
}

class _CreatingpageState extends State<Creatingpage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
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
            "CREATING...",
            style: TextStyle(fontSize: 24, letterSpacing: 6),
          ),
          const SizedBox(height: 20),
          Center(
            child: Lottie.asset(
              'assets/animation/create.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration =
                    composition.duration*0.9 ; // 🔥 2x speed
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
