import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'mainLoginScreen.dart';

void main() => runApp(SilverOnApp());

class SilverOnApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '실버ON',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // 첫 시작 화면
      routes: {
        '/login': (context) => LoginScreen(), // 로그인 화면 연결
      },
    );
  }
}
