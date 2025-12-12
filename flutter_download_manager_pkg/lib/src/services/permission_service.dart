// lib/core/services/permission_service.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermissionsSafe() async {
    // Storage permission (needed on older Android; on Android 11+ app-specific dir doesn't require runtime)
    await Permission.storage.request();

    // Android 13+ notifications
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
