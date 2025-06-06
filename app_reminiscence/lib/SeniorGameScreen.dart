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
                // 타이틀 & 설명
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

                // 게임 목록 (스크롤 가능)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      itemCount: 4,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 3 / 4,
                      ),
                      itemBuilder: (context, index) {
                        final games = [
                          {
                            'title': '카드 매칭 게임',
                            'subtitle': '',
                            'icon': Icons.style,
                            'route': '/game_matching',
                          },
                          {
                            'title': '속담 퀴즈',
                            'subtitle': '',
                            'icon': Icons.chat,
                            'route': '/game_proverb',
                          },
                          {
                            'title': '가수 맞추기',
                            'subtitle': '',
                            'icon': Icons.mic_external_on,
                            'route': '/game_singer',
                          },
                          {
                            'title': '가사 맞추기',
                            'subtitle': '',
                            'icon': Icons.music_note,
                            'route': '/game_lyrics',
                          },
                        ];

                        final game = games[index];

                        return InteractiveGameCard(
                          title: game['title'] as String,
                          subtitle: game['subtitle'] as String,
                          icon: game['icon'] as IconData,
                          enabled: true,
                          route: game['route'] as String,
                          borderColor: Colors.grey,
                          iconColor: Colors.blue,
                          textColor: Colors.blue,
                        );
                      },
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
}
