# 📥 Flutter Download Manager Package

A powerful and easy-to-use Flutter package for handling background downloads with notifications, pause/resume support, permissions, and customizable UI widgets.  
This package wraps `flutter_downloader` + `flutter_local_notifications` with a simplified and developer-friendly API.

---

## 🚀 Features

- 🔄 Start / Pause / Resume / Cancel downloads  
- 📊 Real-time download progress stream  
- 🔔 Local notifications for progress & completion  
- 📁 Supports background download service  
- 🔐 Automatic permission handling  
- 🧩 Customizable download tile widget  
- 🎯 Clean and simple API for all platforms  

---

## 📦 Installation

Add this package to your Flutter project:

### **Add dependency in your pubspec.yaml:**

```yaml
dependencies:
  flutter_download_manager_pkg:
    path:".../flutter_download_manager/flutter_download_manager_pkg" # your path
```
### **Using GitHub (recommended during development)**
```yml
dependencies:
  flutter_download_manager_pkg:
    git:
      url: https://github.com/YOUR_USERNAME/flutter_download_manager_pkg.git
```
## ▶️ Usage
### 1. Import the package
```
import 'package:flutter_download_manager_pkg/flutter_download_manager_pkg.dart';
```
### 2. Initialize services (in main.dart)
```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  BackgroundService.register();
  await NotificationService.initialize();

  runApp(MyApp());
}
```
### 3. Start a Download
```
String url = "https://example.com/file.pdf";
String fileName = "file.pdf";

String? taskId = await DownloadService.startDownload(url, fileName);

if (taskId != null) {
  print("Download started with ID: $taskId");
}
```
### 4. Listen to Download Progress
```
DownloadService.listen((task) {
  print("Progress: ${task.progress}%");
  print("Status: ${task.status}");
});
```
### 5. Pause / Resume / Cancel
```
await DownloadService.pause(taskId);
await DownloadService.resume(taskId);
await DownloadService.cancel(taskId);
```
### 6. Using the Built-In Download Tile Widget
```
DownloadTile(
  task: task,
  onPause: () => DownloadService.pause(task.taskId),
  onResume: () => DownloadService.resume(task.taskId),
  onCancel: () => DownloadService.cancel(task.taskId),
)
```
## Demo Video


https://github.com/user-attachments/assets/49e84b61-5783-48be-8cab-3cb0ec45386d


## 📁 File Structure
```
lib/
 ├── flutter_download_manager_pkg.dart
 └── src/
     ├── services/
     │    ├── download_service.dart
     │    ├── background_service.dart
     │    ├── notification_service.dart
     │    └── permission_service.dart
     ├── models/
     │    └── download_task_model.dart
     └── widgets/
          └── download_tile.dart
```
## ⚙️ Android Setup (Important)
### Make sure your AndroidManifest.xml contains required permissions:
```
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```
### Add FileProvider:
```
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.flutter_downloader.provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```
## 📄 License
### This project is licensed under the MIT License.
``
Copyright (c) 2025 Excelsior Technologies

Permission is hereby granted, free of charge, to any person obtaining a copy  
of this software and associated documentation files (the "Software"), to deal  
in the Software without restriction, including without limitation the rights  
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
copies of the Software, and to permit persons to whom the Software is  
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all  
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED **"AS IS"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```
