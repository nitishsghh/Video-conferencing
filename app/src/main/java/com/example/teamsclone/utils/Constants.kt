package com.example.teamsclone.utils

/**
 * Application-wide constants
 */
object Constants {
    // API endpoints
    const val BASE_URL = "https://your-api-server.com/api/"
    const val SOCKET_URL = "http://10.0.2.2:3000" // Points to localhost:3000 from Android emulator
    
    // WebRTC configuration
    const val ICE_SERVER_URL = "stun:stun.l.google.com:19302"
    const val TURN_SERVER_URL = "turn:your-turn-server.com"
    const val TURN_USERNAME = "username"
    const val TURN_PASSWORD = "password"
    
    // Meeting related constants
    const val DEFAULT_MEETING_DURATION_MINUTES = 60
    const val MAX_PARTICIPANTS = 100
    const val MAX_CHAT_MESSAGE_LENGTH = 1000
    
    // File sharing
    const val MAX_FILE_SIZE_MB = 100
    const val SUPPORTED_FILE_TYPES = "application/pdf,image/*,video/*,audio/*,text/plain"
    
    // Timeouts
    const val CONNECTION_TIMEOUT_SECONDS = 30
    const val CALL_TIMEOUT_SECONDS = 45
    
    // Shared preferences keys
    const val PREF_USER_ID = "user_id"
    const val PREF_AUTH_TOKEN = "auth_token"
    const val PREF_USER_NAME = "user_name"
    const val PREF_USER_EMAIL = "user_email"
    const val PREF_USER_PHOTO_URL = "user_photo_url"
    
    // Notification IDs
    const val CALL_NOTIFICATION_ID = 1001
    const val CHAT_NOTIFICATION_ID = 1002
    const val MEETING_REMINDER_NOTIFICATION_ID = 1003
    
    // Request codes
    const val CAMERA_PERMISSION_REQUEST_CODE = 101
    const val MICROPHONE_PERMISSION_REQUEST_CODE = 102
    const val SCREEN_CAPTURE_REQUEST_CODE = 103
    const val FILE_PICKER_REQUEST_CODE = 104
    
    // Deep link scheme
    const val DEEP_LINK_SCHEME = "teamsclone"
    const val DEEP_LINK_HOST = "meeting"
} 