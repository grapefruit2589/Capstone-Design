import 'package:flutter/material.dart';

// ─── 시작 및 주요 화면 import
import 'SplashScreen.dart';
import 'mainLoginScreen.dart' as mainLogin;
import 'SeniorCitizenLoginScreen.dart' as seniorLogin;
import 'RegisterScreen.dart';
import 'CaregiverRegisterScreen.dart';
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

      /// 앱 시작 시 보여줄 화면
      home: SplashScreen(),

      /// 파라미터 전달이 필요한 화면들
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home_senior':
            final String seniorName = settings.arguments as String? ?? '어르신';
            return MaterialPageRoute(
              builder: (_) => SeniorHomeScreen(seniorName: seniorName),
            );

          case '/home_caregiver':
            final String caregiverName = settings.arguments as String? ?? '요양보호사';
            return MaterialPageRoute(
              builder: (_) => CaregiverHomeScreen(caregiverName: caregiverName),
            );

          case '/caregiver_detail':
            return MaterialPageRoute(
              builder: (_) => CaregiverDetailScreen(),
            );

          case '/reminiscence_feedback':
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

      /// 고정 라우트 (파라미터 없이 이동)
      routes: {
        '/login': (context) => mainLogin.LoginScreen(),
        '/login_both': (context) => seniorLogin.SeniorCitizenLoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/register_caregiver': (context) => CaregiverRegisterScreen(),
        '/game': (context) => SeniorGameScreen(),
        '/game_matching': (context) => CardCoupleGame(),
        '/local_event': (context) => SeniorLocalEventScreen(),
        '/reminiscence': (context) => reminiscence.UploadPage(),
        '/register_nurse': (context) => CaregiverRegisterScreen(),
      },
    );
  }
}
