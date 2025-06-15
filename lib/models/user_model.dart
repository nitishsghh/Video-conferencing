class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String status;
  final String? lastSeen;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.status = 'Available',
    this.lastSeen,
  });

  // Get initials from name
  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return name.substring(0, min(2, name.length));
  }

  // Create a mock user
  factory UserModel.mock({
    required String id,
    required String name,
    String? email,
    String? avatarUrl,
    String? status,
    String? lastSeen,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email ?? '$name.example.com',
      avatarUrl: avatarUrl,
      status: status ?? 'Available',
      lastSeen: lastSeen,
    );
  }

  // Create a list of mock users
  static List<UserModel> getMockUsers() {
    return [
      UserModel.mock(id: '1', name: 'Tania Chen', status: 'Available'),
      UserModel.mock(id: '2', name: 'Maryna Kolesnik', status: 'Available'),
      UserModel.mock(id: '3', name: 'John Smith', status: 'In a call'),
      UserModel.mock(id: '4', name: 'Emily Johnson', status: 'Away'),
      UserModel.mock(id: '5', name: 'Michael Brown', status: 'Busy'),
    ];
  }
}

// Helper function for string length
int min(int a, int b) => a < b ? a : b;
