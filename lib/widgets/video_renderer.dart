import 'package:flutter/material.dart';

class VideoRenderer extends StatefulWidget {
  final dynamic stream;
  final bool isLocalStream;
  final bool isMuted;
  final bool isCameraOff;

  const VideoRenderer({
    Key? key,
    required this.stream,
    this.isLocalStream = false,
    this.isMuted = false,
    this.isCameraOff = false,
  }) : super(key: key);

  @override
  State<VideoRenderer> createState() => _VideoRendererState();
}

class _VideoRendererState extends State<VideoRenderer> {
  @override
  Widget build(BuildContext context) {
    if (widget.isCameraOff) {
      return _buildCameraOffPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Mock video stream
            Center(
              child: Icon(
                widget.isLocalStream ? Icons.person : Icons.people,
                size: 48,
                color: Colors.white,
              ),
            ),

            // User label
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.isLocalStream ? 'You' : 'User',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

            // Muted indicator
            if (widget.isMuted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.mic_off,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraOffPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white, size: 48),
        ),
      ),
    );
  }
}
