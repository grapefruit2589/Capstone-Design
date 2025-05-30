import 'package:flutter/material.dart';
import 'module/bottomNavigationBar.dart';

class CaregiverHomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> seniors = [
    {
      'name': '🧓 김노인',
      'active': true,
      'steps': 1034,
    },
    {
      'name': '👵 박노인',
      'active': false,
      'steps': null,
    },
    {
      'name': '🧓 이노인',
      'active': false,
      'steps': null,
    },
    {
      'name': '👴 최노인',
      'active': true,
      'steps': 2090,
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
            // ✅ 상단 인사말 (요청한 그대로 유지)
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

                  // 포인트 박스
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 8),
                        Text('어르신 관리',
                            style: TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // ✅ 어르신 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: seniors.length,
                itemBuilder: (context, index) {
                  final senior = seniors[index];
                  return _buildSeniorCard(
                    context,
                    senior['name'],
                    senior['active'],
                    senior['steps'],
                    blue,
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        color: blue,
        homeRoute: '/home_caregiver', // 또는 '/home_senior'
      ),
    );
  }

  Widget _buildSeniorCard(BuildContext context, String name, bool active, int? steps, Color blue) {
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
                Navigator.pushNamed(context, '/senior_detail', arguments: name);
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
