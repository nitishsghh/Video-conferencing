package com.example.teamsclone.data.repository

import com.example.teamsclone.data.local.dao.ParticipantDao
import com.example.teamsclone.data.model.ConnectionQuality
import com.example.teamsclone.data.model.Participant
import com.example.teamsclone.data.model.ParticipantRole
import com.example.teamsclone.data.remote.ApiService
import com.example.teamsclone.utils.NetworkResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ParticipantRepository @Inject constructor(
    private val participantDao: ParticipantDao,
    private val apiService: ApiService
) {
    
    // Local database operations
    suspend fun insertParticipant(participant: Participant) = participantDao.insert(participant)
    
    suspend fun insertAllParticipants(participants: List<Participant>) = participantDao.insertAll(participants)
    
    suspend fun updateParticipant(participant: Participant) = participantDao.update(participant)
    
    suspend fun deleteParticipant(participant: Participant) = participantDao.delete(participant)
    
    suspend fun getParticipantById(participantId: String): Participant? = participantDao.getParticipantById(participantId)
    
    fun getParticipantsByMeetingId(meetingId: String): Flow<List<Participant>> = 
        participantDao.getParticipantsByMeetingId(meetingId)
    
    fun getParticipantsByUserId(userId: String): Flow<List<Participant>> = 
        participantDao.getParticipantsByUserId(userId)
    
    suspend fun getParticipantByMeetingAndUserId(meetingId: String, userId: String): Participant? = 
        participantDao.getParticipantByMeetingAndUserId(meetingId, userId)
    
    fun getParticipantsByRole(meetingId: String, role: ParticipantRole): Flow<List<Participant>> = 
        participantDao.getParticipantsByRole(meetingId, role)
    
    fun getParticipantsWithRaisedHands(meetingId: String): Flow<List<Participant>> = 
        participantDao.getParticipantsWithRaisedHands(meetingId)
    
    fun getActiveParticipantCount(meetingId: String): Flow<Int> = 
        participantDao.getActiveParticipantCount(meetingId)
    
    // Remote API operations
    suspend fun fetchParticipants(meetingId: String): NetworkResult<List<Participant>> {
        return withContext(Dispatchers.IO) {
            try {
                val participants = apiService.getParticipants(meetingId)
                
                // Cache participants locally
                insertAllParticipants(participants)
                
                NetworkResult.Success(participants)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to fetch participants")
            }
        }
    }
    
    suspend fun updateParticipantDetails(
        meetingId: String,
        participantId: String,
        participant: Participant
    ): NetworkResult<Participant> {
        return withContext(Dispatchers.IO) {
            try {
                val updatedParticipant = apiService.updateParticipant(
                    meetingId = meetingId,
                    participantId = participantId,
                    participant = participant
                )
                
                // Update local cache
                insertParticipant(updatedParticipant)
                
                NetworkResult.Success(updatedParticipant)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update participant")
            }
        }
    }
    
    // Media state updates
    suspend fun updateAudioState(participantId: String, isEnabled: Boolean): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                participantDao.updateAudioState(participantId, isEnabled)
                
                // Get participant and update on server
                val participant = getParticipantById(participantId)
                participant?.let {
                    val updatedParticipant = it.copy(isAudioEnabled = isEnabled)
                    updateParticipantDetails(it.meetingId, it.id, updatedParticipant)
                }
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update audio state")
            }
        }
    }
    
    suspend fun updateVideoState(participantId: String, isEnabled: Boolean): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                participantDao.updateVideoState(participantId, isEnabled)
                
                // Get participant and update on server
                val participant = getParticipantById(participantId)
                participant?.let {
                    val updatedParticipant = it.copy(isVideoEnabled = isEnabled)
                    updateParticipantDetails(it.meetingId, it.id, updatedParticipant)
                }
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update video state")
            }
        }
    }
    
    suspend fun updateScreenSharingState(participantId: String, isSharing: Boolean): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                participantDao.updateScreenSharingState(participantId, isSharing)
                
                // Get participant and update on server
                val participant = getParticipantById(participantId)
                participant?.let {
                    val updatedParticipant = it.copy(isSharingScreen = isSharing)
                    updateParticipantDetails(it.meetingId, it.id, updatedParticipant)
                }
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update screen sharing state")
            }
        }
    }
    
    suspend fun updateHandRaisedState(participantId: String, isRaised: Boolean): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                participantDao.updateHandRaisedState(participantId, isRaised)
                
                // Get participant and update on server
                val participant = getParticipantById(participantId)
                participant?.let {
                    val updatedParticipant = it.copy(isHandRaised = isRaised)
                    updateParticipantDetails(it.meetingId, it.id, updatedParticipant)
                }
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update hand raised state")
            }
        }
    }
    
    suspend fun updateConnectionQuality(participantId: String, quality: ConnectionQuality): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                participantDao.updateConnectionQuality(participantId, quality.ordinal)
                
                // Get participant and update on server
                val participant = getParticipantById(participantId)
                participant?.let {
                    val updatedParticipant = it.copy(connectionQuality = quality)
                    updateParticipantDetails(it.meetingId, it.id, updatedParticipant)
                }
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update connection quality")
            }
        }
    }
    
    suspend fun recordParticipantLeave(participantId: String): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                val leaveTime = System.currentTimeMillis()
                participantDao.updateLeaveTime(participantId, leaveTime)
                
                // Get participant and update on server
                val participant = getParticipantById(participantId)
                participant?.let {
                    val updatedParticipant = it.copy(leaveTime = leaveTime)
                    updateParticipantDetails(it.meetingId, it.id, updatedParticipant)
                }
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to record participant leave")
            }
        }
    }
    
    // Helper function to generate a unique participant ID
    fun generateParticipantId(): String {
        return UUID.randomUUID().toString()
    }
} 