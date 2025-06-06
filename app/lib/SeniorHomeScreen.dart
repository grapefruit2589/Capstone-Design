import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'module/bottomNavigationBar.dart';

class SeniorHomeScreen extends StatefulWidget {
  final String seniorName; // Flutter에서 로그인 시 전달받는 노인 이름

  const SeniorHomeScreen({
    Key? key,
    required this.seniorName,
  }) : super(key: key);

  @override
  _SeniorHomeScreenState createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  // 긴급 호출 상태 관리
  bool _isEmergency = false;
  String _emergencyText = ""; // 간호사 이름 또는 112 호출 메시지

  // 백엔드 주소 (필요에 따라 IP/도메인/port 수정)
  final String _baseUrl = "http://127.0.0.1:5000";

  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue[700]!;

    // ────────────────────────────────────────────────────────────────────────────
    // 1) 긴급 호출 모드일 때: 노인 이름을 기반으로 백엔드에서 내려준 메시지 표시
    if (_isEmergency) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("긴급 호출"),
          backgroundColor: blue,
        ),
        body: Center(
          child: Text(
            _emergencyText.isNotEmpty
                ? _emergencyText
                : "요양보호사 정보를 가져오는 중입니다...",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ElevatedButton.icon(
            onPressed: _toggleEmergency,
            icon: const Icon(Icons.arrow_back),
            label: const Text('홈으로 돌아가기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              textStyle: const TextStyle(fontSize: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      );
    }

    // ────────────────────────────────────────────────────────────────────────────
    // 2) 일반 홈 화면: 인사말 + 기능 버튼 + 긴급 호출 버튼
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 상단 인사말
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🧓 ${widget.seniorName} 어르신,\n안녕하세요!',
                        style:
                        const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // 기능 버튼 그리드
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
                        _buildTile(context, '치매 예방 게임', Icons.extension, '/game', blue),
                        _buildStepTile(context, blue),
                        _buildTile(context, '지역 행사', Icons.event, '/local_event', blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 긴급 호출 버튼 (화면 맨 아래 고정)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: _toggleEmergency,
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
      ),
    );
  }

  // 긴급 호출 버튼 누르면 화면 토글: false→true 이면 API 호출, true→false 이면 홈으로 돌아가기
  void _toggleEmergency() {
    if (!_isEmergency) {
      _callEmergencyApi();
    } else {
      setState(() {
        _isEmergency = false;
        _emergencyText = "";
      });
    }
  }

  // 백엔드 /emergency API 호출
  Future<void> _callEmergencyApi() async {
    try {
      final uri = Uri.parse("$_baseUrl/emergency");
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mem_name": widget.seniorName, // 노인 이름을 서버로 전달
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 1) nurse_name 키가 있으면: 간호사 출발 메시지
        if (data.containsKey("nurse_name")) {
          final fetchedNurseName = data["nurse_name"] as String;
          setState(() {
            _emergencyText =
            "🚑 $fetchedNurseName 요양보호사님께서 출발하셨습니다.";
            _isEmergency = true;
          });
        }
        // 2) message 키가 있으면: 112 호출 메시지
        else if (data.containsKey("message")) {
          final serverMsg = data["message"] as String;
          setState(() {
            _emergencyText = serverMsg; // “요양보호사가 없어서 112로 출동…”
            _isEmergency = true;
          });
        }
        // 3) 그 외 예외
        else {
          setState(() {
            _emergencyText = "알 수 없는 응답이 왔습니다.";
            _isEmergency = true;
          });
        }
      }
      // 400~499 오류: 입력값 누락, 노인 존재하지 않음 등
      else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorJson = jsonDecode(response.body);
        final message = errorJson["error"] ?? "알 수 없는 에러입니다.";
        _showSnackBar("긴급 호출 실패: $message");
      }
      // 서버 오류
      else {
        _showSnackBar("서버 오류: 긴급 호출에 실패했습니다.");
      }
    } catch (e) {
      _showSnackBar("네트워크 에러: 긴급 호출에 실패했습니다.");
    }
  }

  // 스낵바 띄우는 편의 함수
  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // 기존 기능 버튼 위젯들
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
