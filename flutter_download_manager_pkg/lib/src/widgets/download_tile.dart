import 'package:flutter/material.dart';

class DownloadTile extends StatelessWidget {
  final String fileName;
  final int progress;
  final bool isRunning;
  final bool isPaused;

  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  const DownloadTile({
    super.key,
    required this.fileName,
    required this.progress,
    required this.isRunning,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 6),

            LinearProgressIndicator(value: progress / 100),

            const SizedBox(height: 8),
            Text("$progress%"),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isRunning)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: onPause,
                  ),

                if (isPaused)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: onResume,
                  ),

                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: onCancel,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
