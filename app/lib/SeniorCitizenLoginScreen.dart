// lib/module/SeniorCitizenLoginScreen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SeniorCitizenLoginScreen extends StatefulWidget {
  @override
  _SeniorCitizenLoginScreenState createState() =>
      _SeniorCitizenLoginScreenState();
}

class _SeniorCitizenLoginScreenState extends State<SeniorCitizenLoginScreen> {
  // 역할 선택 토글: 'senior' (노인) 또는 'caregiver' (요양보호사)
  String selectedRole = 'senior';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    // 백엔드에 요청할 URL (개발용: localhost)
    final Uri url = Uri.parse('http://localhost:5000/login');

    // selectedRole 값에 맞춰서 백엔드에 보낼 role 문자열을 매핑
    // 'senior' → 'member', 'caregiver' → 'nurse'
    String roleToSend;
    if (selectedRole == 'senior') {
      roleToSend = 'member';
    } else {
      roleToSend = 'nurse';
    }

    final Map<String, String> body = {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'role': roleToSend,   // 추가된 부분: 백엔드가 기대하는 역할(role)
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          final String role = (data['role'] as String?) ?? '';
          final String name = (data['name'] as String?) ?? '';

          // 백엔드가 준 role에 따라 네비게이트
          if (role == 'nurse') {
            Navigator.pushReplacementNamed(
              context,
              '/home_caregiver',
              arguments: name,
            );
          } else if (role == 'member') {
            Navigator.pushReplacementNamed(
              context,
              '/home_senior',
              arguments: name,
            );
          } else {
            _showErrorDialog('오류', '알 수 없는 사용자 역할입니다.');
          }
        } else {
          final String backendError = (data['error'] as String?) ?? '로그인에 실패했습니다.';
          _showErrorDialog('로그인 실패', backendError);
        }
      } else {
        _showErrorDialog('로그인 실패', '서버 응답 상태: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('서버 오류', '서버에 연결할 수 없습니다.\n${e.toString()}');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ─── 상단 타이틀 + 로고
                const SizedBox(height: 40),
                const Text(
                  '요양 보호사와\n노인 사용자를 위한 플랫폼',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/partnership.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),

                // ─── 로그인 제목
                const Text(
                  '로그인',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // ─── 역할 선택: 노인 / 요양보호사 버튼
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // 노인 버튼
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedRole = 'senior';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: (selectedRole == 'senior')
                                  ? primaryBlue
                                  : Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                bottomLeft: Radius.circular(6),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🧓', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  '노인',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: (selectedRole == 'senior')
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 요양보호사 버튼
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedRole = 'caregiver';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: (selectedRole == 'caregiver')
                                  ? primaryBlue
                                  : Colors.white,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('👩‍⚕️', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  '요양보호사',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: (selectedRole == 'caregiver')
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── 이메일 입력 필드
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 비밀번호 입력 필드
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ─── 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('로그인'),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (selectedRole == 'senior') {
                        Navigator.pushNamed(context, '/register');
                      } else {
                        Navigator.pushNamed(context, '/register_nurse');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,
                      side: BorderSide(color: primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('회원 가입'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
