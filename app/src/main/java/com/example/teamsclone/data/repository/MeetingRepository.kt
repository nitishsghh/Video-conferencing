package com.example.teamsclone.data.repository

import com.example.teamsclone.data.local.dao.MeetingDao
import com.example.teamsclone.data.model.Meeting
import com.example.teamsclone.data.model.MeetingStatus
import com.example.teamsclone.data.model.RecurringPattern
import com.example.teamsclone.data.remote.ApiService
import com.example.teamsclone.data.remote.request.CreateMeetingRequest
import com.example.teamsclone.data.remote.request.JoinMeetingRequest
import com.example.teamsclone.utils.NetworkResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MeetingRepository @Inject constructor(
    private val meetingDao: MeetingDao,
    private val apiService: ApiService
) {
    
    // Local database operations
    suspend fun insertMeeting(meeting: Meeting) = meetingDao.insert(meeting)
    
    suspend fun updateMeeting(meeting: Meeting) = meetingDao.update(meeting)
    
    suspend fun deleteMeeting(meeting: Meeting) = meetingDao.delete(meeting)
    
    suspend fun getMeetingById(meetingId: String): Meeting? = meetingDao.getMeetingById(meetingId)
    
    fun observeMeetingById(meetingId: String): Flow<Meeting?> = meetingDao.observeMeetingById(meetingId)
    
    fun getAllMeetings(): Flow<List<Meeting>> = meetingDao.getAllMeetings()
    
    fun getMeetingsByHostId(userId: String): Flow<List<Meeting>> = meetingDao.getMeetingsByHostId(userId)
    
    fun getMeetingsByParticipantId(userId: String): Flow<List<Meeting>> = meetingDao.getMeetingsByParticipantId(userId)
    
    fun getMeetingsByStatus(status: MeetingStatus): Flow<List<Meeting>> = meetingDao.getMeetingsByStatus(status)
    
    fun getUpcomingMeetings(): Flow<List<Meeting>> = meetingDao.getUpcomingMeetings()
    
    fun getPastMeetings(): Flow<List<Meeting>> = meetingDao.getPastMeetings()
    
    fun searchMeetings(query: String): Flow<List<Meeting>> = meetingDao.searchMeetings(query)
    
    // Remote API operations
    suspend fun createMeeting(
        title: String,
        description: String? = null,
        hostId: String,
        password: String? = null,
        startTime: Long,
        endTime: Long,
        participantIds: List<String> = emptyList(),
        isRecurring: Boolean = false,
        recurringPattern: RecurringPattern? = null,
        isRecordingEnabled: Boolean = false
    ): NetworkResult<Meeting> {
        return withContext(Dispatchers.IO) {
            try {
                val request = CreateMeetingRequest(
                    title = title,
                    description = description,
                    hostId = hostId,
                    password = password,
                    startTime = startTime,
                    endTime = endTime,
                    participantIds = participantIds,
                    isRecurring = isRecurring,
                    recurringPattern = recurringPattern,
                    isRecordingEnabled = isRecordingEnabled
                )
                
                val meeting = apiService.createMeeting(request)
                
                // Cache the meeting locally
                insertMeeting(meeting)
                
                NetworkResult.Success(meeting)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to create meeting")
            }
        }
    }
    
    suspend fun fetchMeetings(
        userId: String? = null,
        status: MeetingStatus? = null,
        startDate: Long? = null,
        endDate: Long? = null
    ): NetworkResult<List<Meeting>> {
        return withContext(Dispatchers.IO) {
            try {
                val meetings = apiService.getMeetings(
                    userId = userId,
                    status = status?.name,
                    startDate = startDate,
                    endDate = endDate
                )
                
                // Cache meetings locally
                meetings.forEach { insertMeeting(it) }
                
                NetworkResult.Success(meetings)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to fetch meetings")
            }
        }
    }
    
    suspend fun fetchMeetingById(meetingId: String): NetworkResult<Meeting> {
        return withContext(Dispatchers.IO) {
            try {
                val meeting = apiService.getMeetingById(meetingId)
                
                // Cache meeting locally
                insertMeeting(meeting)
                
                NetworkResult.Success(meeting)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to fetch meeting")
            }
        }
    }
    
    suspend fun updateMeetingDetails(meeting: Meeting): NetworkResult<Meeting> {
        return withContext(Dispatchers.IO) {
            try {
                val updatedMeeting = apiService.updateMeeting(meeting.id, meeting)
                
                // Update local cache
                insertMeeting(updatedMeeting)
                
                NetworkResult.Success(updatedMeeting)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update meeting")
            }
        }
    }
    
    suspend fun deleteMeetingById(meetingId: String): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                val response = apiService.deleteMeeting(meetingId)
                
                // Delete from local cache if successful
                getMeetingById(meetingId)?.let { deleteMeeting(it) }
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to delete meeting")
            }
        }
    }
    
    suspend fun joinMeeting(
        meetingId: String,
        userId: String,
        displayName: String,
        password: String? = null
    ): NetworkResult<String> {
        return withContext(Dispatchers.IO) {
            try {
                val request = JoinMeetingRequest(
                    userId = userId,
                    displayName = displayName,
                    password = password
                )
                
                val participant = apiService.joinMeeting(meetingId, request)
                
                // Return the participant ID
                NetworkResult.Success(participant.id)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to join meeting")
            }
        }
    }
    
    suspend fun leaveMeeting(meetingId: String, participantId: String): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                apiService.leaveMeeting(meetingId, participantId)
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to leave meeting")
            }
        }
    }
    
    suspend fun updateMeetingStatus(meetingId: String, status: MeetingStatus): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                // Update locally
                meetingDao.updateMeetingStatus(meetingId, status)
                
                // Get the meeting and update on server
                val meeting = getMeetingById(meetingId)
                meeting?.let {
                    val updatedMeeting = it.copy(status = status)
                    updateMeetingDetails(updatedMeeting)
                }
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update meeting status")
            }
        }
    }
    
    // Helper function to generate a unique meeting ID
    fun generateMeetingId(): String {
        return UUID.randomUUID().toString().substring(0, 8)
    }
}
