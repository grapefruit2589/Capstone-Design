import 'package:flutter/material.dart';
import 'module/bottomNavigationBar.dart';

class CaregiverDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue[700]!;

    final Map<String, dynamic> data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    final String name = data['name'] ?? '🧓 어르신';
    final int steps = data['steps'] ?? 0;
    final int games = data['games'] ?? 0;
    final bool medChecked = data['medChecked'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView( // 스크롤
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    SizedBox(height: 60),

                    Center(child: Text(name.split(' ')[0], style: TextStyle(fontSize: 80))),
                    SizedBox(height: 16),

                    Text(
                      name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24),

                    _buildInfoRow('게임 참여 횟수', '$games회', blue),
                    _buildInfoRow('오늘 걸음수', '${steps}보', blue),
                    _buildInfoRow('약 체크', medChecked ? '✅' : '❌', blue, isBold: false),

                    SizedBox(height: 32),

                    // ✅ 확대된 지도 박스
                    Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '어르신 GPS 지도맵',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
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

  Widget _buildInfoRow(String title, String value, Color highlightColor, {bool isBold = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$title ',
              style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.w500 : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 16, color: highlightColor)),
        ],
      ),
    );
  }
}
