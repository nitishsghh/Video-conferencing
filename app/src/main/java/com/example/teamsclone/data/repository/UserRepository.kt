package com.example.teamsclone.data.repository

import com.example.teamsclone.data.local.dao.UserDao
import com.example.teamsclone.data.model.User
import com.example.teamsclone.data.model.UserStatus
import com.example.teamsclone.data.remote.ApiService
import com.example.teamsclone.data.remote.request.LoginRequest
import com.example.teamsclone.data.remote.request.RegisterRequest
import com.example.teamsclone.data.remote.request.UpdateUserRequest
import com.example.teamsclone.data.remote.response.AuthResponse
import com.example.teamsclone.utils.NetworkResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class UserRepository @Inject constructor(
    private val userDao: UserDao,
    private val apiService: ApiService
) {
    
    // Local database operations
    suspend fun insertUser(user: User) = userDao.insert(user)
    
    suspend fun updateUser(user: User) = userDao.update(user)
    
    suspend fun getUserById(userId: String): User? = userDao.getUserById(userId)
    
    fun observeUserById(userId: String): Flow<User?> = userDao.observeUserById(userId)
    
    fun getAllUsers(): Flow<List<User>> = userDao.getAllUsers()
    
    fun searchUsers(query: String): Flow<List<User>> = userDao.searchUsers(query)
    
    // Remote API operations
    suspend fun register(email: String, password: String, displayName: String): NetworkResult<AuthResponse> {
        return withContext(Dispatchers.IO) {
            try {
                val request = RegisterRequest(
                    email = email,
                    password = password,
                    displayName = displayName
                )
                val response = apiService.register(request)
                
                // Cache user data if registration is successful
                response.user?.let { insertUser(it) }
                
                NetworkResult.Success(response)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Registration failed")
            }
        }
    }
    
    suspend fun login(email: String, password: String): NetworkResult<AuthResponse> {
        return withContext(Dispatchers.IO) {
            try {
                val request = LoginRequest(
                    email = email,
                    password = password
                )
                val response = apiService.login(request)
                
                // Cache user data if login is successful
                response.user?.let { insertUser(it) }
                
                NetworkResult.Success(response)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Login failed")
            }
        }
    }
    
    suspend fun logout(): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                apiService.logout()
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Logout failed")
            }
        }
    }
    
    suspend fun fetchUserById(userId: String): NetworkResult<User> {
        return withContext(Dispatchers.IO) {
            try {
                val user = apiService.getUserById(userId)
                
                // Update local cache
                insertUser(user)
                
                NetworkResult.Success(user)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to fetch user")
            }
        }
    }
    
    suspend fun updateUserProfile(
        userId: String,
        displayName: String? = null,
        jobTitle: String? = null,
        phoneNumber: String? = null,
        status: UserStatus? = null
    ): NetworkResult<User> {
        return withContext(Dispatchers.IO) {
            try {
                val request = UpdateUserRequest(
                    displayName = displayName,
                    jobTitle = jobTitle,
                    phoneNumber = phoneNumber,
                    status = status?.name
                )
                
                val updatedUser = apiService.updateUser(userId, request)
                
                // Update local cache
                insertUser(updatedUser)
                
                NetworkResult.Success(updatedUser)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update user profile")
            }
        }
    }
    
    suspend fun uploadUserPhoto(userId: String, photoFile: File): NetworkResult<User> {
        return withContext(Dispatchers.IO) {
            try {
                val requestFile = photoFile.asRequestBody("image/*".toMediaTypeOrNull())
                val photoPart = MultipartBody.Part.createFormData(
                    "photo",
                    photoFile.name,
                    requestFile
                )
                
                val updatedUser = apiService.uploadUserPhoto(userId, photoPart)
                
                // Update local cache
                insertUser(updatedUser)
                
                NetworkResult.Success(updatedUser)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to upload photo")
            }
        }
    }
    
    suspend fun updateUserStatus(userId: String, status: UserStatus): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                userDao.updateUserStatus(userId, status)
                
                // Also update on the server
                updateUserProfile(userId, status = status)
                
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update status")
            }
        }
    }
    
    suspend fun updateUserOnlineStatus(userId: String, isOnline: Boolean): NetworkResult<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                userDao.updateUserOnlineStatus(userId, isOnline)
                NetworkResult.Success(true)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Failed to update online status")
            }
        }
    }
} 