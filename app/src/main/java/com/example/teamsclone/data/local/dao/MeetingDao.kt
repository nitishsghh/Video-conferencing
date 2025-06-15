package com.example.teamsclone.data.local.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.example.teamsclone.data.model.Meeting
import com.example.teamsclone.data.model.MeetingStatus
import kotlinx.coroutines.flow.Flow

@Dao
interface MeetingDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(meeting: Meeting)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(meetings: List<Meeting>)
    
    @Update
    suspend fun update(meeting: Meeting)
    
    @Delete
    suspend fun delete(meeting: Meeting)
    
    @Query("DELETE FROM meetings")
    suspend fun deleteAll()
    
    @Query("SELECT * FROM meetings WHERE id = :meetingId")
    suspend fun getMeetingById(meetingId: String): Meeting?
    
    @Query("SELECT * FROM meetings WHERE id = :meetingId")
    fun observeMeetingById(meetingId: String): Flow<Meeting?>
    
    @Query("SELECT * FROM meetings ORDER BY startTime DESC")
    fun getAllMeetings(): Flow<List<Meeting>>
    
    @Query("SELECT * FROM meetings WHERE hostId = :userId ORDER BY startTime DESC")
    fun getMeetingsByHostId(userId: String): Flow<List<Meeting>>
    
    @Query("SELECT * FROM meetings WHERE :userId IN (participantIds) ORDER BY startTime DESC")
    fun getMeetingsByParticipantId(userId: String): Flow<List<Meeting>>
    
    @Query("SELECT * FROM meetings WHERE status = :status ORDER BY startTime DESC")
    fun getMeetingsByStatus(status: MeetingStatus): Flow<List<Meeting>>
    
    @Query("SELECT * FROM meetings WHERE startTime >= :startTime AND startTime <= :endTime ORDER BY startTime ASC")
    fun getMeetingsBetweenDates(startTime: Long, endTime: Long): Flow<List<Meeting>>
    
    @Query("SELECT * FROM meetings WHERE startTime >= :now ORDER BY startTime ASC")
    fun getUpcomingMeetings(now: Long = System.currentTimeMillis()): Flow<List<Meeting>>
    
    @Query("SELECT * FROM meetings WHERE endTime < :now ORDER BY startTime DESC")
    fun getPastMeetings(now: Long = System.currentTimeMillis()): Flow<List<Meeting>>
    
    @Query("SELECT * FROM meetings WHERE title LIKE '%' || :query || '%' OR description LIKE '%' || :query || '%'")
    fun searchMeetings(query: String): Flow<List<Meeting>>
    
    @Query("UPDATE meetings SET status = :status WHERE id = :meetingId")
    suspend fun updateMeetingStatus(meetingId: String, status: MeetingStatus)
} 