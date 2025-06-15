import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'services/auth_service.dart';
import 'services/webrtc_service_mock.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/meeting_screen.dart';
import 'screens/active_meeting_screen.dart';
import 'screens/active_video_call_screen.dart';
import 'screens/splash_screen.dart';
import 'models/meeting_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => WebRTCService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conferencing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Using light theme for both for now
      themeMode: ThemeMode.light,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/meeting': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final meeting = args?['meeting'] as MeetingModel?;
          final meetingId =
              args?['meetingId'] as String? ?? 'default-meeting-id';

          if (meeting != null) {
            return ActiveMeetingScreen(meeting: meeting);
          }
          return MeetingScreen(meetingId: meetingId);
        },
        '/active-video-call': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return ActiveVideoCallScreen(arguments: args);
        },
      },
    );
  }
}
