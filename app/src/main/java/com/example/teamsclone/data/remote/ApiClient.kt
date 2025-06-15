package com.example.teamsclone.data.remote

import com.example.teamsclone.utils.Constants
import com.example.teamsclone.utils.SessionManager
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ApiClient @Inject constructor(private val sessionManager: SessionManager) {
    
    private val authInterceptor = Interceptor { chain ->
        val originalRequest = chain.request()
        val token = sessionManager.getAuthToken()
        
        val requestBuilder = originalRequest.newBuilder()
            .header("Content-Type", "application/json")
        
        if (!token.isNullOrEmpty()) {
            requestBuilder.header("Authorization", "Bearer $token")
        }
        
        val request = requestBuilder.build()
        chain.proceed(request)
    }
    
    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }
    
    private val client = OkHttpClient.Builder()
        .addInterceptor(authInterceptor)
        .addInterceptor(loggingInterceptor)
        .connectTimeout(Constants.CONNECTION_TIMEOUT_SECONDS.toLong(), TimeUnit.SECONDS)
        .readTimeout(Constants.CONNECTION_TIMEOUT_SECONDS.toLong(), TimeUnit.SECONDS)
        .writeTimeout(Constants.CONNECTION_TIMEOUT_SECONDS.toLong(), TimeUnit.SECONDS)
        .build()
    
    private val retrofit = Retrofit.Builder()
        .baseUrl(Constants.BASE_URL)
        .client(client)
        .addConverterFactory(GsonConverterFactory.create())
        .build()
    
    val apiService: ApiService = retrofit.create(ApiService::class.java)
} 