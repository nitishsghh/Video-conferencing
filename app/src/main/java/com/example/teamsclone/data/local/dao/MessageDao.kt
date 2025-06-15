package com.example.teamsclone.data.local.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.example.teamsclone.data.model.Message
import com.example.teamsclone.data.model.MessageType
import kotlinx.coroutines.flow.Flow

@Dao
interface MessageDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(message: Message)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(messages: List<Message>)
    
    @Update
    suspend fun update(message: Message)
    
    @Delete
    suspend fun delete(message: Message)
    
    @Query("DELETE FROM messages")
    suspend fun deleteAll()
    
    @Query("SELECT * FROM messages WHERE id = :messageId")
    suspend fun getMessageById(messageId: String): Message?
    
    @Query("SELECT * FROM messages WHERE meetingId = :meetingId ORDER BY timestamp ASC")
    fun getMessagesByMeetingId(meetingId: String): Flow<List<Message>>
    
    @Query("SELECT * FROM messages WHERE meetingId = :meetingId ORDER BY timestamp DESC LIMIT :limit")
    fun getRecentMessagesByMeetingId(meetingId: String, limit: Int): Flow<List<Message>>
    
    @Query("SELECT * FROM messages WHERE senderId = :userId ORDER BY timestamp DESC")
    fun getMessagesBySenderId(userId: String): Flow<List<Message>>
    
    @Query("SELECT * FROM messages WHERE type = :type ORDER BY timestamp DESC")
    fun getMessagesByType(type: MessageType): Flow<List<Message>>
    
    @Query("SELECT * FROM messages WHERE meetingId = :meetingId AND type = :type ORDER BY timestamp ASC")
    fun getMessagesByMeetingIdAndType(meetingId: String, type: MessageType): Flow<List<Message>>
    
    @Query("SELECT * FROM messages WHERE content LIKE '%' || :query || '%' ORDER BY timestamp DESC")
    fun searchMessages(query: String): Flow<List<Message>>
    
    @Query("UPDATE messages SET isRead = 1 WHERE meetingId = :meetingId AND senderId != :currentUserId")
    suspend fun markAllMessagesAsRead(meetingId: String, currentUserId: String)
    
    @Query("SELECT COUNT(*) FROM messages WHERE meetingId = :meetingId AND isRead = 0 AND senderId != :currentUserId")
    fun getUnreadMessageCount(meetingId: String, currentUserId: String): Flow<Int>
} 