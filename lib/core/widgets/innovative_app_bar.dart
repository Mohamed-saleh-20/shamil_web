// lib/core/widgets/innovative_app_bar.dart

import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamil_web/core/constants/app_assets.dart';
import 'package:shamil_web/core/constants/app_dimensions.dart';
import 'package:shamil_web/core/widgets/language_switcher.dart';
import 'package:shamil_web/core/widgets/theme_switcher.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// 🚀 INNOVATIVE APP BAR WITH ROTATING LOGO & DOWNLOAD FEATURE 🚀
/// Features: Continuous logo rotation, glassmorphism design, smart download system
class InnovativeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final ScrollController scrollController;
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback? onLanguageToggle;
  final VoidCallback? onThemeToggle;

  const InnovativeAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    required this.scrollController,
    this.isDarkMode = false,
    this.currentLanguage = 'en',
    this.onLanguageToggle,
    this.onThemeToggle,
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
  late AnimationController _appBarAnimationController;
  late AnimationController _downloadController;
  
  // 📊 State Variables
  double _scrollOffset = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    
    // 🔄 Continuous Logo Rotation (Never stops!)
    _logoRotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    // 📜 Scroll-aware animations for the AppBar itself
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 📥 Download button animation
    _downloadController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 👂 Listen to scroll changes from the parent's ScrollController
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _logoRotationController.dispose();
    _appBarAnimationController.dispose();
    _downloadController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  // 📜 Handle scroll changes for dynamic effects
  void _onScroll() {
    final offset = widget.scrollController.offset;
    if (mounted) {
      setState(() {
        _scrollOffset = offset;
      });
    }
    
    // 🌊 Animate AppBar based on scroll
    if (offset > 100) {
      if (mounted) _appBarAnimationController.forward();
    } else {
      if (mounted) _appBarAnimationController.reverse();
    }
  }

  // 📥 Smart Download Handler
  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    
    if (mounted) setState(() => _isDownloading = true);
    if (mounted) _downloadController.forward();
    
    try {
      await _showDownloadOptions();
    } catch (e) {
      if (mounted) _showErrorSnackBar('Download failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
        _downloadController.reverse();
      }
    }
  }

  // 📱 Show Download Options Dialog
  Future<void> _showDownloadOptions() async {
    final theme = Theme.of(context);
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);
    
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => Dialog(
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
                    onPressed: () => Navigator.pop(dialogContext),
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
                () => _downloadFile('android', dialogContext),
              ),
              
              const SizedBox(height: 12),
              
              _buildDownloadOption(
                'Windows EXE',
                'shamil-app-windows.exe',
                Icons.desktop_windows_rounded,
                Colors.blue,
                () => _downloadFile('windows', dialogContext),
              ),
              
              const SizedBox(height: 12),
              
              _buildDownloadOption(
                'macOS DMG',
                'shamil-app-macos.dmg',
                Icons.laptop_mac_rounded,
                Colors.grey.shade700,
                () => _downloadFile('macos', dialogContext),
              ),
              
              const SizedBox(height: 12),
              
              _buildDownloadOption(
                'iOS IPA',
                'shamil-app-ios.ipa',
                Icons.phone_iphone_rounded,
                Colors.black,
                () => _downloadFile('ios', dialogContext),
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
  Future<void> _downloadFile(String platform, BuildContext dialogContext) async {
    Navigator.pop(dialogContext);
    
    if (!mounted) return;

    try {
      final String content = _generateAppFileContent(platform);
      final List<int> bytes = content.codeUnits;
      
      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/octet-stream');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'shamil-app-$platform.${_getFileExtension(platform)}')
        ..click();
      
      html.Url.revokeObjectUrl(url);
      
      if (mounted) _showSuccessSnackBar('Download started successfully!');
      
    } catch (e) {
      if (mounted) _showErrorSnackBar('Download failed. Please try again.');
    }
  }

  // 📝 Generate Sample App Content
  String _generateAppFileContent(String platform) {
    return '''
# Shamil App - $platform Version (Sample Placeholder)

This is a placeholder file for the Shamil App ${platform.toUpperCase()} version.
In a real application, this would be the actual application binary.

Platform: ${platform.toUpperCase()}
Version: 1.0.0
Build Date: ${DateTime.now().toIso8601String()}

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

  void _showSnackBar(String message, Color backgroundColor, IconData iconData) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ✅ Show Success Message
  void _showSuccessSnackBar(String message) {
    _showSnackBar(message, Colors.green, Icons.check_circle_rounded);
  }

  // ❌ Show Error Message
  void _showErrorSnackBar(String message) {
    _showSnackBar(message, Colors.red, Icons.error_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);
    
    // 🌊 Dynamic background opacity based on scroll
    final backgroundOpacity = _appBarAnimationController.drive(Tween<double>(begin: 0.0, end: 0.95)).value;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_appBarAnimationController, _logoRotationController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
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
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.primary.withOpacity(backgroundOpacity * 0.2),
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
            leadingWidth: isMobile ? 60 : 80,
            leading: Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: _logoRotationController.value * 2 * math.pi,
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
            
            // 🏷️ Title (Hidden on mobile to save space)
            title: !isMobile ? Text(
              widget.title, // Use the title from widget properties
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ) : null,
            
            // ⚙️ Actions
            actions: [
              if (!isMobile) ...[
                // 📥 Download Button for desktop
                AnimatedBuilder(
                  animation: _downloadController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_downloadController.value * 0.05),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppDimensions.paddingSmall),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleDownload,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingMedium,
                                vertical: AppDimensions.paddingSmall,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
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
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.download_rounded,
                                      color: theme.colorScheme.onPrimary,
                                      size: 18,
                                    ),
                                  const SizedBox(width: AppDimensions.paddingSmall),
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
                const SizedBox(width: AppDimensions.paddingSmall),
                
                // 🌙 Theme Switcher
                const ThemeSwitcher(),
              ] else ...[
                // 📱 Mobile Menu Button
                IconButton(
                  onPressed: widget.onMenuTap,
                  icon: Icon(
                    Icons.menu_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
              ],
              const SizedBox(width: AppDimensions.paddingSmall),
            ],
          ),
        );
      },
    );
  }
}