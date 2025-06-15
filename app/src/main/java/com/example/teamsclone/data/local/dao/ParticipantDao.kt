package com.example.teamsclone.data.local.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.example.teamsclone.data.model.Participant
import com.example.teamsclone.data.model.ParticipantRole
import kotlinx.coroutines.flow.Flow

@Dao
interface ParticipantDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(participant: Participant)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(participants: List<Participant>)
    
    @Update
    suspend fun update(participant: Participant)
    
    @Delete
    suspend fun delete(participant: Participant)
    
    @Query("DELETE FROM participants")
    suspend fun deleteAll()
    
    @Query("SELECT * FROM participants WHERE id = :participantId")
    suspend fun getParticipantById(participantId: String): Participant?
    
    @Query("SELECT * FROM participants WHERE meetingId = :meetingId")
    fun getParticipantsByMeetingId(meetingId: String): Flow<List<Participant>>
    
    @Query("SELECT * FROM participants WHERE userId = :userId")
    fun getParticipantsByUserId(userId: String): Flow<List<Participant>>
    
    @Query("SELECT * FROM participants WHERE meetingId = :meetingId AND userId = :userId LIMIT 1")
    suspend fun getParticipantByMeetingAndUserId(meetingId: String, userId: String): Participant?
    
    @Query("SELECT * FROM participants WHERE meetingId = :meetingId AND role = :role")
    fun getParticipantsByRole(meetingId: String, role: ParticipantRole): Flow<List<Participant>>
    
    @Query("SELECT * FROM participants WHERE meetingId = :meetingId AND isHandRaised = 1")
    fun getParticipantsWithRaisedHands(meetingId: String): Flow<List<Participant>>
    
    @Query("SELECT COUNT(*) FROM participants WHERE meetingId = :meetingId AND leaveTime IS NULL")
    fun getActiveParticipantCount(meetingId: String): Flow<Int>
    
    @Query("UPDATE participants SET isAudioEnabled = :isEnabled WHERE id = :participantId")
    suspend fun updateAudioState(participantId: String, isEnabled: Boolean)
    
    @Query("UPDATE participants SET isVideoEnabled = :isEnabled WHERE id = :participantId")
    suspend fun updateVideoState(participantId: String, isEnabled: Boolean)
    
    @Query("UPDATE participants SET isSharingScreen = :isSharing WHERE id = :participantId")
    suspend fun updateScreenSharingState(participantId: String, isSharing: Boolean)
    
    @Query("UPDATE participants SET isHandRaised = :isRaised WHERE id = :participantId")
    suspend fun updateHandRaisedState(participantId: String, isRaised: Boolean)
    
    @Query("UPDATE participants SET leaveTime = :leaveTime WHERE id = :participantId")
    suspend fun updateLeaveTime(participantId: String, leaveTime: Long = System.currentTimeMillis())
    
    @Query("UPDATE participants SET connectionQuality = :quality WHERE id = :participantId")
    suspend fun updateConnectionQuality(participantId: String, quality: Int)
} 