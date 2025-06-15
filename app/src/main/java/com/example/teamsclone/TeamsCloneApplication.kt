package com.example.teamsclone

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

@HiltAndroidApp
class TeamsCloneApplication : Application() {

    companion object {
        const val CALL_NOTIFICATION_CHANNEL_ID = "call_notification_channel"
        const val CHAT_NOTIFICATION_CHANNEL_ID = "chat_notification_channel"
        const val MEETING_NOTIFICATION_CHANNEL_ID = "meeting_notification_channel"
    }

    override fun onCreate() {
        super.onCreate()
        
        // Setup Timber for logging
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
        
        // Create notification channels
        createNotificationChannels()
    }
    
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Call notification channel
            val callChannel = NotificationChannel(
                CALL_NOTIFICATION_CHANNEL_ID,
                "Calls",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for incoming and ongoing calls"
                enableVibration(true)
                enableLights(true)
            }
            
            // Chat notification channel
            val chatChannel = NotificationChannel(
                CHAT_NOTIFICATION_CHANNEL_ID,
                "Chat Messages",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for new chat messages"
            }
            
            // Meeting notification channel
            val meetingChannel = NotificationChannel(
                MEETING_NOTIFICATION_CHANNEL_ID,
                "Meeting Reminders",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for upcoming meetings"
            }
            
            // Register the channels with the system
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannels(listOf(callChannel, chatChannel, meetingChannel))
        }
    }
} 