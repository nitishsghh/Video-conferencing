package com.example.teamsclone.data.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity(tableName = "messages")
data class Message(
    @PrimaryKey
    val id: String,
    val meetingId: String,
    val senderId: String,
    val senderName: String,
    val content: String,
    val timestamp: Long = System.currentTimeMillis(),
    val type: MessageType = MessageType.TEXT,
    val fileUrl: String? = null,
    val fileName: String? = null,
    val fileSize: Long? = null,
    val fileMimeType: String? = null,
    val isRead: Boolean = false,
    val replyToMessageId: String? = null,
    val reactions: Map<String, String> = emptyMap() // userId to reaction emoji
) : Parcelable

enum class MessageType {
    TEXT,
    FILE,
    IMAGE,
    VIDEO,
    AUDIO,
    SYSTEM
} 