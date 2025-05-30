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
                SizedBox(height: 28),
                Text(
                  '로그인',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                SizedBox(height: 6),

                // 아이디 (이메일) 입력
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '아이디 (이메일)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 비밀번호 입력
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),


                // ✅ 카카오톡 로그인
                // 구현이 힘들 시에 삭제할 예정
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: GestureDetector(
                    onTap: () {
                      // TODO: 카카오 로그인 기능
                    },
                    child: Image.asset(
                      'assets/kakao_login_medium_narrow.png',
                      width: MediaQuery.of(context).size.width * 1.0, //
                      height: 65,
                      fit: BoxFit.fitHeight, //
                    ),
                  ),
                ),


                SizedBox(height: 14),

                // ✅ 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register'); // ✅ 회원가입 화면으로 이동
                    },
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
