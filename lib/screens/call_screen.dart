import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/avatar_widget.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<UserModel> _contacts = UserModel.getMockUsers();

  // Mock call history
  final List<Map<String, dynamic>> _callHistory = [
    {
      'userId': '2',
      'type': 'incoming',
      'status': 'missed',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'userId': '3',
      'type': 'outgoing',
      'status': 'completed',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'duration': const Duration(minutes: 12, seconds: 35),
    },
    {
      'userId': '4',
      'type': 'incoming',
      'status': 'completed',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'duration': const Duration(minutes: 3, seconds: 47),
    },
    {
      'userId': '2',
      'type': 'outgoing',
      'status': 'completed',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'duration': const Duration(minutes: 8, seconds: 12),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Contacts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRecentCallsList(), _buildContactsList()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dial pad
          _showDialPad();
        },
        child: const Icon(Icons.dialpad),
      ),
    );
  }

  Widget _buildRecentCallsList() {
    if (_callHistory.isEmpty) {
      return const Center(child: Text('No recent calls'));
    }

    return ListView.builder(
      itemCount: _callHistory.length,
      itemBuilder: (context, index) {
        final call = _callHistory[index];
        final userId = call['userId'] as String;
        final user = _contacts.firstWhere(
          (u) => u.id == userId,
          orElse: () => UserModel.mock(id: userId, name: 'Unknown User'),
        );

        final callType = call['type'] as String;
        final callStatus = call['status'] as String;
        final timestamp = call['timestamp'] as DateTime;
        final duration = call['duration'] as Duration?;

        return ListTile(
          leading: AvatarWidget(user: user),
          title: Text(user.name),
          subtitle: Row(
            children: [
              Icon(
                callType == 'incoming'
                    ? (callStatus == 'missed'
                          ? Icons.call_missed
                          : Icons.call_received)
                    : Icons.call_made,
                size: 16,
                color: callStatus == 'missed' ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTimestamp(timestamp),
                style: const TextStyle(color: Colors.grey),
              ),
              if (duration != null) ...[
                const Text(' • '),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Call the user
              _callUser(user);
            },
          ),
          onTap: () {
            // Show call details
          },
        );
      },
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          leading: AvatarWidget(user: contact, showStatus: true),
          title: Text(contact.name),
          subtitle: Text(contact.status),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  // Call the user
                  _callUser(contact);
                },
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  // Video call the user
                  _videoCallUser(contact);
                },
              ),
            ],
          ),
          onTap: () {
            // Show contact details
          },
        );
      },
    );
  }

  void _showDialPad() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final TextEditingController numberController =
                TextEditingController();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: numberController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter number',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    childAspectRatio: 1.5,
                    children: [
                      _buildDialPadButton('1', '', numberController, setState),
                      _buildDialPadButton(
                        '2',
                        'ABC',
                        numberController,
                        setState,
                      ),
                      _buildDialPadButton(
                        '3',
                        'DEF',
                        numberController,
                        setState,
                      ),
                      _buildDialPadButton(
                        '4',
                        'GHI',
                        numberController,
                        setState,
                      ),
                      _buildDialPadButton(
                        '5',
                        'JKL',
                        numberController,
                        setState,
                      ),
                      _buildDialPadButton(
                        '6',
                        'MNO',
                        numberController,
                        setState,
                      ),
                      _buildDialPadButton(
                        '7',
                        'PQRS',
                        numberController,
                        setState,
                      ),
                      _buildDialPadButton(
                        '8',
                        'TUV',
                        numberController,
                        setState,
                      ),
                      _buildDialPadButton(
                        '9',
                        'WXYZ',
                        numberController,
                        setState,
                      ),
                      _buildDialPadButton('*', '', numberController, setState),
                      _buildDialPadButton('0', '+', numberController, setState),
                      _buildDialPadButton('#', '', numberController, setState),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          // Call the number
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.call),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.backspace),
                        onPressed: () {
                          if (numberController.text.isNotEmpty) {
                            setState(() {
                              numberController.text = numberController.text
                                  .substring(
                                    0,
                                    numberController.text.length - 1,
                                  );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialPadButton(
    String number,
    String letters,
    TextEditingController controller,
    StateSetter setState,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          controller.text += number;
        });
      },
      borderRadius: BorderRadius.circular(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (letters.isNotEmpty)
            Text(
              letters,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  void _callUser(UserModel user) {
    // Navigate to call screen
    Navigator.pushNamed(
      context,
      '/active-video-call',
      arguments: {'user': user, 'isVideo': false},
    );
  }

  void _videoCallUser(UserModel user) {
    // Navigate to video call screen
    Navigator.pushNamed(
      context,
      '/active-video-call',
      arguments: {'user': user, 'isVideo': true},
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today
      return 'Today';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week
      switch (timestamp.weekday) {
        case 1:
          return 'Monday';
        case 2:
          return 'Tuesday';
        case 3:
          return 'Wednesday';
        case 4:
          return 'Thursday';
        case 5:
          return 'Friday';
        case 6:
          return 'Saturday';
        case 7:
          return 'Sunday';
        default:
          return '';
      }
    } else {
      // More than a week ago
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
