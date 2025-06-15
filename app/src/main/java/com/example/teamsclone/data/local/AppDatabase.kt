package com.example.teamsclone.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.example.teamsclone.data.local.dao.MeetingDao
import com.example.teamsclone.data.local.dao.MessageDao
import com.example.teamsclone.data.local.dao.ParticipantDao
import com.example.teamsclone.data.local.dao.UserDao
import com.example.teamsclone.data.model.Meeting
import com.example.teamsclone.data.model.Message
import com.example.teamsclone.data.model.Participant
import com.example.teamsclone.data.model.User

@Database(
    entities = [User::class, Meeting::class, Message::class, Participant::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    
    abstract fun userDao(): UserDao
    abstract fun meetingDao(): MeetingDao
    abstract fun messageDao(): MessageDao
    abstract fun participantDao(): ParticipantDao
    
    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "teams_clone_database"
                )
                .fallbackToDestructiveMigration()
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
} 