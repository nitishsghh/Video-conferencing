package com.example.teamsclone.data.local

import androidx.room.TypeConverter
import com.example.teamsclone.data.model.ConnectionQuality
import com.example.teamsclone.data.model.MessageType
import com.example.teamsclone.data.model.MeetingStatus
import com.example.teamsclone.data.model.ParticipantRole
import com.example.teamsclone.data.model.RecurringFrequency
import com.example.teamsclone.data.model.RecurringPattern
import com.example.teamsclone.data.model.UserStatus
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

/**
 * Type converters for Room database
 */
class Converters {
    private val gson = Gson()
    
    // List<String> converters
    @TypeConverter
    fun fromStringList(value: List<String>?): String {
        return gson.toJson(value ?: emptyList<String>())
    }
    
    @TypeConverter
    fun toStringList(value: String): List<String> {
        val listType = object : TypeToken<List<String>>() {}.type
        return gson.fromJson(value, listType) ?: emptyList()
    }
    
    // Map<String, String> converters
    @TypeConverter
    fun fromStringMap(value: Map<String, String>?): String {
        return gson.toJson(value ?: emptyMap<String, String>())
    }
    
    @TypeConverter
    fun toStringMap(value: String): Map<String, String> {
        val mapType = object : TypeToken<Map<String, String>>() {}.type
        return gson.fromJson(value, mapType) ?: emptyMap()
    }
    
    // RecurringPattern converters
    @TypeConverter
    fun fromRecurringPattern(value: RecurringPattern?): String {
        return gson.toJson(value)
    }
    
    @TypeConverter
    fun toRecurringPattern(value: String): RecurringPattern? {
        return try {
            gson.fromJson(value, RecurringPattern::class.java)
        } catch (e: Exception) {
            null
        }
    }
    
    // Enum converters
    @TypeConverter
    fun fromUserStatus(value: UserStatus): String {
        return value.name
    }
    
    @TypeConverter
    fun toUserStatus(value: String): UserStatus {
        return try {
            UserStatus.valueOf(value)
        } catch (e: Exception) {
            UserStatus.AVAILABLE
        }
    }
    
    @TypeConverter
    fun fromMeetingStatus(value: MeetingStatus): String {
        return value.name
    }
    
    @TypeConverter
    fun toMeetingStatus(value: String): MeetingStatus {
        return try {
            MeetingStatus.valueOf(value)
        } catch (e: Exception) {
            MeetingStatus.SCHEDULED
        }
    }
    
    @TypeConverter
    fun fromRecurringFrequency(value: RecurringFrequency?): String? {
        return value?.name
    }
    
    @TypeConverter
    fun toRecurringFrequency(value: String?): RecurringFrequency? {
        return if (value == null) null else try {
            RecurringFrequency.valueOf(value)
        } catch (e: Exception) {
            null
        }
    }
    
    @TypeConverter
    fun fromMessageType(value: MessageType): String {
        return value.name
    }
    
    @TypeConverter
    fun toMessageType(value: String): MessageType {
        return try {
            MessageType.valueOf(value)
        } catch (e: Exception) {
            MessageType.TEXT
        }
    }
    
    @TypeConverter
    fun fromParticipantRole(value: ParticipantRole): String {
        return value.name
    }
    
    @TypeConverter
    fun toParticipantRole(value: String): ParticipantRole {
        return try {
            ParticipantRole.valueOf(value)
        } catch (e: Exception) {
            ParticipantRole.ATTENDEE
        }
    }
    
    @TypeConverter
    fun fromConnectionQuality(value: ConnectionQuality): String {
        return value.name
    }
    
    @TypeConverter
    fun toConnectionQuality(value: String): ConnectionQuality {
        return try {
            ConnectionQuality.valueOf(value)
        } catch (e: Exception) {
            ConnectionQuality.GOOD
        }
    }
} 