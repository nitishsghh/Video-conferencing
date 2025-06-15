import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';

class WebRTCService extends ChangeNotifier {
  // Media state
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isScreenShareEnabled = false;
  bool _isInCall = false;
  String? _currentMeetingId;
  String? _currentCallId;

  // WebRTC components
  MediaStream? _localStream;
  final Map<String, MediaStream> _remoteStreams = {};
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, RTCDataChannel> _dataChannels = {};

  // Signaling
  io.Socket? _socket;
  final String _userId = const Uuid().v4();

  // STUN/TURN servers for NAT traversal
  final _rtcConfig = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ],
      },
    ],
  };

  // Getters
  bool get isMicEnabled => _isMicEnabled;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isSpeakerEnabled => _isSpeakerEnabled;
  bool get isScreenShareEnabled => _isScreenShareEnabled;
  bool get isInCall => _isInCall;
  String? get currentMeetingId => _currentMeetingId;
  String? get currentCallId => _currentCallId;
  MediaStream? get localStream => _localStream;
  Map<String, MediaStream> get remoteStreams => _remoteStreams;

  // Initialize WebRTC service
  Future<void> initialize() async {
    await _initLocalStream();
    _setupSignaling();
  }

  // Initialize local media stream
  Future<void> _initLocalStream() async {
    final mediaConstraints = <String, dynamic>{
      'audio': _isMicEnabled,
      'video': _isCameraEnabled
          ? {
              'facingMode': 'user',
              'width': {'ideal': 1280},
              'height': {'ideal': 720},
            }
          : false,
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting user media: $e');
      rethrow;
    }
  }

  // Setup signaling server connection
  void _setupSignaling() {
    // Replace with your actual signaling server URL
    const serverUrl = 'https://your-signaling-server.com';

    _socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket?.on('connect', (_) {
      debugPrint('Connected to signaling server');
      _socket?.emit('register', {'userId': _userId});
    });

    _socket?.on('offer', (data) async {
      final peerId = data['from'];
      final description = data['description'];
      await _handleOffer(peerId, description);
    });

    _socket?.on('answer', (data) async {
      final peerId = data['from'];
      final description = data['description'];
      await _handleAnswer(peerId, description);
    });

    _socket?.on('ice-candidate', (data) async {
      final peerId = data['from'];
      final candidateData = data['candidate'];
      await _handleIceCandidate(peerId, candidateData);
    });

    _socket?.on('user-joined', (data) async {
      final peerId = data['userId'];
      await _createPeerConnection(peerId, true);
    });

    _socket?.on('user-left', (data) {
      final peerId = data['userId'];
      _removePeerConnection(peerId);
    });
  }

  // Create a peer connection
  Future<RTCPeerConnection> _createPeerConnection(
    String peerId,
    bool isInitiator,
  ) async {
    // Use the configuration map directly instead of RTCConfiguration
    final peerConnection = await createPeerConnection(_rtcConfig);

    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      _socket?.emit('ice-candidate', {
        'to': peerId,
        'from': _userId,
        'candidate': {
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
      });
    };

    peerConnection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStreams[peerId] = event.streams[0];
        notifyListeners();
      }
    };

    // Add local stream tracks to peer connection
    _localStream?.getTracks().forEach((track) {
      peerConnection.addTrack(track, _localStream!);
    });

    // Create data channel for messaging
    if (isInitiator) {
      final dataChannelInit = RTCDataChannelInit();
      dataChannelInit.ordered = true;
      final dataChannel = await peerConnection.createDataChannel(
        'messaging',
        dataChannelInit,
      );
      _setupDataChannel(dataChannel, peerId);
    } else {
      peerConnection.onDataChannel = (RTCDataChannel channel) {
        _setupDataChannel(channel, peerId);
      };
    }

    _peerConnections[peerId] = peerConnection;
    return peerConnection;
  }

  // Setup data channel
  void _setupDataChannel(RTCDataChannel dataChannel, String peerId) {
    dataChannel.onMessage = (RTCDataChannelMessage message) {
      debugPrint('Received message from $peerId: ${message.text}');
      // Handle incoming messages
    };

    dataChannel.onDataChannelState = (RTCDataChannelState state) {
      debugPrint('Data channel state: $state');
    };

    _dataChannels[peerId] = dataChannel;
  }

  // Handle incoming offer
  Future<void> _handleOffer(String peerId, dynamic description) async {
    final peerConnection =
        _peerConnections[peerId] ?? await _createPeerConnection(peerId, false);

    final rtcSessionDescription = RTCSessionDescription(
      description['sdp'],
      description['type'],
    );

    await peerConnection.setRemoteDescription(rtcSessionDescription);

    final answer = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(answer);

    _socket?.emit('answer', {
      'to': peerId,
      'from': _userId,
      'description': {'sdp': answer.sdp, 'type': answer.type},
    });
  }

  // Handle incoming answer
  Future<void> _handleAnswer(String peerId, dynamic description) async {
    final peerConnection = _peerConnections[peerId];
    if (peerConnection != null) {
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(description['sdp'], description['type']),
      );
    }
  }

  // Handle incoming ICE candidate
  Future<void> _handleIceCandidate(String peerId, dynamic candidateData) async {
    final peerConnection = _peerConnections[peerId];
    if (peerConnection != null) {
      await peerConnection.addCandidate(
        RTCIceCandidate(
          candidateData['candidate'],
          candidateData['sdpMid'],
          candidateData['sdpMLineIndex'],
        ),
      );
    }
  }

  // Remove peer connection
  void _removePeerConnection(String peerId) {
    final peerConnection = _peerConnections[peerId];
    if (peerConnection != null) {
      peerConnection.close();
      _peerConnections.remove(peerId);
    }

    _dataChannels.remove(peerId);
    _remoteStreams.remove(peerId);
    notifyListeners();
  }

  // Toggle microphone
  void toggleMic() {
    _isMicEnabled = !_isMicEnabled;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = _isMicEnabled;
    });
    notifyListeners();
  }

  // Toggle camera
  void toggleCamera() {
    _isCameraEnabled = !_isCameraEnabled;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = _isCameraEnabled;
    });
    notifyListeners();
  }

  // Toggle speaker
  void toggleSpeaker() {
    _isSpeakerEnabled = !_isSpeakerEnabled;
    // Implementation depends on platform
    // On mobile, you'd use platform-specific code
    notifyListeners();
  }

  // Toggle screen sharing
  Future<void> toggleScreenShare() async {
    _isScreenShareEnabled = !_isScreenShareEnabled;

    if (_isScreenShareEnabled) {
      try {
        // Save current video stream
        final videoTrack = _localStream?.getVideoTracks().first;

        // Get screen share stream
        final screenStream = await navigator.mediaDevices.getDisplayMedia(
          <String, dynamic>{'video': true},
        );

        // Replace video track with screen share track
        if (_localStream != null && screenStream.getVideoTracks().isNotEmpty) {
          final screenTrack = screenStream.getVideoTracks().first;

          // Replace track in all peer connections
          _peerConnections.forEach((peerId, pc) {
            pc.getSenders().then((senders) {
              for (final sender in senders) {
                if (sender.track?.kind == 'video') {
                  sender.replaceTrack(screenTrack);
                }
              }
            });
          });

          // Add screen track to local stream
          await _localStream!.removeTrack(videoTrack!);
          await _localStream!.addTrack(screenTrack);
        }
      } catch (e) {
        _isScreenShareEnabled = false;
        debugPrint('Error toggling screen share: $e');
      }
    } else {
      // Switch back to camera
      await _initLocalStream();

      // Replace track in all peer connections
      if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
        final videoTrack = _localStream!.getVideoTracks().first;

        _peerConnections.forEach((peerId, pc) {
          pc.getSenders().then((senders) {
            for (final sender in senders) {
              if (sender.track?.kind == 'video') {
                sender.replaceTrack(videoTrack);
              }
            }
          });
        });
      }
    }

    notifyListeners();
  }

  // Create a new meeting
  Future<String> createMeeting() async {
    try {
      await initialize();

      final meetingId = 'meeting-${DateTime.now().millisecondsSinceEpoch}';
      _currentMeetingId = meetingId;
      _isInCall = true;

      _socket?.emit('create-meeting', {
        'meetingId': meetingId,
        'userId': _userId,
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

      _socket?.emit('join-meeting', {
        'meetingId': meetingId,
        'userId': _userId,
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
      if (_currentMeetingId != null) {
        _socket?.emit('leave-meeting', {
          'meetingId': _currentMeetingId,
          'userId': _userId,
        });
      }

      _cleanupConnections();
      _currentMeetingId = null;
      _isInCall = false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error leaving meeting: $e');
      rethrow;
    }
  }

  // Make a call to a user
  Future<String> makeCall(String targetUserId) async {
    try {
      await initialize();

      final callId = 'call-${DateTime.now().millisecondsSinceEpoch}';
      _currentCallId = callId;
      _isInCall = true;

      // Create peer connection
      final peerConnection = await _createPeerConnection(targetUserId, true);

      // Create offer
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);

      // Send offer to remote peer
      _socket?.emit('offer', {
        'to': targetUserId,
        'from': _userId,
        'callId': callId,
        'description': {'sdp': offer.sdp, 'type': offer.type},
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

      notifyListeners();
    } catch (e) {
      debugPrint('Error answering call: $e');
      rethrow;
    }
  }

  // End the current call
  Future<void> endCall() async {
    try {
      if (_currentCallId != null) {
        _socket?.emit('end-call', {
          'callId': _currentCallId,
          'userId': _userId,
        });
      }

      _cleanupConnections();
      _currentCallId = null;
      _isInCall = false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error ending call: $e');
      rethrow;
    }
  }

  // Clean up all connections
  void _cleanupConnections() {
    // Close all peer connections
    _peerConnections.forEach((peerId, pc) {
      pc.close();
    });
    _peerConnections.clear();

    // Close all data channels
    _dataChannels.clear();

    // Stop all tracks in local stream
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream = null;

    // Clear remote streams
    _remoteStreams.clear();
  }

  // Dispose of resources
  @override
  void dispose() {
    _cleanupConnections();
    _socket?.disconnect();
    _socket = null;
    super.dispose();
  }
}
