import 'package:flutter/material.dart';
import 'module/bottomNavigationBar.dart';

class SeniorHomeCompactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue[700]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Text('🧓 ooo어르신, \n안녕하세요!',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildTile(context, '추억공유', Icons.photo, '', blue),
                  _buildTile(context, '치매 예방 게임', Icons.extension, '/game', blue),
                  _buildStepTile(context, blue),
                  _buildTile(context, '지역 행사', Icons.event, '', blue),
                ],
              ),

              SizedBox(height: 36),

              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('긴급 호출이 전송되었습니다!')),
                  );
                },
                icon: Icon(Icons.warning),
                label: Text('긴급호출'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 52),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNav(color: blue), // 네비게이션 바 모듈
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, String routeName, Color color) {
    return GestureDetector(
      onTap: () {
        if (routeName.isNotEmpty) {
          Navigator.pushNamed(context, routeName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('아직 준비 중인 기능입니다.')),
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
              SizedBox(height: 10),
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

  Widget _buildStepTile(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/steps'),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오늘 걸음수', style: TextStyle(fontSize: 20, color: color)),
            SizedBox(height: 8),
            Icon(Icons.directions_walk, size: 40, color: Colors.green),
            Text('0000보 / 3000보', style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
