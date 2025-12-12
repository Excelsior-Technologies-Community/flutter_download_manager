// lib/core/services/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // Callbacks for pause/resume/cancel (registered from main)
  static Function(String taskId)? _onPauseCallback;
  static Function(String taskId)? _onResumeCallback;
  static Function(String taskId)? _onCancelCallback;

  // ============================================================
  // PUBLIC INITIALIZE
  // ============================================================
  static Future<void> initialize() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    // Foreground tap / action handler
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationAction,
      // Background handler must be provided as well (top-level wrapper below will call into here)
      onDidReceiveBackgroundNotificationResponse:
      onDidReceiveBackgroundNotificationResponse,
    );

    await _createChannels();
  }

  // Register callbacks from main.dart
  static void registerCallbacks({
    required Function(String) onPause,
    required Function(String) onResume,
    required Function(String) onCancel,
  }) {
    _onPauseCallback = onPause;
    _onResumeCallback = onResume;
    _onCancelCallback = onCancel;
    print('✅ NotificationService: Callbacks registered');
  }

  static Future<void> _createChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return;

    await android.createNotificationChannel(const AndroidNotificationChannel(
      'download_progress',
      'Downloading',
      description: 'Shows active download progress',
      importance: Importance.low,
      playSound: false,
    ));

    await android.createNotificationChannel(const AndroidNotificationChannel(
      'download_complete',
      'Download Complete',
      description: 'Shows completed downloads',
      importance: Importance.high,
      playSound: true,
    ));
  }

  // ============================================================
  // TOP-LEVEL HANDLER (foreground & background will call this)
  // ============================================================
  // Note: Flutter Local Notifications requires a top-level or static function
  // reference for background handling. We provide a wrapper below that calls this.
  static Future<void> handleNotificationResponse(
      NotificationResponse response) async {
    print('🔔 Notification action received');
    print('   Action ID: ${response.actionId}');
    print('   Payload: ${response.payload}');

    final actionId = response.actionId;
    final payload = response.payload;

    if (payload == null || actionId == null) {
      print('⚠️ No payload or actionId');
      return;
    }

    // payload format examples:
    // running:<taskId>
    // paused:<taskId>
    // complete:<filePath>  (view uses filePath)
    // failed:<taskId>
    // canceled:<taskId>

    // If payload contains ":" we parse accordingly.
    final parts = payload.split(':');
    if (parts.isEmpty) return;

    // For 'complete' the rest (after ':') is file path; for running/paused/canceled it's taskId.
    final tag = parts[0];
    final rest = parts.sublist(1).join(':');

    switch (actionId) {
      case 'pause':
        print('⏸️ Pause action triggered for $rest');
        await _onPauseCallback?.call(rest);
        break;

      case 'resume':
        print('▶️ Resume action triggered for $rest');
        await _onResumeCallback?.call(rest);
        break;

      case 'cancel':
        print('❌ Cancel action triggered for $rest');
        await _onCancelCallback?.call(rest);
        break;

      case 'view':
        print('👁️ View action triggered for $rest');
        if (tag == 'complete') {
          final filePath = rest;
          await _openFile(filePath);
        } else {
          // sometimes payload may be direct file path
          await _openFile(rest);
        }
        break;

      default:
        print('⚠️ Unknown action: $actionId');
    }
  }

  // Foreground handler used by plugin (calls the static handler)
  static Future<void> _handleNotificationAction(
      NotificationResponse response) async {
    await handleNotificationResponse(response);
  }

  // ============================================================
  // SHOW PROGRESS / PAUSED / COMPLETE / FAILED
  // ============================================================
  static Future<void> showProgress(int id, int progress, String taskId) async {
    final android = AndroidNotificationDetails(
      'download_progress',
      'Downloading',
      channelDescription: 'Active download progress',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'pause',
          'Pause',
          // Leave showsUserInterface false so the action is handled in background
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'cancel',
          'Cancel',
          showsUserInterface: false,
          cancelNotification: false,
        ),
      ],
    );

    await _plugin.show(
      id,
      'Downloading',
      '$progress%',
      NotificationDetails(android: android),
      payload: 'running:$taskId',
    );
  }

  static Future<void> showPaused(int id, int progress, String taskId) async {
    final android = AndroidNotificationDetails(
      'download_progress',
      'Download Paused',
      channelDescription: 'Paused download',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: false,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'resume',
          'Resume',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'cancel',
          'Cancel',
          showsUserInterface: false,
          cancelNotification: false,
        ),
      ],
    );

    await _plugin.show(
      id,
      'Download Paused',
      '$progress%',
      NotificationDetails(android: android),
      payload: 'paused:$taskId',
    );
  }

  static Future<void> showComplete(
      int id, String taskId, String filePath) async {
    final fileName = filePath.split('/').last;

    final android = AndroidNotificationDetails(
      'download_complete',
      'Download Complete',
      channelDescription: 'Your file is ready',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'view',
          'View',
          showsUserInterface: true, // open app / UI
        ),
      ],
    );

    await _plugin.show(
      id,
      'Download Complete',
      fileName,
      NotificationDetails(android: android),
      payload: 'complete:$filePath',
    );
  }

  static Future<void> showFailed(int id, String taskId) async {
    final android = AndroidNotificationDetails(
      'download_complete',
      'Download Failed',
      channelDescription: 'Download failed',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id,
      'Download Failed',
      'Something went wrong',
      NotificationDetails(android: android),
      payload: 'failed:$taskId',
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  // ============================================================
  // OPEN FILE
  // ============================================================
  static Future<void> _openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ File not found: $filePath');
        return;
      }
      print('📂 Opening file: $filePath');
      await OpenFile.open(filePath);
    } catch (e) {
      print('❌ Error opening file: $e');
    }
  }

  static Future<void> handleDownloadStatus({
    required String id,
    required DownloadTaskStatus status,
    required int progress,
    String? filePath,
  }) async {
    final notiId = id.hashCode;

    switch (status) {
      case DownloadTaskStatus.running:
        await showProgress(notiId, progress, id);
        break;

      case DownloadTaskStatus.paused:
        await showPaused(notiId, progress, id);
        break;

      case DownloadTaskStatus.complete:
        if (filePath != null) {
          await showComplete(notiId, id, filePath);
        }
        break;

      case DownloadTaskStatus.failed:
        await showFailed(notiId, id);
        break;

      case DownloadTaskStatus.canceled:
        await cancelNotification(notiId);
        break;

      default:
        break;
    }
  }

}

// ============================================================
// TOP-LEVEL BACKGROUND CALLBACK WRAPPER
// Must be a top-level function and annotated as entry-point so it works
// when app is terminated or backgrounded.
// ============================================================
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  // Forward to our handler. This is a top-level entry so it won't get tree-shaken.
  NotificationService.handleNotificationResponse(response);
}
