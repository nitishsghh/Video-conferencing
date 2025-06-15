import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Conferencing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _meetingIdController = TextEditingController();
  bool _isCreatingMeeting = false;
  bool _isJoiningMeeting = false;

  @override
  void dispose() {
    _meetingIdController.dispose();
    super.dispose();
  }

  Future<void> _createMeeting() async {
    setState(() {
      _isCreatingMeeting = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      final meetingId = 'meeting-${DateTime.now().millisecondsSinceEpoch}';
      
      if (mounted) {
        setState(() {
          _isCreatingMeeting = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MeetingScreen(meetingId: meetingId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingMeeting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _joinMeeting() async {
    if (_meetingIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meeting ID')),
      );
      return;
    }

    setState(() {
      _isJoiningMeeting = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      final meetingId = _meetingIdController.text.trim();
      
      if (mounted) {
        setState(() {
          _isJoiningMeeting = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MeetingScreen(meetingId: meetingId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoiningMeeting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showJoinMeetingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Meeting'),
        content: TextField(
          controller: _meetingIdController,
          decoration: const InputDecoration(
            labelText: 'Meeting ID',
            hintText: 'Enter meeting ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinMeeting();
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Conferencing'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Video Conferencing',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isCreatingMeeting ? null : _createMeeting,
                      icon: const Icon(Icons.video_call),
                      label: _isCreatingMeeting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('New Meeting'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isJoiningMeeting ? null : _showJoinMeetingDialog,
                      icon: const Icon(Icons.keyboard),
                      label: _isJoiningMeeting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Join Meeting'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  bool _isJoining = true;
  final List<String> _participants = [];

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  Future<void> _joinMeeting() async {
    try {
      // Simulate joining
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isJoining = false;
          // Add mock participants
          _participants.add('You');
          _participants.add('User 1');
          _participants.add('User 2');
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
          : Column(
              children: [
                Expanded(
                  child: _buildVideoGrid(),
                ),
                _buildLocalVideoPreview(),
                _buildControlBar(),
              ],
            ),
    );
  }

  Widget _buildVideoGrid() {
    if (_participants.isEmpty) {
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
        crossAxisCount: _participants.length == 1 ? 1 : 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _participants.length,
      itemBuilder: (context, index) {
        final participant = _participants[index];
        final isLocal = participant == 'You';
        
        return _buildVideoTile(
          isLocal: isLocal,
          isMuted: isLocal ? !_isMicEnabled : false,
          isCameraOff: isLocal ? !_isCameraEnabled : false,
          participantName: participant,
        );
      },
    );
  }

  Widget _buildVideoTile({
    required bool isLocal,
    required bool isMuted,
    required bool isCameraOff,
    required String participantName,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Mock video stream
            if (!isCameraOff)
              Center(
                child: Icon(
                  isLocal ? Icons.person : Icons.people,
                  size: 48,
                  color: Colors.white,
                ),
              )
            else
              const Center(
                child: Icon(
                  Icons.videocam_off,
                  color: Colors.white,
                  size: 48,
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
                  participantName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            // Muted indicator
            if (isMuted)
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

  Widget _buildLocalVideoPreview() {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(8.0),
      child: _buildVideoTile(
        isLocal: true,
        isMuted: !_isMicEnabled,
        isCameraOff: !_isCameraEnabled,
        participantName: 'You',
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      height: 80,
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
            label: _isMicEnabled ? 'Mute' : 'Unmute',
            onPressed: () {
              setState(() {
                _isMicEnabled = !_isMicEnabled;
              });
            },
          ),
          _buildControlButton(
            icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            label: _isCameraEnabled ? 'Stop Video' : 'Start Video',
            onPressed: () {
              setState(() {
                _isCameraEnabled = !_isCameraEnabled;
              });
            },
          ),
          _buildControlButton(
            icon: Icons.screen_share,
            label: 'Share Screen',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Screen sharing not available in demo')),
              );
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
