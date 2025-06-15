import 'package:flutter/foundation.dart';

class WebRTCService extends ChangeNotifier {
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isScreenShareEnabled = false;
  bool _isInCall = false;
  String? _currentMeetingId;
  String? _currentCallId;

  // Mock streams
  final Map<String, dynamic> _remoteStreams = {};
  dynamic _localStream;

  bool get isMicEnabled => _isMicEnabled;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isSpeakerEnabled => _isSpeakerEnabled;
  bool get isScreenShareEnabled => _isScreenShareEnabled;
  bool get isInCall => _isInCall;
  String? get currentMeetingId => _currentMeetingId;
  String? get currentCallId => _currentCallId;
  dynamic get localStream => _localStream;
  Map<String, dynamic> get remoteStreams => _remoteStreams;

  // Initialize WebRTC service
  Future<void> initialize() async {
    debugPrint('Mock WebRTC service initialized');
    _localStream = {'mock': 'local-stream'};
    notifyListeners();
  }

  // Toggle microphone
  void toggleMic() {
    _isMicEnabled = !_isMicEnabled;
    debugPrint('Microphone ${_isMicEnabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  // Toggle camera
  void toggleCamera() {
    _isCameraEnabled = !_isCameraEnabled;
    debugPrint('Camera ${_isCameraEnabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  // Toggle speaker
  void toggleSpeaker() {
    _isSpeakerEnabled = !_isSpeakerEnabled;
    debugPrint('Speaker ${_isSpeakerEnabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  // Toggle screen sharing
  Future<void> toggleScreenShare() async {
    _isScreenShareEnabled = !_isScreenShareEnabled;
    debugPrint(
      'Screen sharing ${_isScreenShareEnabled ? 'enabled' : 'disabled'}',
    );
    notifyListeners();
  }

  // Create a new meeting
  Future<String> createMeeting() async {
    try {
      await initialize();

      final meetingId = 'meeting-${DateTime.now().millisecondsSinceEpoch}';
      _currentMeetingId = meetingId;
      _isInCall = true;

      debugPrint('Created meeting: $meetingId');

      // Simulate remote participants after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _addMockParticipant('user1');
      });

      Future.delayed(const Duration(seconds: 4), () {
        _addMockParticipant('user2');
      });

      notifyListeners();
      return meetingId;
    } catch (e) {
      debugPrint('Error creating meeting: $e');
      rethrow;
    }
  }

  // Join an existing meeting
  Future<void> joinMeeting(String meetingId) async {
    try {
      await initialize();

      _currentMeetingId = meetingId;
      _isInCall = true;

      debugPrint('Joined meeting: $meetingId');

      // Simulate remote participants after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _addMockParticipant('host');
      });

      Future.delayed(const Duration(seconds: 3), () {
        _addMockParticipant('participant1');
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error joining meeting: $e');
      rethrow;
    }
  }

  // Leave the current meeting
  Future<void> leaveMeeting() async {
    try {
      debugPrint('Left meeting: $_currentMeetingId');

      _currentMeetingId = null;
      _isInCall = false;
      _remoteStreams.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Error leaving meeting: $e');
      rethrow;
    }
  }

  // Make a call to a user
  Future<String> makeCall(String userId) async {
    try {
      await initialize();

      final callId = 'call-${DateTime.now().millisecondsSinceEpoch}';
      _currentCallId = callId;
      _isInCall = true;

      debugPrint('Making call to $userId, callId: $callId');

      // Simulate remote participant after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _addMockParticipant(userId);
      });

      notifyListeners();
      return callId;
    } catch (e) {
      debugPrint('Error making call: $e');
      rethrow;
    }
  }

  // Answer an incoming call
  Future<void> answerCall(String callId) async {
    try {
      await initialize();

      _currentCallId = callId;
      _isInCall = true;

      debugPrint('Answered call: $callId');

      // Simulate remote participant after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        _addMockParticipant('caller');
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error answering call: $e');
      rethrow;
    }
  }

  // End the current call
  Future<void> endCall() async {
    try {
      debugPrint('Ended call: $_currentCallId');

      _currentCallId = null;
      _isInCall = false;
      _remoteStreams.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Error ending call: $e');
      rethrow;
    }
  }

  // Add a mock participant
  void _addMockParticipant(String userId) {
    if (!_isInCall) return;

    _remoteStreams[userId] = {'mock': 'remote-stream-$userId'};
    debugPrint('Added mock participant: $userId');
    notifyListeners();
  }

  // Dispose of resources
  @override
  void dispose() {
    _remoteStreams.clear();
    _localStream = null;
    super.dispose();
  }
}
