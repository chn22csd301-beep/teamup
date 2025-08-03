import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/Pages/IntermediatePages/creatingPage.dart';
import 'package:teamup/Pages/leaderPage.dart';
import 'package:teamup/Utilities/TextStyles.dart';
import 'package:uuid/uuid.dart';

class TeamCreatePage extends StatefulWidget {
  const TeamCreatePage({super.key});

  @override
  State<TeamCreatePage> createState() => _TeamCreatePageState();
}

class _TeamCreatePageState extends State<TeamCreatePage> {
  int teamMembers = 3;
  final _uuid = Uuid();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamDescController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> generateUniqueTeamCode() async {
    final Random random = Random();
    int teamCode;
    bool isUnique = false;

    while (!isUnique) {
      teamCode = 10000 + random.nextInt(90000); // Generates between 10000-99999
      final query = await _firestore
          .collection('teams')
          .where('teamCode', isEqualTo: teamCode)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        isUnique = true;
        return teamCode;
      }
    }
    return 10000 + random.nextInt(90000); // fallback
  }

  Future<void> createTeam() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true; // Show loading animation
    });
    final teamName = _teamNameController.text.trim();
    final description = _teamDescController.text.trim();

    if (teamName.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      // Check if team name already exists
      final existing = await _firestore
          .collection("teams")
          .where("teamName", isEqualTo: teamName)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Team name already exists")),
        );
        return;
      }

      // Generate a unique ID and team code
      final teamId = _uuid.v4();
      final teamCode = await generateUniqueTeamCode();

      // Dummy members and task data
      List<Map<String, dynamic>> members = [
        {
          'completedTask': 0,
          'name': prefs.getString("userName") ?? 'Unknown',
          'tasks': [],
        },
      ];
      List<Map<String, dynamic>> Annoucements = [];
      int totalTasks = 0;
      int completedTasks = 0;

      // Create team document in Firestore
      await _firestore.collection("teams").doc(teamId).set({
        "id": teamId,
        "teamCode": teamCode,
        "teamName": teamName,
        "description": description,
        "teamMembersCount": teamMembers,
        "members": members,
        "totalTasks": totalTasks,
        "completedTasks": completedTasks,
        "createdAt": FieldValue.serverTimestamp(),
        "Announcements": Annoucements,
      });

      _teamNameController.clear();
      _teamDescController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team created successfully!")),
      );

      prefs.setString("teamName", teamName);
      prefs.setInt("teamCode", teamCode);
      prefs.setString("teamId", teamId);
      prefs.setBool("teamLeader", true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TeamLeaderPage()),
      );

      setState(() {
        teamMembers = 5;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Creatingpage()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
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
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
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
                          const SizedBox(height: 40),

                          const Text(
                            "WHAT DOES YOUR TEAM WANT TO BE CALLED?",
                            style: TextStyles.subText,
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: _teamNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                          const Text(
                            "DESCRIBE YOUR TEAM",
                            style: TextStyles.subText,
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: _teamDescController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),

                          const SizedBox(height: 32),
                          const Text(
                            "TOTAL TEAM MEMBERS",
                            style: TextStyles.subText,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (teamMembers > 1) teamMembers--;
                                    });
                                  },
                                  child: const Center(
                                    child: Icon(Icons.remove, size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "$teamMembers",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      teamMembers++;
                                    });
                                  },
                                  child: const Center(
                                    child: Icon(Icons.add, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                          Center(
                            child: TextButton(
                              onPressed: createTeam,
                              style: ButtonStyle(
                                backgroundColor:
                                    const WidgetStatePropertyAll<Color>(
                                      Colors.black,
                                    ),
                                padding:
                                    const WidgetStatePropertyAll<EdgeInsets>(
                                      EdgeInsets.symmetric(
                                        horizontal: 80,
                                        vertical: 16,
                                      ),
                                    ),
                                shape:
                                    WidgetStatePropertyAll<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                elevation: const WidgetStatePropertyAll(6),
                                shadowColor: const WidgetStatePropertyAll(
                                  Colors.black54,
                                ),
                              ),
                              child: const Text(
                                "create",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
