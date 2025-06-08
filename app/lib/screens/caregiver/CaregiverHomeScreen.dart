import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Config.dart'; // baseUrl 포함
import '../../module/bottomNavigationBar.dart';

class CaregiverHomeScreen extends StatefulWidget {
  final String caregiverName;
  const CaregiverHomeScreen({Key? key, required this.caregiverName}) : super(key: key);

  @override
  _CaregiverHomeScreenState createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  final List<Map<String, dynamic>> seniors = [
    {'name': '🧓 김노인', 'active': true, 'steps': 1034, 'games': 3, 'medChecked': true},
    {'name': '👵 박노인', 'active': false, 'steps': null, 'games': 1, 'medChecked': false},
    {'name': '🧓 이노인', 'active': false, 'steps': null, 'games': 0, 'medChecked': false},
    {'name': '👴 최노인', 'active': true, 'steps': 2090, 'games': 5, 'medChecked': true},
  ];

  Timer? emergencyCheckTimer;

  @override
  void initState() {
    super.initState();
    emergencyCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) => checkEmergency());
  }

  @override
  void dispose() {
    emergencyCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> checkEmergency() async {
    final url = Uri.parse('$baseUrl/emergency_queue');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final memName = data['mem_name'];
        _showEmergencyDialog('$memName 어르신의 긴급 호출이 발생했습니다!');
      }
    } catch (e) {
      print('긴급 호출 확인 실패: $e');
    }
  }

  void _showEmergencyDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🚨 긴급 호출'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue[700]!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👩 ${widget.caregiverName} 요양보호사님,\n안녕하세요!',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text('어르신 관리', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: seniors.length,
                itemBuilder: (context, index) {
                  final senior = seniors[index];
                  return _buildSeniorCard(context, senior, blue);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(color: blue, homeRoute: '/home_caregiver'),
    );
  }

  Widget _buildSeniorCard(BuildContext context, Map<String, dynamic> senior, Color blue) {
    final name = senior['name'];
    final active = senior['active'];
    final steps = senior['steps'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            active ? '오늘 활동 ✅' : '오늘 활동 ❌',
            style: const TextStyle(fontSize: 16),
          ),
          if (steps != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '오늘 걸음수 $steps보',
                style: TextStyle(fontSize: 16, color: blue),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/caregiver_detail', arguments: senior);
              },
              style: TextButton.styleFrom(foregroundColor: blue),
              child: const Text('상세보기'),
            ),
          ),
        ],
      ),
    );
  }
}
