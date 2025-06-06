import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SeniorCitizenLoginScreen extends StatefulWidget {
  @override
  _SeniorCitizenLoginScreenState createState() =>
      _SeniorCitizenLoginScreenState();
}

class _SeniorCitizenLoginScreenState extends State<SeniorCitizenLoginScreen> {
  // 지금은 역할 선택 토글은 UI만 남겨두고, 실제 로그인 요청엔 쓰지 않습니다.
  String selectedRole = 'senior';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    // 🔸 백엔드에는 /login 하나만 구현되어 있으므로, 여기서 통합 호출
    // final Uri url = Uri.parse('http://localhost:5000/login');
    //ngrok가 만들어준 주소로 연결(사유:안드로이드 실행 오류로 인해서)
    final url = Uri.parse('https://9af5-2001-2d8-631a-346e-9d3a-fb16-40f7-f598.ngrok-free.app/login');
    // 🔸 백엔드가 기대하는 키 이름: "email" / "password"
    final Map<String, String> body = {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'role': (selectedRole == 'caregiver') ? 'nurse' : 'member',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // HTTP 레벨에서 200이 넘어오면, JSON 안에 success가 true인지 확인
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          // 백엔드가 돌려준 역할(role)과 이름(name)을 꺼내고
          final String role = (data['role'] as String?) ?? '';
          final String name = (data['name'] as String?) ?? '';

          // role 값이 "nurse"라면 CaregiverHomeScreen으로,
          // "member"라면 SeniorHomeScreen으로 네비게이트
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
            // 혹시 role이 의도치 않게 다르면 에러 팝업
            _showErrorDialog('오류', '알 수 없는 사용자 역할입니다.');
          }
        } else {
          // success=false라면, 백엔드가 보낸 error 메시지 표시
          final String backendError = (data['error'] as String?) ?? '로그인에 실패했습니다.';
          _showErrorDialog('로그인 실패', backendError);
        }
      } else {
        // 200이 아닌 코드가 왔으면, 서버 상태 이상 또는 잘못된 요청
        _showErrorDialog('로그인 실패', '서버 응답 상태: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 에러나 예외가 발생했을 때
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

                // ─── 역할 선택: 노인 / 요양보호사 버튼 (UI만 남겨둠)
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
                                const Text('🧓',
                                    style: TextStyle(fontSize: 18)),
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
                                const Text('👩‍⚕️',
                                    style: TextStyle(fontSize: 18)),
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
                      borderSide:
                      BorderSide(color: primaryBlue, width: 2),
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
                      borderSide:
                      BorderSide(color: primaryBlue, width: 2),
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
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
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
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
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
