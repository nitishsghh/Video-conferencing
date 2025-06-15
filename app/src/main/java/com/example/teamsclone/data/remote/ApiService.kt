package com.example.teamsclone.data.remote

import com.example.teamsclone.data.model.Meeting
import com.example.teamsclone.data.model.Message
import com.example.teamsclone.data.model.Participant
import com.example.teamsclone.data.model.User
import com.example.teamsclone.data.remote.request.CreateMeetingRequest
import com.example.teamsclone.data.remote.request.JoinMeetingRequest
import com.example.teamsclone.data.remote.request.LoginRequest
import com.example.teamsclone.data.remote.request.RegisterRequest
import com.example.teamsclone.data.remote.request.SendMessageRequest
import com.example.teamsclone.data.remote.request.UpdateUserRequest
import com.example.teamsclone.data.remote.response.AuthResponse
import com.example.teamsclone.data.remote.response.BaseResponse
import com.example.teamsclone.data.remote.response.IceServersResponse
import okhttp3.MultipartBody
import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.GET
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.PUT
import retrofit2.http.Part
import retrofit2.http.Path
import retrofit2.http.Query

interface ApiService {
    
    // Authentication endpoints
    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): AuthResponse
    
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): AuthResponse
    
    @POST("auth/logout")
    suspend fun logout(): BaseResponse
    
    // User endpoints
    @GET("users")
    suspend fun getUsers(): List<User>
    
    @GET("users/{userId}")
    suspend fun getUserById(@Path("userId") userId: String): User
    
    @PUT("users/{userId}")
    suspend fun updateUser(@Path("userId") userId: String, @Body request: UpdateUserRequest): User
    
    @Multipart
    @POST("users/{userId}/photo")
    suspend fun uploadUserPhoto(
        @Path("userId") userId: String,
        @Part photo: MultipartBody.Part
    ): User
    
    // Meeting endpoints
    @POST("meetings")
    suspend fun createMeeting(@Body request: CreateMeetingRequest): Meeting
    
    @GET("meetings")
    suspend fun getMeetings(
        @Query("userId") userId: String? = null,
        @Query("status") status: String? = null,
        @Query("startDate") startDate: Long? = null,
        @Query("endDate") endDate: Long? = null
    ): List<Meeting>
    
    @GET("meetings/{meetingId}")
    suspend fun getMeetingById(@Path("meetingId") meetingId: String): Meeting
    
    @PUT("meetings/{meetingId}")
    suspend fun updateMeeting(
        @Path("meetingId") meetingId: String,
        @Body meeting: Meeting
    ): Meeting
    
    @DELETE("meetings/{meetingId}")
    suspend fun deleteMeeting(@Path("meetingId") meetingId: String): BaseResponse
    
    @POST("meetings/{meetingId}/join")
    suspend fun joinMeeting(
        @Path("meetingId") meetingId: String,
        @Body request: JoinMeetingRequest
    ): Participant
    
    @POST("meetings/{meetingId}/leave")
    suspend fun leaveMeeting(
        @Path("meetingId") meetingId: String,
        @Query("participantId") participantId: String
    ): BaseResponse
    
    // Participant endpoints
    @GET("meetings/{meetingId}/participants")
    suspend fun getParticipants(@Path("meetingId") meetingId: String): List<Participant>
    
    @PUT("meetings/{meetingId}/participants/{participantId}")
    suspend fun updateParticipant(
        @Path("meetingId") meetingId: String,
        @Path("participantId") participantId: String,
        @Body participant: Participant
    ): Participant
    
    // Message endpoints
    @GET("meetings/{meetingId}/messages")
    suspend fun getMessages(
        @Path("meetingId") meetingId: String,
        @Query("limit") limit: Int? = null,
        @Query("before") before: Long? = null
    ): List<Message>
    
    @POST("meetings/{meetingId}/messages")
    suspend fun sendMessage(
        @Path("meetingId") meetingId: String,
        @Body request: SendMessageRequest
    ): Message
    
    @Multipart
    @POST("meetings/{meetingId}/messages/file")
    suspend fun sendFileMessage(
        @Path("meetingId") meetingId: String,
        @Part("senderId") senderId: String,
        @Part("senderName") senderName: String,
        @Part file: MultipartBody.Part
    ): Message
    
    // WebRTC related endpoints
    @GET("webrtc/ice-servers")
    suspend fun getIceServers(): IceServersResponse
} 