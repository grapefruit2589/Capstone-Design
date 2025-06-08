import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Config.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showDialog("비밀번호 불일치", "비밀번호와 비밀번호 확인이 일치하지 않습니다.");
      return;
    }

    //final url = Uri.parse('http://localhost:5000/member/signup');
    //ngrok가 만들어준 주소
    final Uri url = Uri.parse('$baseUrl/nurse/signup');

    final body = {
      "mem_name": nameController.text.trim(),
      "mem_email": emailController.text.trim(),
      "mem_tel": phoneController.text.trim(),
      "mem_pw": passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showDialog("회원가입 성공", "로그인 화면으로 이동합니다.", redirect: true);
      } else {
        _showDialog("회원가입 실패", res['error'] ?? "서버 오류 발생");
      }
    } catch (e) {
      _showDialog("에러", "서버에 연결할 수 없습니다.\n\n에러: $e");
    }
  }

  void _showDialog(String title, String content, {bool redirect = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (redirect) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
              }
            },
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '회원가입',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '노인 정보를 입력해주세요!',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                TextField(controller: nameController, decoration: _input("이름")),
                SizedBox(height: 16),
                TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: _input("이메일")),
                SizedBox(height: 16),
                TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: _input("전화번호")),
                SizedBox(height: 16),
                TextField(controller: passwordController, obscureText: true, decoration: _input("비밀번호")),
                SizedBox(height: 16),
                TextField(controller: confirmPasswordController, obscureText: true, decoration: _input("비밀번호 확인")),
                SizedBox(height: 32),

                ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('회원가입 완료'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
    );
  }
}
