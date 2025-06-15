import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/webrtc_service.dart';
import '../widgets/video_renderer.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId;

  const MeetingScreen({
    Key? key,
    required this.meetingId,
  }) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late WebRTCService _webRTCService;
  bool _isJoining = true;

  @override
  void initState() {
    super.initState();
    _webRTCService = Provider.of<WebRTCService>(context, listen: false);
    _joinMeeting();
  }

  Future<void> _joinMeeting() async {
    try {
      await _webRTCService.joinMeeting(widget.meetingId);
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join meeting: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _webRTCService.leaveMeeting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting: ${widget.meetingId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            color: Colors.red,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _isJoining
          ? const Center(child: CircularProgressIndicator())
          : Consumer<WebRTCService>(
              builder: (context, webRTCService, child) {
                final localStream = webRTCService.localStream;
                final remoteStreams = webRTCService.remoteStreams;

                return Column(
                  children: [
                    Expanded(
                      child: remoteStreams.isEmpty
                          ? const Center(
                              child: Text(
                                'Waiting for others to join...',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : _buildVideoGrid(remoteStreams),
                    ),
                    _buildLocalVideoPreview(localStream, webRTCService),
                    _buildControlBar(webRTCService),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildVideoGrid(Map<String, dynamic> remoteStreams) {
    final streams = remoteStreams.entries.toList();

    if (streams.isEmpty) {
      return const Center(
        child: Text(
          'No participants yet',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: streams.length == 1 ? 1 : 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: streams.length,
      itemBuilder: (context, index) {
        final stream = streams[index].value;
        return VideoRenderer(
          stream: stream,
          isLocalStream: false,
          isMuted: false,
          isCameraOff: false,
        );
      },
    );
  }

  Widget _buildLocalVideoPreview(dynamic localStream, WebRTCService webRTCService) {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(8.0),
      child: VideoRenderer(
        stream: localStream,
        isLocalStream: true,
        isMuted: !webRTCService.isMicEnabled,
        isCameraOff: !webRTCService.isCameraEnabled,
      ),
    );
  }

  Widget _buildControlBar(WebRTCService webRTCService) {
    return Container(
      height: 80,
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: webRTCService.isMicEnabled ? Icons.mic : Icons.mic_off,
            label: webRTCService.isMicEnabled ? 'Mute' : 'Unmute',
            onPressed: () {
              webRTCService.toggleMic();
            },
          ),
          _buildControlButton(
            icon: webRTCService.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            label: webRTCService.isCameraEnabled ? 'Stop Video' : 'Start Video',
            onPressed: () {
              webRTCService.toggleCamera();
            },
          ),
          _buildControlButton(
            icon: Icons.screen_share,
            label: webRTCService.isScreenShareEnabled ? 'Stop Sharing' : 'Share Screen',
            onPressed: () {
              webRTCService.toggleScreenShare();
            },
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End',
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            backgroundColor: backgroundColor ?? Colors.grey[800],
          ),
          onPressed: onPressed,
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
