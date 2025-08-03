import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android_package_installer/android_package_installer.dart';
import 'package:path_provider/path_provider.dart';

// Black and White Theme Constants
class BWTheme {
  static const Color background = Color(0xFF000000); // Pure black
  static const Color surface = Color(0xFF1A1A1A); // Dark gray
  static const Color cardBackground = Color(0xFF2A2A2A); // Medium gray
  static const Color border = Color(0xFF404040); // Light gray
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFB0B0B0); // Light gray
  static const Color accent = Color(0xFFFFFFFF); // White accent
  static const Color success = Color(0xFFFFFFFF); // White for success
  static const Color disabled = Color(0xFF808080); // Medium gray
}

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isUpdating = false;
  bool _isCheckingUpdate = false;
  double _updateProgress = 0.0;
  String? _currentVersion;
  String? _latestVersion;
  final bool _hasUpdate = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentVersion();
    _checkAndUpdate();
     
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentVersion() async {
    
     
  }

  bool _isVersionNewer(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      }
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  Future<void> downloadAndInstallApk(String apkUrl) async {
    try {
      final dir = await getExternalStorageDirectory();
      final apkPath = '${dir!.path}/update.apk';
      final file = File(apkPath);
      final request = await HttpClient().getUrl(Uri.parse(apkUrl));
      final response = await request.close();
      final totalBytes = response.contentLength;
      int receivedBytes = 0;

      final sink = file.openWrite();
      await for (var chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        if (mounted) {
          setState(() {
            _updateProgress = receivedBytes / totalBytes;
          });
        }
      }
      await sink.close();

      // Haptic feedback on completion
      HapticFeedback.mediumImpact();
      int? statusCode = await AndroidPackageInstaller.installApk(
        apkFilePath: apkPath,
      );
      if (statusCode != null) {
        PackageInstallerStatus installationStatus =
            PackageInstallerStatus.byCode(statusCode);
        print(installationStatus.name);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to download update');
        setState(() {
          _isUpdating = false;
          _updateProgress = 0.0;
        });
      }
    }
  }

  Future<void> _checkAndUpdate() async {
    setState(() => _isCheckingUpdate = true);

    try {
       
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('update_info')
          .get();

      final latestVersion = doc.data()?['latest_version'];
      final apkUrl = doc.data()?['apk_url'];

      setState(() {
        _latestVersion = latestVersion;
        _isCheckingUpdate = false;
      });

       
    } catch (e) {
      setState(() => _isCheckingUpdate = false);
      _showErrorSnackBar('Failed to check for updates');
    }
  }

  Future<void> _startUpdate() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('update_info')
          .get();
      final apkUrl = doc.data()?['apk_url'];

      if (apkUrl != null) {
        setState(() => _isUpdating = true);
        await downloadAndInstallApk(apkUrl);
      } else {
        _showErrorSnackBar('Update URL not found');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to start update');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: BWTheme.success),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: BWTheme.textPrimary)),
          ],
        ),
        backgroundColor: BWTheme.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: BWTheme.textSecondary),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: BWTheme.textPrimary)),
          ],
        ),
        backgroundColor: BWTheme.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildUpdateIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  BWTheme.accent.withOpacity(0.2),
                  BWTheme.accent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: BWTheme.accent.withOpacity(0.3)),
            ),
            child: Icon(
              _hasUpdate ? Icons.system_update : Icons.system_update_alt,
              size: 40,
              color: BWTheme.accent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BWTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BWTheme.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Version',
                style: TextStyle(
                  color: BWTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _currentVersion ?? 'Unknown',
                style: const TextStyle(
                  color: BWTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (_latestVersion != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Version',
                  style: TextStyle(
                    color: BWTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _latestVersion!,
                  style: TextStyle(
                    color: _hasUpdate ? BWTheme.accent : BWTheme.success,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _updateProgress,
                  strokeWidth: 6,
                  backgroundColor: BWTheme.border,
                  valueColor: AlwaysStoppedAnimation<Color>(BWTheme.accent),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${(_updateProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: BWTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Downloading Update...',
          style: TextStyle(
            color: BWTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please don\'t close the app',
          style: TextStyle(
            color: BWTheme.textSecondary.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (_isCheckingUpdate) {
      return Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: BWTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BWTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(BWTheme.accent),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Checking for updates...',
              style: TextStyle(
                color: BWTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasUpdate) {
      return SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isUpdating ? null : _startUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: BWTheme.accent,
            foregroundColor: BWTheme.background,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            disabledBackgroundColor: BWTheme.disabled,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.download, size: 20),
              const SizedBox(width: 8),
              Text(
                'Install Update',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: BWTheme.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            "Already up to date",
            style: TextStyle(fontSize: 20, color: BWTheme.success),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BWTheme.background,
      appBar: AppBar(
        title: const Text(
          'App Update',
          style: TextStyle(
            color: BWTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: BWTheme.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: BWTheme.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Center(
        heightFactor: 1,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildUpdateIcon(),
                  const SizedBox(height: 32),
                  if (_isUpdating) ...[
                    _buildProgressIndicator(),
                  ] else ...[
                    Text(
                      _hasUpdate
                          ? 'Update Available!'
                          : 'Keep Your App Updated',
                      style: TextStyle(
                        color: BWTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasUpdate
                          ? 'A new version is available with improvements and bug fixes.'
                          : 'Check for the latest version to get new features and improvements.',
                      style: TextStyle(
                        color: BWTheme.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildVersionInfo(),
                    const SizedBox(height: 32),
                    _buildActionButton(),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to create the update document (call this once to set up)
Future<void> createUpdateDocument() async {
  await FirebaseFirestore.instance
      .collection('app_config')
      .doc('update_info')
      .set({
        'latest_version': '1.0.0',
        'apk_url': 'https://yourdomain.com/path/to/update.apk',
      });
}
