import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/Utilities/TextStyles.dart';

class Announcement extends StatefulWidget {
  const Announcement({super.key});

  @override
  _AnnouncementState createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  String teamName = "Unknown";
  bool isLeader = false;

  // ✅ State variable to hold announcements
  List<Map<String, String>> sampleAnnouncements = [];

  @override
  void initState() {
    super.initState();
    _loadDate(); // ✅ load announcements on init
  }

  Future<void> _loadDate() async {
    try {
      var prefs = await SharedPreferences.getInstance();

      // teamCode = prefs.getInt('teamCode').toString();
      teamName = prefs.getString("teamName") ?? "UnKnown";
      isLeader = prefs.getBool("teamLeader") ?? false;
      final snapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(prefs.getInt("teamCode").toString())
          .collection('annoucements')
          .get();

      final List<Map<String, String>> tempList = [];

      for (var doc in snapshot.docs) {
        tempList.add({
          "userName": doc.get("userName"),
          "announcementNote": doc.get("announcementNote"),
          "date": DateTime.now().toString(), // or get from doc if available
        });
      }

      setState(() {
        sampleAnnouncements = tempList;
      });
    } catch (e) {
      print(e);
      print("Can't Load Data"); // ignore: avoid_print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ANNOUCEMENTS",
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
                  GestureDetector(
                    onTap: () async {
                      
                      if (isLeader) {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0),
                            ),
                          ),
                          isScrollControlled: true,
                          builder: (context) => BottomSheetContent(
                            onSubmit: (message) async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final teamCode = prefs
                                  .getInt("teamCode")
                                  .toString();
                              final userName =
                                  prefs.getString("userName") ?? "Unknown";

                              await FirebaseFirestore.instance
                                  .collection('teams')
                                  .doc(teamCode)
                                  .collection('annoucements')
                                  .add({
                                    "userName": userName,
                                    "announcementNote": message,
                                    "date": DateTime.now(),
                                  });

                              Navigator.pop(context);
                              _loadDate(); // Reload after posting
                            },
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Only team leaders can post announcements.",
                            ),
                          ),
                        );
                      }
                    },

                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "POST",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Team Progress Circle
              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(240, 238, 238, 1),
                    shape: BoxShape.circle,
                  ),
                  width: 200,
                  height: 200,
                  child: const Center(child: Icon(Icons.campaign, size: 100)),
                ),
              ),

              const SizedBox(height: 40),

              // Shared Documents Section
              sampleAnnouncements.isEmpty
                  ? Center(child: Text("No Annoucements Yet"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sampleAnnouncements.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = sampleAnnouncements[index];
                        return AnnoucementBox(
                          userName: item["userName"] ?? "",
                          announcementNote: item["announcementNote"] ?? "",
                          date: item["date"] ?? "",
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnoucementBox extends StatelessWidget {
  final String userName;
  final String announcementNote;
  final String date;
  const AnnoucementBox({
    super.key,
    required this.userName,
    required this.announcementNote,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color.fromRGBO(240, 238, 238, 1),
            child: Text(
              userName.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcementNote,
                    textAlign: TextAlign.start,
                    style: TextStyles.subText.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Date:${date.split(" ").first}",
                    style: TextStyles.subText.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
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

class BottomSheetContent extends StatefulWidget {
  final Function(String) onSubmit;

  const BottomSheetContent({super.key, required this.onSubmit});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      _showValidationError();
      return;
    }

    setState(() => _isLoading = true);

    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    widget.onSubmit(message);

    setState(() => _isLoading = false);
  }

  void _showValidationError() {
    _focusNode.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please enter an announcement message'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: MediaQuery.of(
          context,
        ).viewInsets.add(const EdgeInsets.fromLTRB(24, 20, 24, 32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Announcement",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Share important updates with everyone",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Text field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 3,
                decoration: InputDecoration(
                  labelText: 'Your announcement message',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  hintText: 'Type your message here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(20),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade500,
                          ),
                        )
                      : null,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(height: 24),

            // Character count
            if (_controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${_controller.text.length} characters',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Post Announcement',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
