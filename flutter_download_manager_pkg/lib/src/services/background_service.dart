// lib/core/services/background_service.dart
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'notification_service.dart';

class BackgroundService {
  static final ReceivePort _port = ReceivePort();

  static Future<void> initialize() async {
    const String portName = 'downloader_port';

    // clean old mapping if exists (prevents double registration crashes)
    final old = IsolateNameServer.lookupPortByName(portName);
    if (old != null) {
      IsolateNameServer.removePortNameMapping(portName);
    }

    // register fresh port
    IsolateNameServer.registerPortWithName(_port.sendPort, portName);

    // listen to callback messages from background isolate
    _port.listen((message) {
      try {
        final String id = message[0] as String;
        final int rawStatus = message[1] as int;
        final int progress = message[2] as int;

        final status = DownloadTaskStatus.values[rawStatus];

        NotificationService.handleDownloadStatus(
          id: id,
          status: status,
          progress: progress,
        );
      } catch (e) {
        // ignore parse errors
      }
    });
  }

  // must be top-level static and annotated
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
    IsolateNameServer.lookupPortByName('downloader_port');
    send?.send([id, status, progress]);
  }
}
