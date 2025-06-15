import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class WebRTCInterface extends ChangeNotifier {
  // Media state
  bool get isMicEnabled;
  bool get isCameraEnabled;
  bool get isSpeakerEnabled;
  bool get isScreenShareEnabled;
  bool get isInCall;
  String? get currentMeetingId;
  String? get currentCallId;

  // Local and remote streams
  MediaStream? get localStream;
  Map<String, MediaStream> get remoteStreams;

  // Media control
  void toggleMic();
  void toggleCamera();
  void toggleSpeaker();
  void toggleScreenShare();

  // Meeting functions
  Future<String> createMeeting();
  Future<void> joinMeeting(String meetingId);
  Future<void> leaveMeeting();

  // Call functions
  Future<String> makeCall(String userId);
  Future<void> answerCall(String callId);
  Future<void> endCall();

  // WebRTC specific functions
  Future<void> createPeerConnection(RTCConfiguration configuration);
  Future<void> setRemoteDescription(RTCSessionDescription description);
  Future<RTCSessionDescription> createOffer();
  Future<RTCSessionDescription> createAnswer();
  Future<void> addIceCandidate(RTCIceCandidate candidate);
  Future<void> dispose();
}
