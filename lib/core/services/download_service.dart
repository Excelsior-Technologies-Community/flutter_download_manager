// lib/core/services/download_service.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'notification_service.dart';

class DownloadService {
  static final Map<String, Timer> _timers = {};

  // ============================================================
  // START DOWNLOAD
  // ============================================================
  static Future<String?> startDownload(String url, String fileName) async {
    print('🚀 Starting download...');
    print('   URL: $url');
    print('   Filename: $fileName');

    final dir = await getExternalStorageDirectory();
    final savedDir =
        dir?.path ?? (await getApplicationDocumentsDirectory()).path;

    print('   Save directory: $savedDir');

    final directory = Directory(savedDir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: savedDir,
      fileName: fileName,
      showNotification: false,
      openFileFromNotification: false,
      timeout: 60000,
    );

    if (taskId != null) {
      print('✅ Task created: $taskId');
      _startMonitoring(taskId);
    } else {
      print('❌ Failed to create task');
    }

    return taskId;
  }

  // ============================================================
  // MONITOR DOWNLOAD PROGRESS
  // ============================================================
  static void _startMonitoring(String taskId) {
    print('👀 Starting monitoring for: $taskId');

    // Cancel existing timer if any
    _timers[taskId]?.cancel();

    // Create monitoring timer
    _timers[taskId] = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      try {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
          query: "SELECT * FROM task WHERE task_id='$taskId'",
        );

        if (tasks == null || tasks.isEmpty) {
          print('⚠️ No task found for: $taskId');
          timer.cancel();
          _timers.remove(taskId);
          return;
        }

        final task = tasks.first;
        final status = task.status;
        final progress = task.progress;
        final notificationId = taskId.hashCode;

        // Log less frequently for running
        if (status != DownloadTaskStatus.running || progress % 10 == 0) {
          print('📊 Task: $taskId | Status: $status | Progress: $progress%');
        }

        if (status == DownloadTaskStatus.running) {
          await NotificationService.showProgress(notificationId, progress, taskId);
        } else if (status == DownloadTaskStatus.paused) {
          await NotificationService.showPaused(notificationId, progress, taskId);
          // stop monitoring paused task (we will monitor the resumed newTaskId)
          timer.cancel();
          _timers.remove(taskId);
        } else if (status == DownloadTaskStatus.complete) {
          final filePath = '${task.savedDir}/${task.filename ?? 'file'}';
          await NotificationService.showComplete(notificationId, taskId, filePath);
          timer.cancel();
          _timers.remove(taskId);
        } else if (status == DownloadTaskStatus.failed) {
          await NotificationService.showFailed(notificationId, taskId);
          timer.cancel();
          _timers.remove(taskId);
        } else if (status == DownloadTaskStatus.canceled) {
          await NotificationService.cancelNotification(notificationId);
          timer.cancel();
          _timers.remove(taskId);
        }
      } catch (e) {
        print('❌ Error monitoring task: $e');
      }
    });
  }

  // ============================================================
  // PAUSE DOWNLOAD
  // ============================================================
  static Future<void> pause(String taskId) async {
    print('⏸️ Pausing download: $taskId');
    try {
      // stop monitoring immediately (status will change to paused)
      _timers[taskId]?.cancel();
      _timers.remove(taskId);

      await FlutterDownloader.pause(taskId: taskId);
      print('✅ Download paused successfully');
    } catch (e) {
      print('❌ Error pausing download: $e');
    }
  }

  // ============================================================
  // RESUME DOWNLOAD
  // ============================================================
  static Future<void> resume(String taskId) async {
    print('▶️ Resuming download: $taskId');
    try {
      // When resuming, FlutterDownloader returns a new taskId (or null if failed)
      final newTaskId = await FlutterDownloader.resume(taskId: taskId);

      if (newTaskId != null && newTaskId.isNotEmpty) {
        print('✅ Download resumed with new taskId: $newTaskId');

        // Ensure any leftover timer for previous id is stopped
        _timers[taskId]?.cancel();
        _timers.remove(taskId);

        // Start monitoring the resumed task id
        _startMonitoring(newTaskId);
      } else {
        print('❌ Failed to resume download (no new task id returned)');
      }
    } catch (e) {
      print('❌ Error resuming download: $e');
    }
  }

  // ============================================================
  // CANCEL DOWNLOAD
  // ============================================================
  static Future<void> cancel(String taskId) async {
    print('❌ Canceling download: $taskId');
    try {
      // stop monitoring first
      _timers[taskId]?.cancel();
      _timers.remove(taskId);

      await FlutterDownloader.cancel(taskId: taskId);
      await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
      await NotificationService.cancelNotification(taskId.hashCode);

      print('✅ Download canceled successfully');
    } catch (e) {
      print('❌ Error canceling download: $e');
    }
  }
}
