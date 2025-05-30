import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'mainLoginScreen.dart' as mainLogin;
import 'SeniorCitizenLoginScreen.dart' as seniorLogin;
import 'RegisterScreen.dart';

void main() => runApp(SilverOnApp());

class SilverOnApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '실버ON',
      debugShowCheckedModeBanner: false,
      // home: SplashScreen(), // 첫 시작 화면
      home: seniorLogin.SeniorCitizenLoginScreen(), //임시 개발환경
      routes: {
        '/login': (context) => mainLogin.LoginScreen(),
        '/login_senior': (context) => seniorLogin.SeniorCitizenLoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
