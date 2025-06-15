/**
 * Firebase Admin SDK configuration
 * IMPORTANT: Actual credentials should be stored in environment variables
 * or in a .env file that is not committed to version control
 */
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const initializeFirebaseAdmin = () => {
  try {
    // Check if credentials are provided via environment variables
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      // Parse the JSON string from environment variable
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      
      console.log('Firebase Admin SDK initialized successfully with env credentials');
    } else {
      // For local development, you can use a service account file
      // that is not committed to version control
      try {
        const serviceAccount = require('../firebase-service-account.json');
        
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount)
        });
        
        console.log('Firebase Admin SDK initialized successfully with local credentials');
      } catch (error) {
        console.warn('Firebase service account file not found. Firebase Admin SDK not initialized.');
        console.warn('To use Firebase services, please provide credentials via environment variables');
        console.warn('or place firebase-service-account.json in the server root directory.');
      }
    }
  } catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error);
  }
};

module.exports = {
  admin,
  initializeFirebaseAdmin
}; 