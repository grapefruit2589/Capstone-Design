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

void main() => runApp(SilverOnApp());

class SilverOnApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '실버ON',
      debugShowCheckedModeBanner: false,
      //home: SplashScreen(), // 첫 시작 화면
      //home: CaregiverHomeScreen(),  //임시 개발환경
      home: SeniorGameScreen(),  //임시 개발환경
      routes: {
        '/login': (context) => mainLogin.LoginScreen(),
        '/login_both': (context) => seniorLogin.SeniorCitizenLoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home_senior': (context) => SeniorHomeCompactScreen(),
        '/home_caregiver': (context) => CaregiverHomeScreen(),
        '/caregiver_detail': (context) => CaregiverDetailScreen(),
        '/game': (context) => SeniorGameScreen(),
        '/game_matching': (context) => CardCoupleGame(),
      },
    );
  }
}
