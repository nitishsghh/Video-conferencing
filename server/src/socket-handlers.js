const { v4: uuidv4 } = require('uuid');

/**
 * Set up Socket.IO event handlers for WebRTC signaling
 * @param {Object} io - Socket.IO server instance
 * @param {Map} rooms - Map to store active rooms and participants
 */
function setupSocketHandlers(io, rooms) {
  io.on('connection', (socket) => {
    console.log(`Client connected: ${socket.id}`);
    
    // Store user data
    let userData = {
      socketId: socket.id,
      userId: null,
      username: null,
      roomId: null
    };

    // Handle joining a room
    socket.on('join_room', async (data) => {
      try {
        const { roomId, userId, username } = data;
        
        // Update user data
        userData.userId = userId;
        userData.username = username;
        userData.roomId = roomId;
        
        // Create room if it doesn't exist
        if (!rooms.has(roomId)) {
          rooms.set(roomId, new Map());
        }
        
        // Add user to room
        const room = rooms.get(roomId);
        room.set(socket.id, {
          userId,
          username,
          socketId: socket.id
        });
        
        // Join the socket room
        await socket.join(roomId);
        
        // Get list of participants in the room
        const participants = Array.from(room.values()).map(p => ({
          userId: p.userId,
          username: p.username,
          socketId: p.socketId
        }));
        
        // Notify the new user about existing participants
        socket.emit('room_joined', {
          roomId,
          participants
        });
        
        // Notify other participants about the new user
        socket.to(roomId).emit('user_joined', {
          userId,
          username,
          socketId: socket.id
        });
        
        console.log(`User ${username} (${userId}) joined room ${roomId}`);
      } catch (error) {
        console.error('Error joining room:', error);
        socket.emit('error', { message: 'Failed to join room' });
      }
    });

    // Handle WebRTC signaling
    socket.on('offer', (data) => {
      const { targetSocketId, sdp } = data;
      socket.to(targetSocketId).emit('offer', {
        sdp,
        offerSocketId: socket.id
      });
    });

    socket.on('answer', (data) => {
      const { targetSocketId, sdp } = data;
      socket.to(targetSocketId).emit('answer', {
        sdp,
        answerSocketId: socket.id
      });
    });

    socket.on('ice_candidate', (data) => {
      const { targetSocketId, candidate } = data;
      socket.to(targetSocketId).emit('ice_candidate', {
        candidate,
        candidateSocketId: socket.id
      });
    });

    // Handle screen sharing
    socket.on('start_screen_sharing', () => {
      if (userData.roomId) {
        socket.to(userData.roomId).emit('user_started_sharing', {
          socketId: socket.id,
          userId: userData.userId
        });
      }
    });

    socket.on('stop_screen_sharing', () => {
      if (userData.roomId) {
        socket.to(userData.roomId).emit('user_stopped_sharing', {
          socketId: socket.id,
          userId: userData.userId
        });
      }
    });

    // Handle chat messages
    socket.on('send_message', (data) => {
      const { roomId, message } = data;
      const messageWithMetadata = {
        ...message,
        senderId: userData.userId,
        senderName: userData.username,
        timestamp: new Date().toISOString()
      };
      
      // Broadcast to everyone in the room including sender
      io.to(roomId).emit('new_message', messageWithMetadata);
    });

    // Handle mute/unmute events
    socket.on('toggle_audio', (data) => {
      const { isAudioEnabled } = data;
      if (userData.roomId) {
        socket.to(userData.roomId).emit('user_toggle_audio', {
          socketId: socket.id,
          userId: userData.userId,
          isAudioEnabled
        });
      }
    });

    socket.on('toggle_video', (data) => {
      const { isVideoEnabled } = data;
      if (userData.roomId) {
        socket.to(userData.roomId).emit('user_toggle_video', {
          socketId: socket.id,
          userId: userData.userId,
          isVideoEnabled
        });
      }
    });

    // Handle disconnection
    socket.on('disconnect', () => {
      console.log(`Client disconnected: ${socket.id}`);
      
      // Remove user from room
      if (userData.roomId && rooms.has(userData.roomId)) {
        const room = rooms.get(userData.roomId);
        room.delete(socket.id);
        
        // Notify other participants
        socket.to(userData.roomId).emit('user_left', {
          socketId: socket.id,
          userId: userData.userId
        });
        
        // Clean up empty rooms
        if (room.size === 0) {
          rooms.delete(userData.roomId);
          console.log(`Room ${userData.roomId} deleted (empty)`);
        }
      }
    });
    
    // Handle explicit leaving
    socket.on('leave_room', () => {
      if (userData.roomId && rooms.has(userData.roomId)) {
        const room = rooms.get(userData.roomId);
        room.delete(socket.id);
        
        // Notify other participants
        socket.to(userData.roomId).emit('user_left', {
          socketId: socket.id,
          userId: userData.userId
        });
        
        // Leave the socket room
        socket.leave(userData.roomId);
        
        // Clean up empty rooms
        if (room.size === 0) {
          rooms.delete(userData.roomId);
          console.log(`Room ${userData.roomId} deleted (empty)`);
        }
        
        console.log(`User ${userData.username} (${userData.userId}) left room ${userData.roomId}`);
        
        // Reset user data
        userData.roomId = null;
      }
    });
  });
}

module.exports = { setupSocketHandlers }; 