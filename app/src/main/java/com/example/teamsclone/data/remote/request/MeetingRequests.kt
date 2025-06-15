package com.example.teamsclone.data.remote.request

import com.example.teamsclone.data.model.RecurringPattern

data class CreateMeetingRequest(
    val title: String,
    val description: String? = null,
    val hostId: String,
    val password: String? = null,
    val startTime: Long,
    val endTime: Long,
    val participantIds: List<String> = emptyList(),
    val isRecurring: Boolean = false,
    val recurringPattern: RecurringPattern? = null,
    val isRecordingEnabled: Boolean = false
)

data class JoinMeetingRequest(
    val userId: String,
    val displayName: String,
    val password: String? = null
)

data class SendMessageRequest(
    val senderId: String,
    val senderName: String,
    val content: String,
    val type: String = "TEXT",
    val replyToMessageId: String? = null
) 