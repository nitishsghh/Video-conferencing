class MeetingModel {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> participants;
  final bool isStarted;
  final String? description;
  final String? meetingLink;

  MeetingModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.participants,
    this.isStarted = false,
    this.description,
    this.meetingLink,
  });

  // Create a mock meeting
  factory MeetingModel.mock({
    required String id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    List<String>? participants,
    bool isStarted = false,
    String? description,
    String? meetingLink,
  }) {
    return MeetingModel(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      participants: participants ?? ['user1', 'user2', 'user3'],
      isStarted: isStarted,
      description: description,
      meetingLink: meetingLink ?? 'https://meet.example.com/$id',
    );
  }

  // Create a list of mock meetings
  static List<MeetingModel> getMockMeetings() {
    final now = DateTime.now();
    return [
      MeetingModel.mock(
        id: '1',
        title: 'STAND UP MEETING - WEEK 1',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 9, 30),
        isStarted: true,
      ),
      MeetingModel.mock(
        id: '2',
        title: 'DESIGN DISCUSSION',
        startTime: DateTime(now.year, now.month, now.day + 9, 9, 0),
        endTime: DateTime(now.year, now.month, now.day + 9, 9, 30),
        description: 'The meeting will be available in 2 days.',
      ),
      MeetingModel.mock(
        id: '3',
        title: 'FRONTEND DEV MEETING',
        startTime: DateTime(now.year, now.month, now.day + 12, 9, 0),
        endTime: DateTime(now.year, now.month, now.day + 12, 9, 30),
        description: 'The meeting will be available in 2 days.',
      ),
    ];
  }
}
