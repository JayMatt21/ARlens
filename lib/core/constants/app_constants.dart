import 'package:flutter/material.dart';

/// All app-wide constants are defined here.
/// Use [AppConstants] instead of hardcoding values across the app.
class AppConstants {
  // 📌 App Info
  static const String appName = "Area Calculator";

  // 📌 Feature Messages
  static const String cameraComingSoon = "Camera feature coming soon";
  static const String galleryComingSoon = "Gallery feature coming soon";

  // 📌 Error Messages
  static const String errorNoFlutterSdk =
      "Flutter SDK not found. Define location with flutter.sdk in the local.properties file.";

  // 📌 Default Values
  static const String defaultUnit = "sq.m";

  // 📌 Colors
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.orange;
}
