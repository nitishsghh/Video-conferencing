import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/webrtc_service.dart';
import '../models/meeting_model.dart';
import '../models/user_model.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/meeting_card.dart';
import '../screens/meeting_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _meetingIdController = TextEditingController();
  bool _isCreatingMeeting = false;
  bool _isJoiningMeeting = false;
  late TabController _tabController;
  final List<MeetingModel> _meetings = MeetingModel.getMockMeetings();
  final UserModel _currentUser = UserModel.getMockUsers().first;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _meetingIdController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createMeeting() async {
    setState(() {
      _isCreatingMeeting = true;
    });

    try {
      final webRTCService = Provider.of<WebRTCService>(context, listen: false);
      final meetingId = await webRTCService.createMeeting();

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MeetingScreen(meetingId: meetingId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingMeeting = false;
        });
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
      final meetingId = _meetingIdController.text.trim();

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MeetingScreen(meetingId: meetingId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoiningMeeting = false;
        });
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

  void _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      if (mounted && authService.isFirebaseAvailable) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Conferencing'),
        actions: [
          if (Provider.of<AuthService>(context).isFirebaseAvailable)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMeetingButtons(),
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildListView(), _buildCalendarView()],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to create a new meeting
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMeetingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AvatarWidget(user: _currentUser, size: 48),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HELLO, ${_currentUser.name.split(' ').first}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'See your meetings today!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // Show settings
          },
          icon: const Icon(Icons.settings_outlined),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'List'),
          Tab(text: 'Calendar'),
        ],
        indicator: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _meetings.length,
      itemBuilder: (context, index) {
        final meeting = _meetings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: MeetingCard(
            meeting: meeting,
            onTap: () {
              // Navigate to meeting details or join meeting
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeetingScreen(meetingId: meeting.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    final today = DateTime.now();
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    // Adjust for Sunday as first day of week (0-indexed)
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday;

    return Column(
      children: [
        _buildMonthHeader(today),
        const SizedBox(height: 16),
        _buildWeekdayLabels(),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: daysInMonth + startOffset,
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox.shrink();
              }

              final day = index - startOffset + 1;
              final date = DateTime(today.year, today.month, day);
              final isToday = day == today.day;

              // Check if there are meetings on this day
              final hasMeetings = _meetings.any(
                (meeting) =>
                    meeting.startTime.year == date.year &&
                    meeting.startTime.month == date.month &&
                    meeting.startTime.day == date.day,
              );

              // Find meetings for this day
              final dayMeetings = _meetings
                  .where(
                    (meeting) =>
                        meeting.startTime.year == date.year &&
                        meeting.startTime.month == date.month &&
                        meeting.startTime.day == date.day,
                  )
                  .toList();

              return GestureDetector(
                onTap: () {
                  // Show meetings for this day
                  if (hasMeetings) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Meetings on ${DateFormat('MMM d').format(date)}',
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: dayMeetings
                              .map(
                                (meeting) => ListTile(
                                  title: Text(meeting.title),
                                  subtitle: Text(
                                    '${DateFormat('h:mm a').format(meeting.startTime)} - ${DateFormat('h:mm a').format(meeting.endTime)}',
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      '/meeting',
                                      arguments: {'meeting': meeting},
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.blue : null,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isToday ? Colors.white : null,
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                      if (hasMeetings && !isToday)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      if (hasMeetings && dayMeetings.length > 1)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${dayMeetings.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader(DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            // Previous month
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          DateFormat('MMMM yyyy').format(date),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        IconButton(
          onPressed: () {
            // Next month
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (day) => Text(
              day,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
          .toList(),
    );
  }
}
