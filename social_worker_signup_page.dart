import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SocialWorkerSignupPage extends StatefulWidget {
  @override
  _SocialWorkerSignupPageState createState() => _SocialWorkerSignupPageState();
}

class _SocialWorkerSignupPageState extends State<SocialWorkerSignupPage> {
  final _nameController = TextEditingController();
  final _genController = TextEditingController();
  final _pwController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> _signup() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/worker/signup'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'worker_name': _nameController.text,
        'worker_gen': _genController.text,
        'worker_pw': _pwController.text,
        'worker_tel': _telController.text,
        'worker_email': _emailController.text
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사회복지사 회원가입 성공!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 실패...')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사회복지사 회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: '이름')),
            TextField(controller: _genController, decoration: InputDecoration(labelText: '성별 (M/F)')),
            TextField(controller: _pwController, decoration: InputDecoration(labelText: '비밀번호')),
            TextField(controller: _telController, decoration: InputDecoration(labelText: '전화번호')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: '이메일')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: Text('회원가입')),
          ],
        ),
      ),
    );
  }
}
