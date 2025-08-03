import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/Pages/teamJoinPage.dart';

class Namingjoin extends StatefulWidget {
  const Namingjoin({super.key});

  @override
  _NamingjoinState createState() => _NamingjoinState();
}

class _NamingjoinState extends State<Namingjoin> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents layout shift
      body: Stack(
        children: [
          // Fullscreen fixed background
          Positioned.fill(
            child: Image.asset(
              "assets/bgImages/screen2.png",
              fit: BoxFit.cover,
            ),
          ),

          // Foreground content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'LET ME KNOW YOUR NAME',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input field
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: '',
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Let's TeamUp button
                  TextButton(
                    onPressed: () async {
                      if (_nameController.text.isNotEmpty) {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString("userName", _nameController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Welcome ${_nameController.text}!'),
                            backgroundColor: Colors.black,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Teamjoinpage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter your name"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: const WidgetStatePropertyAll(Size(250, 50)),
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      backgroundColor: const WidgetStatePropertyAll<Color>(
                        Colors.black,
                      ),
                      elevation: const WidgetStatePropertyAll(0),
                    ),
                    child: const Text(
                      "Let's TeamUp",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
