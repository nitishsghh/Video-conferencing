package com.example.teamsclone.data.repository

import com.example.teamsclone.data.local.dao.MessageDao
import com.example.teamsclone.data.model.Message
import com.example.teamsclone.data.model.MessageType
import com.example.teamsclone.data.remote.ApiService
import com.example.teamsclone.data.remote.request.SendMessageRequest
import com.example.teamsclone.utils.NetworkResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MessageRepository @Inject constructor(
    private val messageDao: MessageDao,
    private val apiService: ApiService
) {
    
    // Local database operations
    suspend fun insertMessage(message: Message) = messageDao.insert(message)
    
    suspend fun insertAllMessages(messages: List<Message>) = messageDao.insertAll(messages)
    
    suspend fun updateMessage(message: Message) = messageDao.update(message)
    
    suspend fun deleteMessage(message: Message) = messageDao.delete(message)
    
    suspend fun getMessageById(messageId: String): Message? = messageDao.getMessageById(messageId)
    
    fun getMessagesByMeetingId(meetingId: String): Flow<List<Message>> = messageDao.getMessagesByMeetingId(meetingId)
    
    fun getRecentMessagesByMeetingId(meetingId: String, limit: Int): Flow<List<Message>> = 
        messageDao.getRecentMessagesByMeetingId(meetingId, limit)
    
    fun getMessagesByType(type: MessageType): Flow<List<Message>> = messageDao.getMessagesByType(type)
    
    fun getMessagesByMeetingIdAndType(meetingId: String, type: MessageType): Flow<List<Message>> = 
        messageDao.getMessagesByMeetingIdAndType(meetingId, type)
    
    fun searchMessages(query: String): Flow<List<Message>> = messageDao.searchMessages(query)
    
    suspend fun markAllMessagesAsRead(meetingId: String, currentUserId: String) = 
        messageDao.markAllMessagesAsRead(meetingId, currentUserId)
    
    fun getUnreadMessageCount(meetingId: String, currentUserId: String): Flow<Int> = 
        messageDao.getUnreadMessageCount(meetingId, currentUserId)
    
    // Remote API operations
    suspend fun fetchMessages(
        meetingId: String,
        limit: Int? = null,
        before: Long? = null
    ): NetworkResult<List<Message>> {
        return withContext(Dispatchers.IO) {
            try {
                val messages = apiService.getMessages(meetingId, limit, before)
                
                // Cache messages locally
                insertAllMessages(messages)
                
                NetworkResult.Success(messages)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to fetch messages")
            }
        }
    }
    
    suspend fun sendMessage(
        meetingId: String,
        senderId: String,
        senderName: String,
        content: String,
        type: MessageType = MessageType.TEXT,
        replyToMessageId: String? = null
    ): NetworkResult<Message> {
        return withContext(Dispatchers.IO) {
            try {
                val request = SendMessageRequest(
                    senderId = senderId,
                    senderName = senderName,
                    content = content,
                    type = type.name,
                    replyToMessageId = replyToMessageId
                )
                
                val message = apiService.sendMessage(meetingId, request)
                
                // Cache message locally
                insertMessage(message)
                
                NetworkResult.Success(message)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to send message")
            }
        }
    }
    
    suspend fun sendFileMessage(
        meetingId: String,
        senderId: String,
        senderName: String,
        file: File
    ): NetworkResult<Message> {
        return withContext(Dispatchers.IO) {
            try {
                val requestFile = file.asRequestBody(getMimeType(file).toMediaTypeOrNull())
                val filePart = MultipartBody.Part.createFormData("file", file.name, requestFile)
                
                val message = apiService.sendFileMessage(
                    meetingId = meetingId,
                    senderId = senderId,
                    senderName = senderName,
                    file = filePart
                )
                
                // Cache message locally
                insertMessage(message)
                
                NetworkResult.Success(message)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to send file")
            }
        }
    }
    
    // Helper function to determine MIME type from file extension
    private fun getMimeType(file: File): String {
        return when (file.extension.lowercase()) {
            "jpg", "jpeg" -> "image/jpeg"
            "png" -> "image/png"
            "gif" -> "image/gif"
            "mp4" -> "video/mp4"
            "mp3" -> "audio/mp3"
            "pdf" -> "application/pdf"
            "doc", "docx" -> "application/msword"
            "xls", "xlsx" -> "application/vnd.ms-excel"
            "ppt", "pptx" -> "application/vnd.ms-powerpoint"
            "txt" -> "text/plain"
            else -> "application/octet-stream"
        }
    }
    
    // Helper function to generate a unique message ID
    fun generateMessageId(): String {
        return UUID.randomUUID().toString()
    }
} 