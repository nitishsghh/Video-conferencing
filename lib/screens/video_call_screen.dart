import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/avatar_widget.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final List<UserModel> _contacts = UserModel.getMockUsers();

  // Favorites - using a subset of contacts
  late List<UserModel> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = _contacts.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFavorites(),
              const SizedBox(height: 24),
              _buildRecentContacts(),
              const SizedBox(height: 24),
              _buildAllContacts(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new meeting
          _showCreateMeetingDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFavorites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorites',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                _favorites.length + 1, // +1 for the "Add favorite" button
            itemBuilder: (context, index) {
              if (index == _favorites.length) {
                // Add favorite button
                return _buildAddFavoriteButton();
              }

              final contact = _favorites[index];
              return _buildFavoriteItem(contact);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteItem(UserModel contact) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              _videoCallUser(contact);
            },
            borderRadius: BorderRadius.circular(30),
            child: AvatarWidget(user: contact, size: 60, showStatus: true),
          ),
          const SizedBox(height: 8),
          Text(
            contact.name.split(' ')[0],
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFavoriteButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Show dialog to add favorite
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Add', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3, // Show only 3 recent contacts
          itemBuilder: (context, index) {
            final contact = _contacts[index];
            return ListTile(
              leading: AvatarWidget(user: contact, showStatus: true),
              title: Text(contact.name),
              subtitle: Text(contact.status),
              trailing: IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  _videoCallUser(contact);
                },
              ),
              onTap: () {
                _videoCallUser(contact);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAllContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Contacts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            final contact = _contacts[index];
            return ListTile(
              leading: AvatarWidget(user: contact, showStatus: true),
              title: Text(contact.name),
              subtitle: Text(contact.status),
              trailing: IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  _videoCallUser(contact);
                },
              ),
              onTap: () {
                _videoCallUser(contact);
              },
            );
          },
        ),
      ],
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

  void _showCreateMeetingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Meeting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Meeting Title',
                prefixIcon: Icon(Icons.title),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Date & Time',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                // Show date picker
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );

                if (date != null && context.mounted) {
                  // Show time picker
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (time != null) {
                    // Handle selected date and time
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Add Participants',
                prefixIcon: Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Create meeting and navigate
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Meeting'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
