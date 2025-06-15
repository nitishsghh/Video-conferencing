import 'package:flutter/material.dart';
import '../models/meeting_model.dart';
import '../models/user_model.dart';
import '../widgets/avatar_widget.dart';

class ActiveMeetingScreen extends StatefulWidget {
  final MeetingModel meeting;

  const ActiveMeetingScreen({super.key, required this.meeting});

  @override
  State<ActiveMeetingScreen> createState() => _ActiveMeetingScreenState();
}

class _ActiveMeetingScreenState extends State<ActiveMeetingScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  bool _isScreenSharing = false;

  final List<UserModel> _participants = [];

  @override
  void initState() {
    super.initState();
    // Generate mock participants
    final mockUsers = UserModel.getMockUsers();
    for (final participantId in widget.meeting.participants) {
      final index = int.tryParse(participantId.replaceAll('user', '')) ?? 0;
      _participants.add(mockUsers[index % mockUsers.length]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '05:12',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.meeting.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              // Show participants list
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main video area
          Expanded(child: _buildMainVideoArea()),

          // Control buttons
          _buildControlButtons(),

          // Participants row
          _buildParticipantsRow(),
        ],
      ),
    );
  }

  Widget _buildMainVideoArea() {
    return Stack(
      children: [
        // Main participant video
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.grey.shade900),
          child: Center(
            child: _participants.isNotEmpty
                ? AvatarWidget(user: _participants.first, size: 120)
                : const Icon(Icons.person, size: 120, color: Colors.white54),
          ),
        ),

        // Your video (picture-in-picture)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _isVideoOff
                      ? Center(
                          child: AvatarWidget(
                            user: UserModel.mock(id: 'self', name: 'You'),
                            size: 48,
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade700,
                          child: Center(
                            child: AvatarWidget(
                              user: UserModel.mock(id: 'self', name: 'You'),
                              size: 48,
                            ),
                          ),
                        ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
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
              });
            },
            backgroundColor: _isMuted ? Colors.red : Colors.white,
            iconColor: _isMuted ? Colors.white : Colors.black,
          ),
          _buildControlButton(
            icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
            label: _isVideoOff ? 'Video On' : 'Video Off',
            onPressed: () {
              setState(() {
                _isVideoOff = !_isVideoOff;
              });
            },
            backgroundColor: _isVideoOff ? Colors.red : Colors.white,
            iconColor: _isVideoOff ? Colors.white : Colors.black,
          ),
          _buildControlButton(
            icon: Icons.screen_share,
            label: 'Share',
            onPressed: () {
              setState(() {
                _isScreenSharing = !_isScreenSharing;
              });
            },
            backgroundColor: _isScreenSharing ? Colors.blue : Colors.white,
            iconColor: _isScreenSharing ? Colors.white : Colors.black,
          ),
          _buildControlButton(
            icon: Icons.settings,
            label: 'Settings',
            onPressed: () {
              // Show settings
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

  Widget _buildParticipantsRow() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.black,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _participants.length,
        itemBuilder: (context, index) {
          final participant = _participants[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                AvatarWidget(user: participant, size: 48, showStatus: true),
                const SizedBox(height: 4),
                Text(
                  participant.name.split(' ').first,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
