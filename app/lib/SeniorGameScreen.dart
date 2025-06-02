import 'package:flutter/material.dart';
import 'module/bottomNavigationBar.dart';
import 'module/interactiveGameCard.dart';

class SeniorGameScreen extends StatelessWidget {
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
                // 상단 타이틀 + 설명
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text('치매 예방 게임',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('게임을 선택하세요',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[700])),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                // 게임 목록
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 3 / 4,
                      children: [
                        // 카드 매칭 게임
                        InteractiveGameCard(
                          title: '카드 매칭 게임',
                          subtitle: '(1단계)',
                          icon: Icons.style,
                          enabled: true,
                          route: '/game_matching', //TODO: 실제 구현된 카드게임 경로로
                          borderColor: Colors.grey,
                          iconColor: Colors.blue,
                          textColor: Colors.blue,
                        ),

                        // 나머지 미정 게임 3개
                        for (int i = 0; i < 3; i++)
                          _buildGameCard(
                            context,
                            title: '미정',
                            subtitle: '',
                            icon: Icons.block,
                            enabled: false,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 뒤로가기 버튼
            Positioned(
              top: 12,
              left: 12,
              child: CircleAvatar(
                backgroundColor: blue.withOpacity(0.1),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: blue),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: CustomBottomNav(
        color: blue,
        homeRoute: '/home_senior',
      ),
    );
  }

  // 공통 게임 카드 위젯
  Widget _buildGameCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    String? route,
    required Color color,
    Color? iconColor,
    Color? textColor,
  }) {
    final iconCol = iconColor ?? color;
    final textCol = textColor ?? color;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          if (enabled && route != null) {
            Navigator.pushNamed(context, route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('아직 구현되지 않은 게임입니다.')),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: iconCol),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                    fontSize: 18, color: textCol, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ]
            ],
          ),
        ),
      ),
    );
  }
}