import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'mainLoginScreen.dart' as mainLogin;
import 'SeniorCitizenLoginScreen.dart' as seniorLogin;
import 'RegisterScreen.dart';
import 'SeniorHomeScreen.dart';
import 'CaregiverHomeScreen.dart';
import 'CaregiverDetailScreen.dart';
import 'SeniorGameScreen.dart';
import 'CardCoupleGame.dart';
import 'SeniorLocalEventScreen.dart';
import 'SeniorReminiscenceScreen.dart' as reminiscence;
import 'SeniorReminiscenceFeedbackScreen.dart' as feedback;

void main() => runApp(SilverOnApp());

class SilverOnApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '실버ON',
      debugShowCheckedModeBanner: false,
      home: SeniorHomeCompactScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/reminiscence_feedback') {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (_) => feedback.FeedbackPage(
              imageFile: args['imageFile'],
              mood: args['mood'],
            ),
          );
        }
        return null;
      },
      routes: {
        '/login': (context) => mainLogin.LoginScreen(),
        '/login_both': (context) => seniorLogin.SeniorCitizenLoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home_senior': (context) => SeniorHomeCompactScreen(),
        '/home_caregiver': (context) => CaregiverHomeScreen(),
        '/caregiver_detail': (context) => CaregiverDetailScreen(),
        '/game': (context) => SeniorGameScreen(),
        '/game_matching': (context) => CardCoupleGame(),
        '/local_event': (context) => SeniorLocalEventScreen(),
        '/reminiscence': (context) => reminiscence.UploadPage(),
      },
    );
  }
}
