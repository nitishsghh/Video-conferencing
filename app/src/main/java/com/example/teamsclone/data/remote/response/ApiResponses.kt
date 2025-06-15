package com.example.teamsclone.data.remote.response

import com.example.teamsclone.data.model.User

data class BaseResponse(
    val success: Boolean,
    val message: String? = null,
    val errorCode: Int? = null
)

data class AuthResponse(
    val success: Boolean,
    val message: String? = null,
    val token: String? = null,
    val refreshToken: String? = null,
    val user: User? = null,
    val expiresIn: Long? = null,
    val errorCode: Int? = null
)

data class IceServer(
    val urls: List<String>,
    val username: String? = null,
    val credential: String? = null
)

data class IceServersResponse(
    val iceServers: List<IceServer>,
    val ttlSeconds: Int
) 