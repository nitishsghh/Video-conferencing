import 'package:flutter/foundation.dart';

class AppConfig {
  // Server URLs
  static String get signalingServerUrl {
    if (kDebugMode) {
      // For emulators, use 10.0.2.2 which points to the host machine's localhost
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // For iOS simulators
        return 'http://localhost:3000';
      }
    }
    
    // For physical devices in development, use your computer's IP address on the local network
    // Replace with your actual IP address when testing on physical devices
    return 'http://192.168.1.100:3000';
    
    // For production, use your actual server URL
    // return 'https://your-production-server.com';
  }
  
  // STUN/TURN servers configuration
  static List<Map<String, dynamic>> get iceServers => [
    {
      'urls': [
        'stun:stun1.l.google.com:19302',
        'stun:stun2.l.google.com:19302',
      ],
    },
    // Uncomment and configure for production use with TURN server
    /*
    {
      'urls': 'turn:your-turn-server.com:3478',
      'username': 'username',
      'credential': 'password',
    },
    */
  ];
  
  // Development mode flag
  static bool get isDevelopmentMode => kDebugMode;
} 