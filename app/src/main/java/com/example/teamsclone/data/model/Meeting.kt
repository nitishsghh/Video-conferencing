package com.example.teamsclone.data.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverters
import com.example.teamsclone.data.local.Converters
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity(tableName = "meetings")
@TypeConverters(Converters::class)
data class Meeting(
    @PrimaryKey
    val id: String,
    val title: String,
    val description: String? = null,
    val hostId: String,
    val password: String? = null,
    val startTime: Long,
    val endTime: Long,
    val participantIds: List<String> = emptyList(),
    val isRecurring: Boolean = false,
    val recurringPattern: RecurringPattern? = null,
    val status: MeetingStatus = MeetingStatus.SCHEDULED,
    val isRecordingEnabled: Boolean = false,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
) : Parcelable

@Parcelize
data class RecurringPattern(
    val frequency: RecurringFrequency,
    val interval: Int = 1, // Every 1 day, every 2 weeks, etc.
    val daysOfWeek: List<Int>? = null, // For weekly patterns
    val dayOfMonth: Int? = null, // For monthly patterns
    val endDate: Long? = null, // When the recurring pattern ends
    val count: Int? = null // Number of occurrences
) : Parcelable

enum class RecurringFrequency {
    DAILY,
    WEEKLY,
    MONTHLY,
    YEARLY
}

enum class MeetingStatus {
    SCHEDULED,
    LIVE,
    COMPLETED,
    CANCELLED
} 