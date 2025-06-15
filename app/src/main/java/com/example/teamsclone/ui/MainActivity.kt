package com.example.teamsclone.ui

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.example.teamsclone.ui.components.BottomNavigationBar
import com.example.teamsclone.ui.screens.auth.LoginScreen
import com.example.teamsclone.ui.screens.auth.RegisterScreen
import com.example.teamsclone.ui.screens.chat.ChatScreen
import com.example.teamsclone.ui.screens.home.HomeScreen
import com.example.teamsclone.ui.screens.meeting.CreateMeetingScreen
import com.example.teamsclone.ui.screens.meeting.JoinMeetingScreen
import com.example.teamsclone.ui.screens.meeting.MeetingScreen
import com.example.teamsclone.ui.screens.meetings.MeetingsScreen
import com.example.teamsclone.ui.screens.profile.ProfileScreen
import com.example.teamsclone.ui.theme.TeamsCloneTheme
import com.example.teamsclone.utils.Constants
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        
        setContent {
            TeamsCloneTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainScreen(handleIntent(intent))
                }
            }
        }
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Handle the new intent, e.g., for meeting deep links
    }
    
    private fun handleIntent(intent: Intent?): String? {
        // Handle deep links for meeting invites
        if (intent?.action == Intent.ACTION_VIEW) {
            val uri = intent.data
            if (uri?.scheme == "teamsclone" && uri.host == "meeting") {
                val meetingId = uri.getQueryParameter("id")
                if (!meetingId.isNullOrEmpty()) {
                    return meetingId
                }
            }
        }
        return null
    }
}

@Composable
fun MainScreen(deepLinkMeetingId: String? = null) {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route
    
    // Check if the current screen should show the bottom navigation
    val showBottomNav = when (currentRoute) {
        Screen.Home.route, Screen.Meetings.route, Screen.Chat.route, Screen.Profile.route -> true
        else -> false
    }
    
    Scaffold(
        bottomBar = {
            if (showBottomNav) {
                BottomNavigationBar(navController = navController, currentRoute = currentRoute)
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Login.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            // Auth screens
            composable(Screen.Login.route) {
                LoginScreen(navController = navController)
            }
            composable(Screen.Register.route) {
                RegisterScreen(navController = navController)
            }
            
            // Main navigation screens
            composable(Screen.Home.route) {
                HomeScreen(navController = navController)
            }
            composable(Screen.Meetings.route) {
                MeetingsScreen(navController = navController)
            }
            composable(Screen.Chat.route) {
                ChatScreen(navController = navController)
            }
            composable(Screen.Profile.route) {
                ProfileScreen(navController = navController)
            }
            
            // Meeting screens
            composable(Screen.CreateMeeting.route) {
                CreateMeetingScreen(navController = navController)
            }
            composable(Screen.JoinMeeting.route) {
                JoinMeetingScreen(navController = navController)
            }
            composable("${Screen.Meeting.route}/{meetingId}") { backStackEntry ->
                val meetingId = backStackEntry.arguments?.getString("meetingId")
                MeetingScreen(navController = navController, meetingId = meetingId)
            }
            
            // Handle deep link if present
            deepLinkMeetingId?.let {
                navController.navigate("${Screen.Meeting.route}/$it") {
                    popUpTo(Screen.Login.route) { inclusive = true }
                }
            }
        }
    }
}

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object Register : Screen("register")
    object Home : Screen("home")
    object Meetings : Screen("meetings")
    object Chat : Screen("chat")
    object Profile : Screen("profile")
    object CreateMeeting : Screen("create_meeting")
    object JoinMeeting : Screen("join_meeting")
    object Meeting : Screen("meeting")
} 