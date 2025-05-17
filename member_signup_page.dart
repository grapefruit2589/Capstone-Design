import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemberSignupPage extends StatefulWidget {
  @override
  _MemberSignupPageState createState() => _MemberSignupPageState();
}

class _MemberSignupPageState extends State<MemberSignupPage> {
  final _nameController = TextEditingController();
  final _genController = TextEditingController();
  final _pwController = TextEditingController();
  final _telController = TextEditingController();

  Future<void> _signup() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/member/signup'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'mem_name': _nameController.text,
        'mem_gen': _genController.text,
        'mem_pw': _pwController.text,
        'mem_tel': _telController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 성공!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 실패...')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('노인 회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: '이름')),
            TextField(controller: _genController, decoration: InputDecoration(labelText: '성별 (M/F)')),
            TextField(controller: _pwController, decoration: InputDecoration(labelText: '비밀번호')),
            TextField(controller: _telController, decoration: InputDecoration(labelText: '전화번호(-포함)')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: Text('회원가입')),
          ],
        ),
      ),
    );
  }
}
