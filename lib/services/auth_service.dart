import 'package:flutter/foundation.dart';

class User {
  final String uid;
  final String? email;
  final String? displayName;

  User({required this.uid, this.email, this.displayName});
}

class AuthService extends ChangeNotifier {
  User? _user;
  bool _isFirebaseAvailable = false;

  AuthService() {
    // In a real app, we would initialize Firebase here
    // For now, we'll just create a mock user
    _user = User(
      uid: 'mock-user-123',
      email: 'user@example.com',
      displayName: 'Demo User',
    );
  }

  User? get user => _user;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      // In a real app, this would use Firebase Auth
      _user = User(
        uid: 'mock-user-123',
        email: email,
        displayName: email.split('@').first,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // In a real app, this would sign out from Firebase Auth
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // In a real app, this would create a user in Firebase Auth
      _user = User(
        uid: 'new-mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
