import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/Pages/IntermediatePages/verifyPage.dart';
import 'package:teamup/Pages/mainPage.dart'; // ← destination after 5s

class Teamjoinpage extends StatefulWidget {
  const Teamjoinpage({super.key});

  @override
  State<Teamjoinpage> createState() => _TeamjoinpageState();
}

class _TeamjoinpageState extends State<Teamjoinpage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _enteredCode = '';
  bool _isLoading = false;

  Future<void> joinTeam() async {
    final preps = await SharedPreferences.getInstance();
    if (_enteredCode.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 5-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final query = await _firestore
          .collection('teams')
          .where('teamCode', isEqualTo: int.parse(_enteredCode))
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Team not found")));
        return;
      }

      final doc = query.docs.first;
      final teamId = doc.id;
      final data = doc.data();
      final teamName = data['teamName'];
      // 🔐 Save team ID to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teamId', teamId);

      // 👤 Add new member
      final List members = List.from(data['members'] ?? []);
      members.add({
        "name": prefs.getString(
          'userName',
        ), // 🔄 Replace with actual name input if available
        "tasks": [],
      });

      // ✅ Recalculate total and completed tasks
      int totalTasks = 0;
      int completedTasks = 0;
      for (var member in members) {
        List tasks = member["tasks"];
        totalTasks += tasks.length;
        completedTasks += tasks
            .where((task) => task["completed"] == true)
            .length;
      }

      // 🔄 Update team document
      await _firestore.collection('teams').doc(teamId).update({
        "members": members,
        "teamMembersCount": members.length,
        "totalTasks": totalTasks,
        "completedTasks": completedTasks,
      });

      // ⏳ Wait 5 seconds, then go to team leader page
      prefs.setString("teamName", teamName);
      prefs.setInt("teamCode", int.parse(_enteredCode));
      prefs.setString("teamId", teamId);
      prefs.setBool('teamLeader', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Mainpage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: _isLoading
          ? Verifypage()
          : Stack(
              children: [
                Positioned(child: Image.asset("assets/bgImages/screen3.png")),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 50,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        const Row(
                          children: [
                            Text(
                              "LET’S ",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              "TEAM UP",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 100),
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                "WANT TO JOIN YOR TEAM",
                                style: TextStyle(
                                  fontSize: 22,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 50),
                              const Text(
                                "TELL US YOUR SUPER SECRET TEAM CODE",
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 250,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  color: const Color.fromARGB(
                                    255,
                                    244,
                                    244,
                                    244,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "ENTER CODE",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                      ),
                                      child: PinCodeTextField(
                                        appContext: context,
                                        length: 5,
                                        obscureText: false,
                                        animationType: AnimationType.fade,
                                        pinTheme: PinTheme(
                                          shape: PinCodeFieldShape.underline,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          fieldHeight: 30,
                                          fieldWidth: 15,
                                          activeFillColor: const Color(
                                            0xFFF4F4F4,
                                          ),
                                          inactiveFillColor: const Color(
                                            0xFFF4F4F4,
                                          ),
                                          selectedFillColor: const Color(
                                            0xFFF4F4F4,
                                          ),
                                          selectedColor: Colors.black,
                                          activeColor: Colors.black,
                                          inactiveColor: Colors.black45,
                                        ),
                                        animationDuration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        enableActiveFill: true,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          _enteredCode = value;
                                        },
                                        onCompleted: (value) {
                                          _enteredCode = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 50),
                              Container(
                                height: 40,
                                width: 200,
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 160, 160, 160),
                                      blurRadius: 6,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: _isLoading ? null : joinTeam,
                                  style: ButtonStyle(
                                    fixedSize: const WidgetStatePropertyAll(
                                      Size(250, 45),
                                    ),
                                    shape:
                                        WidgetStatePropertyAll<
                                          RoundedRectangleBorder
                                        >(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                          Colors.white,
                                        ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        )
                                      : const Text(
                                          "join",
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
