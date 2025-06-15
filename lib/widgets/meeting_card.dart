import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meeting_model.dart';
import '../models/user_model.dart';
import 'avatar_widget.dart';

class MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback? onTap;

  const MeetingCard({super.key, required this.meeting, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Generate mock users for participants
    final mockUsers = UserModel.getMockUsers();
    final participants = meeting.participants.map((id) {
      final index = int.tryParse(id.replaceAll('user', '')) ?? 0;
      return mockUsers[index % mockUsers.length];
    }).toList();

    return Card(
      elevation: 0,
      color: meeting.isStarted ? const Color(0xFF3D5AFE) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: meeting.isStarted ? Colors.white : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onTap,
                    icon: const Icon(Icons.chevron_right),
                    color: meeting.isStarted ? Colors.white : Colors.grey,
                  ),
                ],
              ),
              if (meeting.isStarted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Text(
                    'The meeting is started.\nPlease join us!',
                    style: TextStyle(
                      color: meeting.isStarted
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey,
                    ),
                  ),
                ),
              if (meeting.description != null && !meeting.isStarted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Text(
                    meeting.description!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Show participant avatars
                      SizedBox(
                        width: 80,
                        child: Stack(
                          children: [
                            for (
                              int i = 0;
                              i < participants.length && i < 4;
                              i++
                            )
                              Positioned(
                                left: i * 20.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: meeting.isStarted
                                          ? const Color(0xFF3D5AFE)
                                          : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: AvatarWidget(
                                    user: participants[i],
                                    size: 32,
                                  ),
                                ),
                              ),
                            if (participants.length > 4)
                              Positioned(
                                left: 4 * 20.0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: meeting.isStarted
                                          ? const Color(0xFF3D5AFE)
                                          : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${participants.length - 4}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${participants.length}',
                        style: TextStyle(
                          color: meeting.isStarted ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _formatDate(meeting.startTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: meeting.isStarted ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: meeting.isStarted
                              ? Colors.white
                              : const Color(0xFF3D5AFE),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${DateFormat('h:mm').format(meeting.startTime)} - ${DateFormat('h:mm a').format(meeting.endTime)}',
                          style: TextStyle(
                            color: meeting.isStarted
                                ? const Color(0xFF3D5AFE)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('d MMM yyyy').format(date);
    }
  }
}
