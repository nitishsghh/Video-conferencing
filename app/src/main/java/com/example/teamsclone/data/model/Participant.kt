package com.example.teamsclone.data.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity(tableName = "participants")
data class Participant(
    @PrimaryKey
    val id: String,
    val userId: String,
    val meetingId: String,
    val displayName: String,
    val photoUrl: String? = null,
    val role: ParticipantRole = ParticipantRole.ATTENDEE,
    val joinTime: Long = System.currentTimeMillis(),
    val leaveTime: Long? = null,
    val isAudioEnabled: Boolean = true,
    val isVideoEnabled: Boolean = true,
    val isSharingScreen: Boolean = false,
    val isHandRaised: Boolean = false,
    val connectionQuality: ConnectionQuality = ConnectionQuality.GOOD
) : Parcelable

enum class ParticipantRole {
    HOST,
    CO_HOST,
    PRESENTER,
    ATTENDEE
}

enum class ConnectionQuality {
    EXCELLENT,
    GOOD,
    FAIR,
    POOR,
    BAD
} 