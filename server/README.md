# Teams Clone Signaling Server

A WebRTC signaling server for the Teams Clone Android application, built with Node.js, Express, and Socket.IO.

## Features

- Real-time WebRTC signaling for video/audio calls
- Room-based participant management
- Screen sharing signaling
- Real-time chat message relay
- Participant status updates (audio/video toggle)
- Firebase authentication integration

## Prerequisites

- Node.js (v14+)
- npm or yarn
- Firebase project (for authentication)

## Installation

1. Clone the repository
2. Navigate to the server directory
3. Install dependencies:

```bash
npm install
```

## Configuration

Create a `.env` file in the root directory with the following variables:

```
PORT=3000
NODE_ENV=development
CORS_ORIGIN=*
```

Adjust these values according to your environment.

### Firebase Setup

The server uses Firebase Admin SDK for authentication. You need to set up Firebase credentials:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Generate a new private key for your service account:
   - Go to Project Settings > Service accounts
   - Click "Generate new private key"
   - Save the JSON file securely

3. Set up the Firebase credentials using our helper script:

```bash
node setup-firebase.js
```

This script will guide you through setting up your Firebase credentials securely.

Alternatively, you can manually:
- Save the JSON file as `firebase-service-account.json` in the server root directory
- Set the `FIREBASE_SERVICE_ACCOUNT` environment variable with the JSON content

**Important**: For detailed security guidelines regarding Firebase credentials, please refer to [FIREBASE_SECURITY.md](./FIREBASE_SECURITY.md).

## Running the Server

### Quick Start

#### On Linux/macOS:
```bash
./start.sh
```

#### On Windows:
```bash
start.bat
```

### Development Mode

```bash
npm run dev
```

This will start the server with nodemon for automatic reloading.

### Production Mode

```bash
npm start
```

### Using Docker

To run the server in a Docker container:

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

## API Endpoints

- `GET /`: Simple health check
- `GET /api/status`: Returns server status and active room count
- `GET /api/protected`: Protected endpoint requiring Firebase authentication

## Authentication

Protected endpoints require Firebase authentication. Include an authorization header with a Firebase ID token:

```
Authorization: Bearer <firebase-id-token>
```

## WebSocket Events

### Client to Server

- `join_room`: Join a meeting room
- `leave_room`: Leave a meeting room
- `offer`: Send WebRTC offer
- `answer`: Send WebRTC answer
- `ice_candidate`: Send ICE candidate
- `send_message`: Send chat message
- `start_screen_sharing`: Notify about screen sharing start
- `stop_screen_sharing`: Notify about screen sharing stop
- `toggle_audio`: Update audio status
- `toggle_video`: Update video status

### Server to Client

- `room_joined`: Confirmation of room join with participant list
- `user_joined`: Notification about new participant
- `user_left`: Notification about participant leaving
- `offer`: Receive WebRTC offer
- `answer`: Receive WebRTC answer
- `ice_candidate`: Receive ICE candidate
- `new_message`: Receive chat message
- `user_started_sharing`: Notification about screen sharing start
- `user_stopped_sharing`: Notification about screen sharing stop
- `user_toggle_audio`: Notification about audio status change
- `user_toggle_video`: Notification about video status change
- `error`: Error notification 