// lib/SeniorHomeScreen.dart

import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final Color color;
  final String homeRoute;
  final String? seniorName;

  const CustomBottomNav({
    Key? key,
    required this.color,
    required this.homeRoute,
    this.seniorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: color,
      unselectedItemColor: color.withOpacity(0.5),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: color),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_run, color: color),
          label: '활동',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline, color: color),
          label: '도움말',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(
              context,
              homeRoute,
              arguments: seniorName,
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

class SeniorHomeScreen extends StatelessWidget {
  final String seniorName;
  const SeniorHomeScreen({Key? key, required this.seniorName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue[700]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🧓 $seniorName 어르신,\n안녕하세요!',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1,
                      children: [
                        _buildTile(context, '추억공유', Icons.photo, '', blue),
                        _buildTile(
                            context, '치매 예방 게임', Icons.extension, '/game', blue),
                        _buildStepTile(context, blue),
                        _buildTile(
                            context, '지역 행사', Icons.event, '/local_event', blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('긴급 호출이 전송되었습니다!')),
                  );
                },
                icon: const Icon(Icons.warning),
                label: const Text('긴급호출'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        color: blue,
        homeRoute: '/home_senior',
        seniorName: seniorName,
      ),
    );
  }

  static Widget _buildTile(
      BuildContext context, String title, IconData icon, String routeName, Color color) {
    return GestureDetector(
      onTap: () {
        if (routeName.isNotEmpty) {
          Navigator.pushNamed(context, routeName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('아직 준비 중인 기능입니다.')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 24, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStepTile(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/steps'),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('오늘 걸음수', style: TextStyle(fontSize: 20, color: Colors.black)),
            SizedBox(height: 8),
            Icon(Icons.directions_walk, size: 40, color: Colors.green),
            Text('0000보 / 3000보', style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
