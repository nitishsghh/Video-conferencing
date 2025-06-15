package com.example.teamsclone.webrtc

import com.example.teamsclone.utils.Constants
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter
import org.json.JSONException
import org.json.JSONObject
import org.json.JSONArray
import timber.log.Timber
import java.net.URISyntaxException
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SignalingClient @Inject constructor() {
    
    private var socket: Socket? = null
    private var listener: SignalingClientListener? = null
    private var roomId: String? = null
    private var userId: String? = null
    private var username: String? = null
    private var isInitiator = false
    
    fun initialize(userId: String, username: String) {
        this.userId = userId
        this.username = username
        try {
            socket = IO.socket(Constants.SOCKET_URL)
            
            socket?.on(Socket.EVENT_CONNECT, onConnect)
            socket?.on(Socket.EVENT_DISCONNECT, onDisconnect)
            socket?.on(Socket.EVENT_CONNECT_ERROR, onConnectError)
            
            socket?.on("room_joined", onRoomJoined)
            socket?.on("user_joined", onUserJoined)
            socket?.on("user_left", onUserLeft)
            socket?.on("ice_candidate", onIceCandidate)
            socket?.on("offer", onOffer)
            socket?.on("answer", onAnswer)
            socket?.on("error", onError)
            socket?.on("user_toggle_audio", onUserToggleAudio)
            socket?.on("user_toggle_video", onUserToggleVideo)
            socket?.on("user_started_sharing", onUserStartedSharing)
            socket?.on("user_stopped_sharing", onUserStoppedSharing)
            socket?.on("new_message", onNewMessage)
            
            socket?.connect()
        } catch (e: URISyntaxException) {
            Timber.e(e, "Initialize signaling client error")
        }
    }
    
    fun joinRoom(roomId: String) {
        this.roomId = roomId
        val data = JSONObject().apply {
            put("roomId", roomId)
            put("userId", userId)
            put("username", username)
        }
        socket?.emit("join_room", data)
    }
    
    fun leaveRoom() {
        socket?.emit("leave_room")
        roomId = null
    }
    
    fun sendIceCandidate(targetSocketId: String, iceCandidate: JSONObject) {
        val data = JSONObject().apply {
            put("targetSocketId", targetSocketId)
            put("candidate", iceCandidate)
        }
        socket?.emit("ice_candidate", data)
    }
    
    fun sendOffer(targetSocketId: String, sdp: JSONObject) {
        val data = JSONObject().apply {
            put("targetSocketId", targetSocketId)
            put("sdp", sdp)
        }
        socket?.emit("offer", data)
    }
    
    fun sendAnswer(targetSocketId: String, sdp: JSONObject) {
        val data = JSONObject().apply {
            put("targetSocketId", targetSocketId)
            put("sdp", sdp)
        }
        socket?.emit("answer", data)
    }
    
    fun toggleAudio(isAudioEnabled: Boolean) {
        val data = JSONObject().apply {
            put("isAudioEnabled", isAudioEnabled)
        }
        socket?.emit("toggle_audio", data)
    }
    
    fun toggleVideo(isVideoEnabled: Boolean) {
        val data = JSONObject().apply {
            put("isVideoEnabled", isVideoEnabled)
        }
        socket?.emit("toggle_video", data)
    }
    
    fun startScreenSharing() {
        socket?.emit("start_screen_sharing")
    }
    
    fun stopScreenSharing() {
        socket?.emit("stop_screen_sharing")
    }
    
    fun sendMessage(message: JSONObject) {
        val data = JSONObject().apply {
            put("roomId", roomId)
            put("message", message)
        }
        socket?.emit("send_message", data)
    }
    
    fun disconnect() {
        socket?.disconnect()
        socket?.off()
    }
    
    fun setListener(listener: SignalingClientListener) {
        this.listener = listener
    }
    
    // Socket.IO Event Listeners
    private val onConnect = Emitter.Listener {
        Timber.d("Socket connected")
        listener?.onSignalingConnected()
    }
    
    private val onDisconnect = Emitter.Listener {
        Timber.d("Socket disconnected")
        listener?.onSignalingDisconnected()
    }
    
    private val onConnectError = Emitter.Listener { args ->
        Timber.e("Socket connection error: ${args[0]}")
        listener?.onSignalingError("Connection error")
    }
    
    private val onRoomJoined = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val roomId = data.getString("roomId")
            val participants = data.getJSONArray("participants")
            
            Timber.d("Joined room: $roomId with ${participants.length()} other participants")
            
            val participantsList = mutableListOf<Participant>()
            for (i in 0 until participants.length()) {
                val participant = participants.getJSONObject(i)
                val participantUserId = participant.getString("userId")
                val participantUsername = participant.getString("username")
                val participantSocketId = participant.getString("socketId")
                
                // Don't add ourselves to the list
                if (participantUserId != userId) {
                    participantsList.add(Participant(
                        userId = participantUserId,
                        username = participantUsername,
                        socketId = participantSocketId
                    ))
                }
            }
            
            // We're the initiator if we're the first one in the room
            isInitiator = participants.length() == 1
            
            listener?.onJoinedRoom(roomId, isInitiator, participantsList)
        } catch (e: JSONException) {
            Timber.e(e, "Room joined parsing error")
            listener?.onSignalingError("Room joined parsing error")
        }
    }
    
    private val onUserJoined = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val userId = data.getString("userId")
            val username = data.getString("username")
            val socketId = data.getString("socketId")
            
            Timber.d("User joined: $username ($userId)")
            
            val participant = Participant(
                userId = userId,
                username = username,
                socketId = socketId
            )
            
            listener?.onUserJoined(participant)
        } catch (e: JSONException) {
            Timber.e(e, "User joined parsing error")
        }
    }
    
    private val onUserLeft = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val socketId = data.getString("socketId")
            val userId = data.getString("userId")
            
            Timber.d("User left: $userId")
            listener?.onUserLeft(socketId, userId)
        } catch (e: JSONException) {
            Timber.e(e, "User left parsing error")
        }
    }
    
    private val onIceCandidate = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val candidate = data.getJSONObject("candidate")
            val candidateSocketId = data.getString("candidateSocketId")
            
            Timber.d("Received ICE candidate from socket: $candidateSocketId")
            listener?.onRemoteIceCandidate(candidateSocketId, candidate)
        } catch (e: JSONException) {
            Timber.e(e, "Ice candidate parsing error")
        }
    }
    
    private val onOffer = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val sdp = data.getJSONObject("sdp")
            val offerSocketId = data.getString("offerSocketId")
            
            Timber.d("Received offer from socket: $offerSocketId")
            listener?.onRemoteOffer(offerSocketId, sdp)
        } catch (e: JSONException) {
            Timber.e(e, "Offer parsing error")
        }
    }
    
    private val onAnswer = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val sdp = data.getJSONObject("sdp")
            val answerSocketId = data.getString("answerSocketId")
            
            Timber.d("Received answer from socket: $answerSocketId")
            listener?.onRemoteAnswer(answerSocketId, sdp)
        } catch (e: JSONException) {
            Timber.e(e, "Answer parsing error")
        }
    }
    
    private val onError = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val message = data.getString("message")
            Timber.e("Signaling error: $message")
            listener?.onSignalingError(message)
        } catch (e: JSONException) {
            Timber.e(e, "Error parsing error")
            listener?.onSignalingError("Unknown error")
        }
    }
    
    private val onUserToggleAudio = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val socketId = data.getString("socketId")
            val userId = data.getString("userId")
            val isAudioEnabled = data.getBoolean("isAudioEnabled")
            
            Timber.d("User $userId toggled audio: $isAudioEnabled")
            listener?.onUserToggleAudio(socketId, userId, isAudioEnabled)
        } catch (e: JSONException) {
            Timber.e(e, "User toggle audio parsing error")
        }
    }
    
    private val onUserToggleVideo = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val socketId = data.getString("socketId")
            val userId = data.getString("userId")
            val isVideoEnabled = data.getBoolean("isVideoEnabled")
            
            Timber.d("User $userId toggled video: $isVideoEnabled")
            listener?.onUserToggleVideo(socketId, userId, isVideoEnabled)
        } catch (e: JSONException) {
            Timber.e(e, "User toggle video parsing error")
        }
    }
    
    private val onUserStartedSharing = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val socketId = data.getString("socketId")
            val userId = data.getString("userId")
            
            Timber.d("User $userId started screen sharing")
            listener?.onUserStartedSharing(socketId, userId)
        } catch (e: JSONException) {
            Timber.e(e, "User started sharing parsing error")
        }
    }
    
    private val onUserStoppedSharing = Emitter.Listener { args ->
        try {
            val data = args[0] as JSONObject
            val socketId = data.getString("socketId")
            val userId = data.getString("userId")
            
            Timber.d("User $userId stopped screen sharing")
            listener?.onUserStoppedSharing(socketId, userId)
        } catch (e: JSONException) {
            Timber.e(e, "User stopped sharing parsing error")
        }
    }
    
    private val onNewMessage = Emitter.Listener { args ->
        try {
            val messageData = args[0] as JSONObject
            listener?.onNewMessage(messageData)
        } catch (e: JSONException) {
            Timber.e(e, "New message parsing error")
        }
    }
    
    data class Participant(
        val userId: String,
        val username: String,
        val socketId: String
    )
    
    interface SignalingClientListener {
        fun onSignalingConnected()
        fun onSignalingDisconnected()
        fun onSignalingError(message: String)
        fun onJoinedRoom(roomId: String, isInitiator: Boolean, participants: List<Participant>)
        fun onUserJoined(participant: Participant)
        fun onUserLeft(socketId: String, userId: String)
        fun onRemoteIceCandidate(socketId: String, candidate: JSONObject)
        fun onRemoteOffer(socketId: String, sdp: JSONObject)
        fun onRemoteAnswer(socketId: String, sdp: JSONObject)
        fun onUserToggleAudio(socketId: String, userId: String, isAudioEnabled: Boolean)
        fun onUserToggleVideo(socketId: String, userId: String, isVideoEnabled: Boolean)
        fun onUserStartedSharing(socketId: String, userId: String)
        fun onUserStoppedSharing(socketId: String, userId: String)
        fun onNewMessage(messageData: JSONObject)
    }
} 