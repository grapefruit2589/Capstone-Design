// lib/CaregiverHomeScreen.dart
 
import 'package:flutter/material.dart';

/// 바텀 네비게이션 바: 홈 탭을 누르면 지정된 라우트로 이동하며
/// userName(요양보호사 이름)을 arguments로 전달한다.
class CustomBottomNav extends StatelessWidget {
  final Color color;       // 아이콘/텍스트 색상
  final String homeRoute;  // 홈 화면 라우트 이름
  final String? userName;  // 홈으로 이동할 때 넘길 사용자 이름

  const CustomBottomNav({
    Key? key,
    required this.color,
    required this.homeRoute,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: color,
      unselectedItemColor: color.withOpacity(0.5),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_run),
          label: '활동',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline),
          label: '도움말',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(
              context,
              homeRoute,
              arguments: userName,
            );
            break;
          case 1:
            Navigator.pushNamed(context, '/activities');
            break;
          case 2:
            Navigator.pushNamed(context, '/help');
            break;
        }
      },
    );
  }
}

/// CaregiverHomeScreen:
/// 로그인한 요양보호사 이름을 받아 상단에 표시하고,
/// 어르신 목록을 리스트로 보여준다.
class CaregiverHomeScreen extends StatelessWidget {
  final String caregiverName; // 로그인한 요양보호사 이름

  const CaregiverHomeScreen({
    Key? key,
    required this.caregiverName,
  }) : super(key: key);

  // 샘플 어르신 데이터 (나중에 백엔드 연동)
  final List<Map<String, dynamic>> seniors = const [
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
            // 상단 인삿말 + "어르신 관리" 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👩 $caregiverName 요양보호사님,\n안녕하세요!',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '어르신 관리',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
            ),
          ],
        ),
      ),

      // 바텀 네비게이션 바
      bottomNavigationBar: CustomBottomNav(
        color: blue,
        homeRoute: '/home_caregiver',
        userName: caregiverName,
      ),
    );
  }

  // 어르신 한 명을 표시하는 카드 위젯
  Widget _buildSeniorCard(
      BuildContext context, Map<String, dynamic> senior, Color blue) {
    final name = senior['name'] as String;
    final active = senior['active'] as bool;
    final steps = senior['steps'] as int?;

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
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
                Navigator.pushNamed(
                  context,
                  '/caregiver_detail',
                  arguments: senior,
                );
              },
              child: const Text('상세보기'),
              style: TextButton.styleFrom(foregroundColor: blue),
            ),
          ),
        ],
      ),
    );
  }
}
