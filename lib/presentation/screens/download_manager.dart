import 'package:flutter/material.dart';
import 'package:flutter_download_manager/core/services/permission_service.dart';
import '../../core/services/download_service.dart';

class DownloadManager extends StatefulWidget {
  const DownloadManager({super.key});

  @override
  State<DownloadManager> createState() => _DownloadManagerState();
}

class _DownloadManagerState extends State<DownloadManager> {
  final urlCtrl = TextEditingController();
  final fileCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    PermissionService.requestPermissionsSafe();
  }

  Future<void> startDownload() async {
    final url = urlCtrl.text.trim();
    final fileName = fileCtrl.text.trim().isEmpty
        ? url.split("/").last
        : fileCtrl.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("URL enter karein!")),
      );
      return;
    }

    try {
      print('🚀 Starting download...');
      print('📎 URL: $url');
      print('📄 File: $fileName');

      final taskId = await DownloadService.startDownload(url, fileName);

      if (taskId != null) {
        print('✅ Task ID: $taskId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download started! Task: $taskId")),
        );
      } else {
        print('❌ Task ID is null!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Download start failed!")),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            children: [
              Text('Download Manager',style: TextStyle(fontSize: 30),),
              SizedBox(height: 16),
              TextField(
                controller: urlCtrl,
                decoration: InputDecoration(
                  labelText: "Enter File URL",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // TextField(
              //   controller: fileCtrl,
              //   decoration: InputDecoration(
              //     labelText: "File Name (optional)",
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              // ),
              //
              // const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: startDownload,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Start Download",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
        ),
      ),
    );
  }
}