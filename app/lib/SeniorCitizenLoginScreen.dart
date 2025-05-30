import 'package:flutter/material.dart';

class SeniorCitizenLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '요양 보호사와\n노인 사용자를 위한 플랫폼',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                Image.asset(
                  'assets/partnership.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                Text(
                  '로그인',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),

                // ✅ 카카오톡 로그인
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Text('🟡', style: TextStyle(fontSize: 20)),
                    label: Text('카카오톡 계정으로 로그인'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFEE500),
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // ✅ 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text('회원 가입'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // ✅ 아이디/비밀번호 찾기
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text('아이디 찾기'),
                    ),
                    Text('|', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {},
                      child: Text('비밀번호 찾기'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
