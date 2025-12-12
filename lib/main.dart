import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'core/services/notification_service.dart';
import 'core/services/download_service.dart';
import 'core/services/background_service.dart';
import 'presentation/screens/download_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🎯 Initializing app...');

  // 1. Initialize flutter_downloader
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  print('✅ FlutterDownloader initialized');

  // 2. Register background callback
  FlutterDownloader.registerCallback(BackgroundService.downloadCallback);
  print('✅ Background callback registered');

  // 3. Initialize background service (port listener)
  await BackgroundService.initialize();
  print('✅ BackgroundService initialized');

  // 4. Initialize notifications
  await NotificationService.initialize();
  print('✅ NotificationService initialized');

  // 5. 🔥 Register notification action callbacks BEFORE runApp
  NotificationService.registerCallbacks(
    onPause: (taskId) async {
      print('🎯 MAIN: Pause button clicked for $taskId');
      await DownloadService.pause(taskId);
    },
    onResume: (taskId) async {
      print('🎯 MAIN: Resume button clicked for $taskId');
      await DownloadService.resume(taskId);
    },
    onCancel: (taskId) async {
      print('🎯 MAIN: Cancel button clicked for $taskId');
      await DownloadService.cancel(taskId);
    },
  );
  print('✅ Notification callbacks registered');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const DownloadManager(),
    );
  }
}