import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  String teamName = "The Innovators";
  String teamCode = "";
  int totalTasks = 0;
  int completedTasks = 0;

  List<SharedDocument> sharedDocs = [];
  bool isLoading = true;
  bool isUploading = false;

  final cloudinary = Cloudinary.signedConfig(
    apiKey: "867422241413155",
    apiSecret: "i8-wZvF_54E3AZ2FLZKc0fdxFOA",
    cloudName: "drqepoigy",
  );

  @override
  void initState() {
    super.initState();
    _loadTeamCode().then((_) => _fetchSharedDocuments());
  }

  Future<void> _loadTeamCode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teamCode = prefs.getInt('teamCode').toString();
      teamName = prefs.getString("teamName") ?? "UnKnown";
    });
  }

  Future<void> _fetchSharedDocuments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamCode)
          .collection('shared_documents')
          .get();

      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        return SharedDocument(
          data['name'] ?? '',
          data['type'] ?? '',
          data['lastModified'] ?? '',
          data['url'] ?? '',
        );
      }).toList();

      setState(() {
        sharedDocs = docs;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching documents: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> uploadDoc(File file) async {
    try {
      final response = await cloudinary.upload(
        file: file.path,
        fileBytes: await file.readAsBytes(),
        resourceType: CloudinaryResourceType.raw,
        folder: 'documents/doc',
        progressCallback: (count, total) {
          print('Uploading file with progress: $count/$total');
        },
      );

      if (response.isSuccessful) {
        print('File uploaded: ${response.url}');
        return response.secureUrl;
      } else {
        print('Upload failed: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }

  void _showUploadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Uploading..."),
            ],
          ),
        );
      },
    );
  }

  void _viewDocument(String url, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(url: url, name: name),
      ),
    );
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, size: 20, color: Colors.grey[600]),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx'],
                        );
                        if (result != null &&
                            result.files.single.path != null) {
                          File file = File(result.files.single.path!);

                          setState(() => isUploading = true);
                          _showUploadingDialog();

                          String? url = await uploadDoc(file);

                          if (url != null) {
                            final docRef = FirebaseFirestore.instance
                                .collection('teams')
                                .doc(teamCode)
                                .collection('shared_documents')
                                .doc();

                            await docRef.set({
                              'name': result.files.single.name
                                  .split('.')
                                  .first,
                              'type':
                                  result.files.single.extension ?? 'pdf',
                              'lastModified':
                                  DateTime.now().toIso8601String(),
                              'url': url,
                            });

                            await _fetchSharedDocuments();
                          }

                          if (mounted) {
                            Navigator.pop(context);
                            setState(() => isUploading = false);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(240, 238, 238, 1),
                    shape: BoxShape.circle,
                  ),
                  width: 200,
                  height: 200,
                  child: const Center(
                    child: Icon(Icons.picture_as_pdf, size: 100),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "SHARED DOCUMENTS",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 20),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : sharedDocs.isEmpty
                      ? const Center(child: Text("No documents found."))
                      : Column(
                          children: sharedDocs
                              .map((doc) => _buildDocumentTile(doc))
                              .toList(),
                        ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTile(SharedDocument doc) {
    return GestureDetector(
      onTap: () => _showOptionsBottomSheet(context, doc),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color.fromRGBO(240, 238, 238, 1),
              child: Text(
                doc.type.toUpperCase(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, var doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.remove_red_eye),
              title: const Text('View'),
              onTap: () {
                Navigator.pop(context);
                _viewDocument(doc.url, doc.name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final dir = await getTemporaryDirectory();
                  final fileExtension = doc.type.toLowerCase();
                  final fileName = '${doc.name}.$fileExtension';
                  final filePath = '${dir.path}/$fileName';

                  await Dio().download(doc.url, filePath);
                  await SharePlus.instance.share(
                    ShareParams(files: [XFile(filePath)]),
                  );
                } catch (e) {
                  print('Error sharing document: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class SharedDocument {
  String name;
  String type;
  String lastModified;
  String url;

  SharedDocument(this.name, this.type, this.lastModified, this.url);
}

class PDFViewerPage extends StatelessWidget {
  final String url;
  final String name;

  const PDFViewerPage({super.key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SfPdfViewer.network(url),
    );
  }
}
