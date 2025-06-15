package com.example.teamsclone.data.remote.request

data class RegisterRequest(
    val email: String,
    val password: String,
    val displayName: String,
    val photoUrl: String? = null,
    val jobTitle: String? = null,
    val phoneNumber: String? = null
)

data class LoginRequest(
    val email: String,
    val password: String
)

data class UpdateUserRequest(
    val displayName: String? = null,
    val jobTitle: String? = null,
    val phoneNumber: String? = null,
    val status: String? = null
) 