import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/Pages/aboutpage.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

// TaskItem class to hold task details and completion status
class TaskItem {
  String description;
  bool isCompleted;

  TaskItem({required this.description, this.isCompleted = false});

  // Factory constructor to create a TaskItem from a Firestore map
  factory TaskItem.fromFirestore(Map<String, dynamic> data) {
    return TaskItem(
      description: data['description'] as String? ?? '',
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }

  // Method to convert TaskItem to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {'description': description, 'isCompleted': isCompleted};
  }
}

class TeamLeaderPage extends StatefulWidget {
  const TeamLeaderPage({super.key});

  @override
  _TeamLeaderPageState createState() => _TeamLeaderPageState();
}

class _TeamLeaderPageState extends State<TeamLeaderPage> {
  String teamCode = '';
  bool isTeamLeader = false;
  String userName = '';
  String? _currentlyExpandedMemberName;
  int _selectedIndex = 0; // For bottom navigation

  @override
  void initState() {
    super.initState();
    _loadTeamCode();
  }

  Future<void> _loadTeamCode() async {
    final prefs = await SharedPreferences.getInstance();
    isTeamLeader = prefs.getBool("teamLeader") ?? false;
    userName = prefs.getString('userName')!;
    
    setState(() {
      teamCode = prefs.getInt('teamCode').toString();
      print(teamCode);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (teamCode.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teams')
          .where('teamCode', isEqualTo: int.parse(teamCode))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(child: Text("Team not found.")),
          );
        }

        final teamData =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final teamName = teamData['teamName'] as String? ?? 'Unknown Team';
        final totalTasks = teamData['totalTasks'] as int? ?? 0;
        final completedTasks = teamData['completedTasks'] as int? ?? 0;
        final teamMembers =
            (teamData['members'] as List<dynamic>?)
                ?.map(
                  (e) => TeamMember.fromFirestore(e as Map<String, dynamic>),
                )
                .toList() ??
            [];

        final double progress = totalTasks > 0
            ? completedTasks / totalTasks
            : 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TEAM DASHBOARD",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              teamName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => About()),
                          );
                        },
                        icon: Icon(Icons.info),

                        color: Colors.grey[600],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Team Progress Circle
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${(progress * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "COMPLETED",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "$completedTasks of $totalTasks tasks",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  TeamCodeRow(teamCode: teamCode),

                  const SizedBox(height: 40),

                  // Team Members Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TEAM MEMBERS",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "${teamMembers.length} members",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Team Members List
                  if (teamMembers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          "No team members found",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    ...teamMembers.map((member) => _buildMemberCard(member)),

                  const SizedBox(height: 10),
                  Center(child: Text("...", style: TextStyle(fontSize: 50))),
                  const SizedBox(height: 20),
                  Text(
                    "Together We,",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: const Color.fromARGB(111, 0, 0, 0),
                    ),
                  ),
                  Text(
                    "Rise",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: const Color.fromARGB(111, 0, 0, 0),
                    ),
                  ),

                  const SizedBox(height: 100), // Bottom padding for navigation
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(TeamMember member) {
    // This ensures only the clicked member expands
    bool isMemberExpanded = _currentlyExpandedMemberName == member.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    _getInitials(member.name),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name != userName ? member.name : 'You',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (member.isLeader) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "LEADER",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.role,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${member.completedTasks}/${member.tasks.length} tasks",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isTeamLeader
                        ? GestureDetector(
                            onTap: () => _showAssignTaskDialog(member),
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          )
                        : SizedBox(),
                    SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          // Toggle expansion: if this member is already expanded, collapse it
                          // Otherwise, expand this member and collapse any other expanded member
                          if (isMemberExpanded) {
                            _currentlyExpandedMemberName =
                                null; // Collapse current member
                          } else {
                            _currentlyExpandedMemberName =
                                member.name; // Expand this member only
                          }
                        });
                      },
                      icon: Icon(
                        isMemberExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable Tasks Section - Only shows for THIS specific member when expanded
          if (isMemberExpanded) ...[
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ASSIGNED TASKS FOR ${member.name.toUpperCase()}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${member.tasks.length} total",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Display ONLY this member's tasks
                  if (member.tasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 32,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No tasks assigned to ${member.name} yet",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Show only THIS member's tasks
                    ...member.tasks.asMap().entries.map((entry) {
                      int taskIndex = entry.key;
                      TaskItem task = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? Colors.green[50]
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: task.isCompleted
                                ? Colors.green[200]!
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: task.isCompleted
                                          ? Colors.green[700]
                                          : Colors.grey[700],
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (task.isCompleted)
                                    Text(
                                      "Completed",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Change Task Status"),
                                    content: task.isCompleted
                                        ? const Text(
                                            "Are you sure? you want to mark it as not completed !",
                                          )
                                        : const Text(
                                            "Are you sure? you want to mark it as completed !",
                                          ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Yes"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  _toggleTaskCompletion(
                                    member,
                                    taskIndex,
                                    task.isCompleted,
                                  );
                                }
                              },

                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                  color: task.isCompleted
                                      ? Colors.green
                                      : Colors.grey[50],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: task.isCompleted
                                    ? Icon(Icons.check, color: Colors.white)
                                    : Icon(Icons.check),
                              ),
                            ),
                            const SizedBox(width: 12),

                            GestureDetector(
                              onTap: () => _showRemoveTaskConfirmation(
                                member,
                                taskIndex,
                              ),
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(Icons.close),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return 'U';
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : 'U';
    }
    return (nameParts[0].isNotEmpty ? nameParts[0][0] : '') +
        (nameParts[1].isNotEmpty ? nameParts[1][0] : '');
  }

  Widget _buildDocumentTile(SharedDocument doc) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.description, color: Colors.grey[600]),
      ),
      title: Text(
        doc.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "${doc.type} • ${doc.lastModified}",
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: () {
        // Handle document tap
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Opening ${doc.name}...')));
      },
    );
  }

  Future<void> _showAssignTaskDialog(TeamMember member) async {
    TextEditingController taskController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Assign Task to ${member.name}"),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(
              labelText: "Task Description",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (taskController.text.trim().isNotEmpty) {
                  await _assignTaskToMember(
                    member.name,
                    taskController.text.trim(),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task assigned successfully!'),
                    ),
                  );
                }
              },
              child: const Text("Assign"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _assignTaskToMember(
    String memberName,
    String taskDescription,
  ) async {
    try {
      final teamsCollection = FirebaseFirestore.instance.collection('teams');
      final querySnapshot = await teamsCollection
          .where('teamCode', isEqualTo: int.parse(teamCode))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final teamDocRef = querySnapshot.docs.first.reference;
        final teamData = querySnapshot.docs.first.data();
        List<dynamic> members = List.from(teamData['members'] ?? []);

        int memberIndex = members.indexWhere((m) => m['name'] == memberName);
        if (memberIndex != -1) {
          List<dynamic> tasksData = List.from(
            members[memberIndex]['tasks'] ?? [],
          );
          tasksData.add(
            TaskItem(
              description: taskDescription,
              isCompleted: false,
            ).toFirestore(),
          );
          members[memberIndex]['tasks'] = tasksData;

          await teamDocRef.update({
            'members': members,
            'totalTasks': FieldValue.increment(1),
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error assigning task: $e')));
    }
  }

  Future<void> _toggleTaskCompletion(
    TeamMember member,
    int taskIndex,
    bool currentStatus,
  ) async {
    try {
      final teamsCollection = FirebaseFirestore.instance.collection('teams');
      final querySnapshot = await teamsCollection
          .where('teamCode', isEqualTo: int.parse(teamCode))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final teamDocRef = querySnapshot.docs.first.reference;
        final teamData = querySnapshot.docs.first.data();
        List<dynamic> members = List.from(teamData['members'] ?? []);

        int memberIndex = members.indexWhere((m) => m['name'] == member.name);
        if (memberIndex != -1) {
          List<dynamic> tasksData = List.from(
            members[memberIndex]['tasks'] ?? [],
          );

          if (taskIndex < tasksData.length) {
            tasksData[taskIndex]['isCompleted'] = !currentStatus;

            int memberCompletedTasks = 0;
            for (var taskMap in tasksData) {
              if (taskMap['isCompleted'] == true) {
                memberCompletedTasks++;
              }
            }
            members[memberIndex]['completedTasks'] = memberCompletedTasks;

            int completedTasksChange = !currentStatus ? 1 : -1;

            await teamDocRef.update({
              'members': members,
              'completedTasks': FieldValue.increment(completedTasksChange),
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
    }
  }

  Future<void> _showRemoveTaskConfirmation(
    TeamMember member,
    int taskIndex,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Task"),
          content: Text(
            "Are you sure you want to remove this task from ${member.name}?",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _removeTask(member, taskIndex);
    }
  }

  Future<void> _removeTask(TeamMember member, int taskIndex) async {
    try {
      final teamsCollection = FirebaseFirestore.instance.collection('teams');
      final querySnapshot = await teamsCollection
          .where('teamCode', isEqualTo: int.parse(teamCode))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final teamDocRef = querySnapshot.docs.first.reference;
        final teamData = querySnapshot.docs.first.data();
        List<dynamic> members = List.from(teamData['members'] ?? []);

        int memberIndex = members.indexWhere((m) => m['name'] == member.name);
        if (memberIndex != -1) {
          List<dynamic> tasksData = List.from(
            members[memberIndex]['tasks'] ?? [],
          );

          if (taskIndex < tasksData.length) {
            final bool wasCompleted =
                tasksData[taskIndex]['isCompleted'] ?? false;

            tasksData.removeAt(taskIndex);
            members[memberIndex]['tasks'] = tasksData;

            int memberCompletedTasks =
                (members[memberIndex]['completedTasks'] ?? 0);
            if (wasCompleted) {
              memberCompletedTasks = memberCompletedTasks - 1;
            }
            members[memberIndex]['completedTasks'] = memberCompletedTasks;

            Map<String, dynamic> updateData = {
              'members': members,
              'totalTasks': FieldValue.increment(-1),
            };

            if (wasCompleted) {
              updateData['completedTasks'] = FieldValue.increment(-1);
            }

            await teamDocRef.update(updateData);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task removed successfully!')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing task: $e')));
    }
  }
}

class TeamMember {
  String name;
  String role;
  List<TaskItem> tasks;
  int completedTasks;
  bool isLeader;

  TeamMember({
    required this.name,
    required this.role,
    required this.tasks,
    required this.completedTasks,
    this.isLeader = false,
  });

  factory TeamMember.fromFirestore(Map<String, dynamic> data) {
    return TeamMember(
      name: data['name'] as String? ?? 'Unknown',
      role: data['role'] as String? ?? 'N/A',
      tasks:
          (data['tasks'] as List<dynamic>?)
              ?.map(
                (taskMap) =>
                    TaskItem.fromFirestore(taskMap as Map<String, dynamic>),
              )
              .toList() ??
          [],
      completedTasks: data['completedTasks'] as int? ?? 0,
      isLeader: data['isLeader'] as bool? ?? false,
    );
  }
}

class SharedDocument {
  String name;
  String type;
  String lastModified;

  SharedDocument(this.name, this.type, this.lastModified);
}

class TeamCodeRow extends StatelessWidget {
  final String teamCode;

  const TeamCodeRow({super.key, required this.teamCode});

  Future<void> _copyCode(BuildContext context) async {
    Clipboard.setData(ClipboardData(text: teamCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Team code copied to clipboard")),
    );
  }

  Future<void> _shareCode() async {
    SharePlus.instance.share(
      ShareParams(
        text:
            "Welcome to TeamUp \n This is your SUPER SECRET CODE: ${teamCode} to join the team",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.share, color: Colors.blue),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _shareCode(),
              child: Text(
                "Share Code",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        InkWell(
          onTap: () => _copyCode(context),
          child: Row(
            children: [
              Icon(Icons.copy, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                "Copy Code",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
