package com.example.teamsclone.ui.components

import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.navigation.NavController
import com.example.teamsclone.R
import com.example.teamsclone.ui.Screen

@Composable
fun BottomNavigationBar(navController: NavController, currentRoute: String?) {
    NavigationBar {
        val items = listOf(
            NavigationItem(
                title = stringResource(R.string.home),
                icon = R.drawable.ic_home,
                route = Screen.Home.route
            ),
            NavigationItem(
                title = stringResource(R.string.meetings),
                icon = R.drawable.ic_meetings,
                route = Screen.Meetings.route
            ),
            NavigationItem(
                title = stringResource(R.string.chat_nav),
                icon = R.drawable.ic_chat,
                route = Screen.Chat.route
            ),
            NavigationItem(
                title = stringResource(R.string.profile),
                icon = R.drawable.ic_profile,
                route = Screen.Profile.route
            )
        )
        
        items.forEach { item ->
            NavigationBarItem(
                icon = { Icon(painter = painterResource(id = item.icon), contentDescription = item.title) },
                label = { Text(text = item.title) },
                selected = currentRoute == item.route,
                onClick = {
                    if (currentRoute != item.route) {
                        navController.navigate(item.route) {
                            // Pop up to the start destination of the graph to avoid building up a large stack
                            popUpTo(Screen.Home.route) {
                                saveState = true
                            }
                            // Avoid multiple copies of the same destination
                            launchSingleTop = true
                            // Restore state when reselecting a previously selected item
                            restoreState = true
                        }
                    }
                }
            )
        }
    }
}

data class NavigationItem(
    val title: String,
    val icon: Int,
    val route: String
) 