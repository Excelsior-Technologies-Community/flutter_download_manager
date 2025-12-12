import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadTaskModel {
  final String taskId;
  final String fileName;
  final String url;
  final int progress;
  final DownloadTaskStatus status;

  DownloadTaskModel({
    required this.taskId,
    required this.fileName,
    required this.url,
    required this.progress,
    required this.status,
  });

  /// Convert flutter_downloader DownloadTask → DownloadTaskModel
  factory DownloadTaskModel.fromTask(DownloadTask task) {
    return DownloadTaskModel(
      taskId: task.taskId,
      fileName: task.filename ?? task.url.split('/').last,
      url: task.url,
      progress: task.progress,
      status: task.status,
    );
  }
}
