import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/webrtc_service.dart';
import '../widgets/avatar_widget.dart';

class ActiveVideoCallScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const ActiveVideoCallScreen({super.key, this.arguments});

  @override
  State<ActiveVideoCallScreen> createState() => _ActiveVideoCallScreenState();
}

class _ActiveVideoCallScreenState extends State<ActiveVideoCallScreen> {
  late UserModel _user;
  late bool _isVideoCall;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  bool _isCallConnected = false;
  Duration _callDuration = Duration.zero;
  late DateTime _callStartTime;

  @override
  void initState() {
    super.initState();
    _user =
        widget.arguments?['user'] as UserModel? ??
        UserModel.mock(id: 'unknown', name: 'Unknown User');
    _isVideoCall = widget.arguments?['isVideo'] as bool? ?? false;

    // Start call timer
    _callStartTime = DateTime.now();
    _startCallTimer();

    // Simulate call connecting after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCallConnected = true;
        });
      }
    });
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime);
          _startCallTimer();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final webrtcService = Provider.of<WebRTCService>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Call info bar
            _buildCallInfoBar(),

            // Main call area
            Expanded(child: _buildCallArea()),

            // Call controls
            _buildCallControls(webrtcService),
          ],
        ),
      ),
    );
  }

  Widget _buildCallInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                _formatDuration(_callDuration),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isCallConnected
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isCallConnected ? 'Connected' : 'Connecting...',
                  style: TextStyle(
                    color: _isCallConnected ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCallArea() {
    if (_isVideoCall && !_isVideoOff) {
      // Video call UI
      return Stack(
        fit: StackFit.expand,
        children: [
          // Remote video (simulated with avatar for now)
          Container(
            color: Colors.grey.shade900,
            child: Center(child: AvatarWidget(user: _user, size: 120)),
          ),

          // Local video preview (simulated)
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: AvatarWidget(
                    user: UserModel.mock(id: 'self', name: 'You'),
                    size: 48,
                  ),
                ),
              ),
            ),
          ),

          // User name
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Audio call UI
      return Container(
        color: Colors.grey.shade900,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarWidget(user: _user, size: 120),
            const SizedBox(height: 24),
            Text(
              _user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isCallConnected ? 'In call' : 'Calling...',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCallControls(WebRTCService webrtcService) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
                webrtcService.toggleMic();
              });
            },
            backgroundColor: _isMuted ? Colors.red : Colors.white,
            iconColor: _isMuted ? Colors.white : Colors.black,
          ),
          if (_isVideoCall)
            _buildControlButton(
              icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
              label: _isVideoOff ? 'Video On' : 'Video Off',
              onPressed: () {
                setState(() {
                  _isVideoOff = !_isVideoOff;
                  webrtcService.toggleCamera();
                });
              },
              backgroundColor: _isVideoOff ? Colors.red : Colors.white,
              iconColor: _isVideoOff ? Colors.white : Colors.black,
            ),
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
            onPressed: () {
              setState(() {
                _isSpeakerOn = !_isSpeakerOn;
                webrtcService.toggleSpeaker();
              });
            },
            backgroundColor: Colors.white,
            iconColor: Colors.black,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End',
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: Colors.red,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon),
            color: iconColor,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}
