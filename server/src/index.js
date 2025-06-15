require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const { setupSocketHandlers } = require('./socket-handlers');
const { v4: uuidv4 } = require('uuid');
const { initializeFirebaseAdmin, admin } = require('./firebase-config');

// Initialize Firebase Admin SDK
initializeFirebaseAdmin();

// Store active rooms and participants
const rooms = new Map();

// Initialize express app
const app = express();
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*'
}));
app.use(express.json());

// Basic routes
app.get('/', (req, res) => {
  res.send('Teams Clone Signaling Server is running');
});

app.get('/api/status', (req, res) => {
  res.json({ 
    status: 'ok',
    activeRooms: Array.from(rooms.keys()).length
  });
});

// Firebase authentication middleware
const authenticateFirebase = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    res.status(401).json({ error: 'Authentication failed' });
  }
};

// Protected route example
app.get('/api/protected', authenticateFirebase, (req, res) => {
  res.json({ 
    message: 'This is a protected endpoint',
    user: req.user
  });
});

// Create HTTP server and Socket.IO instance
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST']
  }
});

// Set up Socket.IO event handlers
setupSocketHandlers(io, rooms);

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Signaling server running on port ${PORT}`);
}); 