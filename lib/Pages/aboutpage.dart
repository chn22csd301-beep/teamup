import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Header
              Text(
                "ABOUT US",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "TEAM UP",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              // Circle Icon
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xffdad8d8),
                  shape: BoxShape.circle,
                ),
                width: 180,
                height: 180,
                child: const Center(
                  child: Icon(Icons.groups_rounded, size: 100),
                ),
              ),
              const SizedBox(height: 30),

              // Team Members Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Our Team",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              teamMemberCard("Abhishek Kurian", "UI/UX Design"),
              teamMemberCard(
                  "Jithu Girish", "Backend Development & Firebase Integration"),
              teamMemberCard("S Sree Lekshmi",
                  "Frontend Integration & Web page development"),

              const SizedBox(height: 30),

              // Core Features
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Core Features",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              featureCard("Interactive UI",
                  "Clean and intuitive design that enhances user experience."),
              featureCard("Easy Team Formation",
                  "Quickly build or join teams with a few simple steps."),
              featureCard("Real-Time Notifications",
                  "Instant updates on tasks, messages, and announcements."),
              featureCard("Document Sharing",
                  "Securely upload and access important team files."),
              featureCard("Live Announcements",
                  "Keep your team aligned with real-time alerts."),
              featureCard("Team Communication",
                  "Smooth interactions between leaders and members."),

              const SizedBox(height: 30),

              // Quote

              const SizedBox(height: 20),

              // Closing Thank You
              const Text(
                "Thank you for choosing TEAM UP!\n Satisfaction Guaranteed And Definitely 👍\nJithu & Co",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Copyright
              const Text(
                "© 2025 TEAM UP. All rights reserved.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Team Member Card Widget
  static Widget teamMemberCard(String name, String role) {
    return Card(
      color: const Color(0xFFF0F0F0),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.person, size: 24, color: Colors.black87),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(role,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Feature Card Widget
  static Widget featureCard(String title, String description) {
    return Card(
      color: const Color(0xFFF2F2F2),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.star_border_rounded,
                color: Colors.black54, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      )),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black54,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}