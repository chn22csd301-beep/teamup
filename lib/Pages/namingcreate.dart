import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/Pages/teamCreatePage.dart';

class Namingcreate extends StatefulWidget {
  const Namingcreate({super.key});

  @override
  _NamingcreateState createState() => _NamingcreateState();
}

class _NamingcreateState extends State<Namingcreate> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _LoadName() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", _nameController.text);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: false, // prevents resize
    body: Stack(
      children: [
        // Fixed full-screen background
        Positioned.fill(child: Image.asset("assets/bgImages/screen2.png", fit: BoxFit.cover)),

        // Scrollable foreground to avoid overflow
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

                TextButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      await _LoadName();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Welcome ${_nameController.text}!'),
                          backgroundColor: Colors.black,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeamCreatePage(),
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
