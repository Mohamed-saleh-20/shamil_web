// lib/core/widgets/innovative_app_bar.dart

import 'dart:html' as html; // 📁 For web file downloads
// 📊 For binary data handling
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🎨 For loading assets
import 'package:shamil_web/core/constants/app_assets.dart';
import 'package:shamil_web/core/constants/app_dimensions.dart';
import 'package:shamil_web/core/widgets/language_switcher.dart';
import 'package:shamil_web/core/widgets/theme_switcher.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// 🚀 INNOVATIVE APP BAR WITH ROTATING LOGO & DOWNLOAD FEATURE 🚀
/// Features: Continuous logo rotation, glassmorphism design, smart download system
class InnovativeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final VoidCallback? onMenuTap;

  const InnovativeAppBar({
    super.key,
    required this.scrollController,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<InnovativeAppBar> createState() => _InnovativeAppBarState();
}

class _InnovativeAppBarState extends State<InnovativeAppBar>
    with TickerProviderStateMixin {
  
  // 🎭 Animation Controllers
  late AnimationController _logoRotationController;
  late AnimationController _scrollController;
  late AnimationController _downloadController;
  
  // 📊 State Variables
  double _scrollOffset = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    
    // 🔄 Continuous Logo Rotation (Never stops!)
    _logoRotationController = AnimationController(
      duration: const Duration(seconds: 8), // Smooth 8-second rotation
      vsync: this,
    )..repeat(); // 🔁 Loop forever!
    
    // 📜 Scroll-aware animations
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 📥 Download button animation
    _downloadController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 👂 Listen to scroll changes
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _logoRotationController.dispose();
    _scrollController.dispose();
    _downloadController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  // 📜 Handle scroll changes for dynamic effects
  void _onScroll() {
    final offset = widget.scrollController.offset;
    setState(() {
      _scrollOffset = offset;
    });
    
    // 🌊 Animate AppBar based on scroll
    if (offset > 100) {
      _scrollController.forward();
    } else {
      _scrollController.reverse();
    }
  }

  // 📥 Smart Download Handler
  Future<void> _handleDownload() async {
    if (_isDownloading) return; // 🚫 Prevent multiple downloads
    
    setState(() => _isDownloading = true);
    _downloadController.forward();
    
    try {
      // 🎯 Show download options dialog
      await _showDownloadOptions();
    } catch (e) {
      // ❌ Handle download error
      _showErrorSnackBar('Download failed. Please try again.');
    } finally {
      setState(() => _isDownloading = false);
      _downloadController.reverse();
    }
  }

  // 📱 Show Download Options Dialog
  Future<void> _showDownloadOptions() async {
    final theme = Theme.of(context);
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);
    
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isMobile ? double.infinity : 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.light
                  ? [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.85),
                    ]
                  : [
                      Colors.grey.shade900.withOpacity(0.95),
                      Colors.black.withOpacity(0.9),
                    ],
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎯 Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download Shamil App',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Choose your platform',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 📱 Download Options
              _buildDownloadOption(
                'Android APK',
                'shamil-app-android.apk',
                Icons.android_rounded,
                theme.colorScheme.primary,
                () => _downloadFile('android'),
              ),
              
              const SizedBox(height: 12),
              
              _buildDownloadOption(
                'Windows EXE',
                'shamil-app-windows.exe',
                Icons.desktop_windows_rounded,
                Colors.blue,
                () => _downloadFile('windows'),
              ),
              
              const SizedBox(height: 12),
              
              _buildDownloadOption(
                'macOS DMG',
                'shamil-app-macos.dmg',
                Icons.laptop_mac_rounded,
                Colors.grey.shade700,
                () => _downloadFile('macos'),
              ),
              
              const SizedBox(height: 12),
              
              _buildDownloadOption(
                'iOS IPA',
                'shamil-app-ios.ipa',
                Icons.phone_iphone_rounded,
                Colors.black,
                () => _downloadFile('ios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📦 Build Download Option Widget
  Widget _buildDownloadOption(
    String title,
    String filename,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            color: theme.colorScheme.surface.withOpacity(0.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: iconColor.withOpacity(0.1),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      filename,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📁 Download File Function
  Future<void> _downloadFile(String platform) async {
    Navigator.pop(context); // Close dialog
    
    try {
      // 🎯 Create sample file content (replace with actual app files)
      final String content = _generateAppFileContent(platform);
      final List<int> bytes = content.codeUnits;
      
      // 📦 Create blob and download
      final blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // 📥 Trigger download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'shamil-app-$platform.${_getFileExtension(platform)}')
        ..click();
      
      // 🧹 Cleanup
      html.Url.revokeObjectUrl(url);
      
      // ✅ Show success message
      _showSuccessSnackBar('Download started successfully!');
      
    } catch (e) {
      // ❌ Handle error
      _showErrorSnackBar('Download failed. Please try again.');
    }
  }

  // 📝 Generate Sample App Content (Replace with actual app binaries)
  String _generateAppFileContent(String platform) {
    return '''
# Shamil App - $platform Version

Welcome to Shamil App!

Platform: ${platform.toUpperCase()}
Version: 1.0.0
Build Date: ${DateTime.now().toString()}

## Features:
- Book services easily
- Manage appointments
- Secure payments
- Real-time notifications
- Multi-language support

## Installation Instructions:
1. Download the file
2. Install according to your platform requirements
3. Launch the app
4. Create your account
5. Start booking services!

Thank you for choosing Shamil App!

---
© ${DateTime.now().year} Shamil App. All rights reserved.
    ''';
  }

  // 📋 Get File Extension
  String _getFileExtension(String platform) {
    switch (platform) {
      case 'android': return 'apk';
      case 'windows': return 'exe';
      case 'macos': return 'dmg';
      case 'ios': return 'ipa';
      default: return 'txt';
    }
  }

  // ✅ Show Success Message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ❌ Show Error Message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);
    
    // 🌊 Dynamic background opacity based on scroll
    final backgroundOpacity = (_scrollOffset / 200).clamp(0.0, 0.95);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scrollController, _logoRotationController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            // 🌈 Glassmorphism background
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.brightness == Brightness.light
                  ? [
                      Colors.white.withOpacity(backgroundOpacity),
                      Colors.white.withOpacity(backgroundOpacity * 0.8),
                    ]
                  : [
                      Colors.black.withOpacity(backgroundOpacity),
                      Colors.grey.shade900.withOpacity(backgroundOpacity * 0.8),
                    ],
            ),
            // ✨ Dynamic border
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.primary.withOpacity(backgroundOpacity * 0.3),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            
            // 🎯 Leading: Rotating Logo
            leading: Container(
              padding: const EdgeInsets.all(12),
              child: Transform.rotate(
                angle: _logoRotationController.value * 2 * 3.14159, // 🔄 Full rotation
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.rocket_launch_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
            
            // 🏷️ Title (Hidden on mobile)
            title: !isMobile ? Text(
              'Shamil',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ) : null,
            
            // ⚙️ Actions
            actions: [
              if (!isMobile) ...[
                // 📥 Download Button
                AnimatedBuilder(
                  animation: _downloadController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_downloadController.value * 0.1),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleDownload,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isDownloading)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.download_rounded,
                                      color: theme.colorScheme.onPrimary,
                                      size: 18,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isDownloading ? 'Downloading...' : 'Download',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // 🌐 Language Switcher
                const LanguageSwitcher(),
                
                // 🌙 Theme Switcher
                const ThemeSwitcher(),
              ] else
                // 📱 Mobile Menu Button
                IconButton(
                  onPressed: widget.onMenuTap,
                  icon: Icon(
                    Icons.menu_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              
              const SizedBox(width: AppDimensions.paddingMedium),
            ],
          ),
        );
      },
    );
  }
}