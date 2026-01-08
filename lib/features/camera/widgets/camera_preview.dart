import 'package:flutter/material.dart';

class DebugCameraPreview extends StatelessWidget {
  const DebugCameraPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.videocam, size: 60, color: Colors.white30),
            SizedBox(height: 12),
            Text(
              "CAMERA PREVIEW",
              style: TextStyle(
                color: Colors.white38,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

