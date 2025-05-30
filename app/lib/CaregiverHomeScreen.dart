import 'package:flutter/material.dart';
import 'module/bottomNavigationBar.dart';

class CaregiverHomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> seniors = [
    {
      'name': '🧓 김노인',
      'active': true,
      'steps': 1034,
      'games': 3,
      'medChecked': true,
    },
    {
      'name': '👵 박노인',
      'active': false,
      'steps': null,
      'games': 1,
      'medChecked': false,
    },
    {
      'name': '🧓 이노인',
      'active': false,
      'steps': null,
      'games': 0,
      'medChecked': false,
    },
    {
      'name': '👴 최노인',
      'active': true,
      'steps': 2090,
      'games': 5,
      'medChecked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue[700]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 인사말
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👩 ooo 요양보호사님,\n안녕하세요!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  // 어르신 관리 박스
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('어르신 관리',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // 어르신 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: seniors.length,
                itemBuilder: (context, index) {
                  final senior = seniors[index];
                  return _buildSeniorCard(context, senior, blue);
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        color: blue,
        homeRoute: '/home_caregiver',
      ),
    );
  }

  Widget _buildSeniorCard(BuildContext context, Map<String, dynamic> senior, Color blue) {
    final name = senior['name'];
    final active = senior['active'];
    final steps = senior['steps'];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            active ? '오늘 활동 ✅' : '오늘 활동 ❌',
            style: TextStyle(fontSize: 16),
          ),
          if (steps != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '오늘 걸음수 $steps보',
                style: TextStyle(fontSize: 16, color: blue),
              ),
            ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/caregiver_detail',
                  arguments: senior, // ✅ 전체 데이터 전달
                );
              },
              child: Text('상세보기'),
              style: TextButton.styleFrom(foregroundColor: blue),
            ),
          )
        ],
      ),
    );
  }
}
