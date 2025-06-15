package com.example.teamsclone.di

import android.content.Context
import com.example.teamsclone.data.local.AppDatabase
import com.example.teamsclone.data.local.dao.MeetingDao
import com.example.teamsclone.data.local.dao.MessageDao
import com.example.teamsclone.data.local.dao.ParticipantDao
import com.example.teamsclone.data.local.dao.UserDao
import com.example.teamsclone.data.remote.ApiClient
import com.example.teamsclone.data.remote.ApiService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    
    @Singleton
    @Provides
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase {
        return AppDatabase.getInstance(context)
    }
    
    @Singleton
    @Provides
    fun provideUserDao(appDatabase: AppDatabase): UserDao {
        return appDatabase.userDao()
    }
    
    @Singleton
    @Provides
    fun provideMeetingDao(appDatabase: AppDatabase): MeetingDao {
        return appDatabase.meetingDao()
    }
    
    @Singleton
    @Provides
    fun provideMessageDao(appDatabase: AppDatabase): MessageDao {
        return appDatabase.messageDao()
    }
    
    @Singleton
    @Provides
    fun provideParticipantDao(appDatabase: AppDatabase): ParticipantDao {
        return appDatabase.participantDao()
    }
    
    @Singleton
    @Provides
    fun provideApiService(apiClient: ApiClient): ApiService {
        return apiClient.apiService
    }
} 