package com.example.teamsclone.data.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity(tableName = "users")
data class User(
    @PrimaryKey
    val id: String,
    val email: String,
    val displayName: String,
    val photoUrl: String? = null,
    val jobTitle: String? = null,
    val phoneNumber: String? = null,
    val status: UserStatus = UserStatus.AVAILABLE,
    val isOnline: Boolean = false,
    val lastSeen: Long = 0
) : Parcelable

enum class UserStatus {
    AVAILABLE,
    BUSY,
    DO_NOT_DISTURB,
    AWAY,
    OFFLINE
} 