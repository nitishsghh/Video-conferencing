const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Store active users and their socket IDs
const users = new Map();
// Store active meetings
const meetings = new Map();
// Store active calls
const calls = new Map();

io.on('connection', (socket) => {
  console.log(`User connected: ${socket.id}`);
  
  // Register user
  socket.on('register', (data) => {
    const { userId } = data;
    users.set(userId, socket.id);
    console.log(`User registered: ${userId} with socket ID: ${socket.id}`);
  });
  
  // Create meeting
  socket.on('create-meeting', (data) => {
    const { meetingId, userId } = data;
    
    if (!meetings.has(meetingId)) {
      meetings.set(meetingId, new Set([userId]));
      socket.join(meetingId);
      console.log(`Meeting created: ${meetingId} by user: ${userId}`);
    } else {
      socket.emit('error', { message: 'Meeting ID already exists' });
    }
  });
  
  // Join meeting
  socket.on('join-meeting', (data) => {
    const { meetingId, userId } = data;
    
    if (meetings.has(meetingId)) {
      const participants = meetings.get(meetingId);
      
      // Notify existing participants about new user
      participants.forEach((participantId) => {
        if (participantId !== userId) {
          const participantSocketId = users.get(participantId);
          if (participantSocketId) {
            io.to(participantSocketId).emit('user-joined', { userId });
            socket.emit('user-joined', { userId: participantId });
          }
        }
      });
      
      // Add user to meeting
      participants.add(userId);
      socket.join(meetingId);
      console.log(`User ${userId} joined meeting: ${meetingId}`);
    } else {
      socket.emit('error', { message: 'Meeting not found' });
    }
  });
  
  // Leave meeting
  socket.on('leave-meeting', (data) => {
    const { meetingId, userId } = data;
    
    if (meetings.has(meetingId)) {
      const participants = meetings.get(meetingId);
      
      // Remove user from meeting
      participants.delete(userId);
      socket.leave(meetingId);
      
      // Notify other participants
      participants.forEach((participantId) => {
        const participantSocketId = users.get(participantId);
        if (participantSocketId) {
          io.to(participantSocketId).emit('user-left', { userId });
        }
      });
      
      // If no participants left, remove the meeting
      if (participants.size === 0) {
        meetings.delete(meetingId);
        console.log(`Meeting ended: ${meetingId}`);
      }
      
      console.log(`User ${userId} left meeting: ${meetingId}`);
    }
  });
  
  // Handle WebRTC signaling
  
  // Offer
  socket.on('offer', (data) => {
    const { to, from, callId, description } = data;
    const toSocketId = users.get(to);
    
    if (toSocketId) {
      io.to(toSocketId).emit('offer', { from, description, callId });
      
      // Store call information
      if (callId) {
        calls.set(callId, { from, to });
      }
      
      console.log(`Offer sent from ${from} to ${to}`);
    }
  });
  
  // Answer
  socket.on('answer', (data) => {
    const { to, from, description } = data;
    const toSocketId = users.get(to);
    
    if (toSocketId) {
      io.to(toSocketId).emit('answer', { from, description });
      console.log(`Answer sent from ${from} to ${to}`);
    }
  });
  
  // ICE Candidate
  socket.on('ice-candidate', (data) => {
    const { to, from, candidate } = data;
    const toSocketId = users.get(to);
    
    if (toSocketId) {
      io.to(toSocketId).emit('ice-candidate', { from, candidate });
      console.log(`ICE candidate sent from ${from} to ${to}`);
    }
  });
  
  // End call
  socket.on('end-call', (data) => {
    const { callId, userId } = data;
    
    if (calls.has(callId)) {
      const { from, to } = calls.get(callId);
      const otherUserId = userId === from ? to : from;
      const otherUserSocketId = users.get(otherUserId);
      
      if (otherUserSocketId) {
        io.to(otherUserSocketId).emit('call-ended', { callId, userId });
      }
      
      calls.delete(callId);
      console.log(`Call ended: ${callId}`);
    }
  });
  
  // Disconnect
  socket.on('disconnect', () => {
    console.log(`User disconnected: ${socket.id}`);
    
    // Find and remove user
    let disconnectedUserId = null;
    for (const [userId, socketId] of users.entries()) {
      if (socketId === socket.id) {
        disconnectedUserId = userId;
        users.delete(userId);
        break;
      }
    }
    
    if (disconnectedUserId) {
      // Remove user from all meetings
      for (const [meetingId, participants] of meetings.entries()) {
        if (participants.has(disconnectedUserId)) {
          participants.delete(disconnectedUserId);
          
          // Notify other participants
          participants.forEach((participantId) => {
            const participantSocketId = users.get(participantId);
            if (participantSocketId) {
              io.to(participantSocketId).emit('user-left', { userId: disconnectedUserId });
            }
          });
          
          // If no participants left, remove the meeting
          if (participants.size === 0) {
            meetings.delete(meetingId);
            console.log(`Meeting ended: ${meetingId}`);
          }
        }
      }
      
      // End all calls involving this user
      for (const [callId, call] of calls.entries()) {
        if (call.from === disconnectedUserId || call.to === disconnectedUserId) {
          const otherUserId = call.from === disconnectedUserId ? call.to : call.from;
          const otherUserSocketId = users.get(otherUserId);
          
          if (otherUserSocketId) {
            io.to(otherUserSocketId).emit('call-ended', { callId, userId: disconnectedUserId });
          }
          
          calls.delete(callId);
          console.log(`Call ended: ${callId}`);
        }
      }
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Signaling server running on port ${PORT}`);
}); 