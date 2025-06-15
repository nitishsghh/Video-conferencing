# Video Conferencing App with WebRTC

A Flutter video conferencing application using WebRTC for real-time communication.

## Features

- Create and join video meetings
- Real-time video and audio streaming
- Toggle camera, microphone, and speaker
- Screen sharing
- Chat functionality
- Meeting scheduling

## Project Structure

The project is organized into the following key directories:

### Flutter Application
- `lib/` - Main Flutter application code
  - `main.dart` - Application entry point
  - `screens/` - UI screens (home, login, meeting, video call screens)
  - `widgets/` - Reusable UI components
  - `services/` - Business logic and external services integration
  - `models/` - Data models
  - `utils/` - Helper functions and utilities
  - `config/` - Application configuration

### Backend
- `server/` - Signaling server for WebRTC
  - `signaling_server.js` - Node.js WebSocket server for WebRTC signaling
  - `setup-firebase.js` - Firebase integration
  - `src/` - Additional server modules

### Assets and Configuration
- `assets/` - Images, fonts, and other static resources
- `android/`, `ios/`, `web/`, `windows/` - Platform-specific code

## Modules

### Core Modules

1. **Authentication Module**
   - Handles user registration, login, and session management
   - Files: `lib/services/auth_service.dart`

2. **WebRTC Communication Module**
   - Manages real-time audio/video communication
   - Files: 
     - `lib/services/webrtc_service.dart` - Main implementation
     - `lib/services/webrtc_interface.dart` - Interface definition
     - `lib/services/webrtc_service_mock.dart` - Mock for testing

3. **Meeting Management Module**
   - Handles creation, joining, and management of meetings
   - Files: `lib/models/meeting_model.dart`

4. **User Management Module**
   - User profile and settings
   - Files: `lib/models/user_model.dart`

5. **Signaling Server Module**
   - Facilitates WebRTC connection establishment
   - Files: `server/signaling_server.js`

## WebRTC Implementation

The application uses WebRTC (Web Real-Time Communication) for peer-to-peer communication. Here's how it's implemented:

### Components

1. **WebRTC Service**: Manages WebRTC connections, streams, and signaling.
2. **Signaling Server**: Node.js server using Socket.IO for WebRTC signaling.
3. **Video Renderer**: Flutter widget to display video streams.

### WebRTC Flow

1. User creates or joins a meeting
2. WebRTC service initializes local media stream
3. Connects to signaling server
4. For meeting creator:
   - Creates a meeting ID
   - Waits for participants
5. For meeting joiners:
   - Connects to the meeting using the meeting ID
   - Exchanges SDP offers/answers and ICE candidates
6. Establishes peer connections
7. Streams audio and video between participants

## Getting Started

### Prerequisites

- Flutter SDK
- Node.js (for signaling server)
- WebRTC-compatible browsers or devices

### Installation

1. Clone the repository
```
git clone https://github.com/yourusername/conferencing.git
cd conferencing
```

2. Install Flutter dependencies
```
flutter pub get
```

3. Install signaling server dependencies
```
cd server
npm install
```

### Running the App

1. Start the signaling server
```
cd server
npm start
```

2. Run the Flutter app
```
flutter run
```

## Configuration

Update the signaling server URL in `lib/services/webrtc_service.dart`:

```dart
// Setup signaling server connection
void _setupSignaling() {
  // Replace with your actual signaling server URL
  const serverUrl = 'https://your-signaling-server.com';
  
  // ...
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter WebRTC package
- Socket.IO for signaling
- STUN/TURN servers for NAT traversal 