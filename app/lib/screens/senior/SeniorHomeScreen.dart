import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Config.dart';

import '../../module/bottomNavigationBar.dart';
import '../../module/StepTrackerTile.dart';

class SeniorHomeScreen extends StatefulWidget {
  final String seniorName; // Flutter에서 로그인 시 전달받는 노인 이름
  const SeniorHomeScreen({Key? key, required this.seniorName}) : super(key: key);

  @override
  _SeniorHomeScreenState createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  // 걸음 수 관련 상태
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;
  final int _targetSteps = 3000;

  // 긴급 호출 상태 관리
  bool _isEmergency = false;
  String _emergencyText = "";

  // 백엔드 주소 (ngrok 주소 또는 서버 주소 입력)
  final String _baseUrl = "$baseUrl";

  @override
  void initState() {
    super.initState();
    initPedometer();
  }

  // pedometer 초기화 및 스트림 연결
  void initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  // 걸음 수 이벤트 처리
  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
    });
  }

  // pedometer 에러 처리
  void onStepCountError(error) {
    debugPrint('걸음 수 센서 에러: $error');
  }

  // 긴급 호출 버튼 토글 (true일 경우 API 호출)
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
      final uri = Uri.parse("$baseUrl/emergency");
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mem_name": widget.seniorName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("nurse_name")) {
          final fetchedNurseName = data["nurse_name"] as String;
          setState(() {
            _emergencyText = "🚑 $fetchedNurseName 요양보호사님께서 출발하셨습니다.";
            _isEmergency = true;
          });
        } else if (data.containsKey("message")) {
          final serverMsg = data["message"] as String;
          setState(() {
            _emergencyText = serverMsg;
            _isEmergency = true;
          });
        } else {
          setState(() {
            _emergencyText = "알 수 없는 응답이 왔습니다.";
            _isEmergency = true;
          });
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorJson = jsonDecode(response.body);
        final message = errorJson["error"] ?? "알 수 없는 오류입니다.";
        _showSnackBar("긴급 호출 실패: $message");
      } else {
        _showSnackBar("서버 오류: 긴급 호출에 실패했습니다.");
      }
    } catch (e) {
      _showSnackBar("네트워크 오류: 긴급 호출에 실패했습니다.");
    }
  }

  // 스낵바 표시용 함수
  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue[700]!;

    // 긴급 호출 모드 화면
    if (_isEmergency) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("긴급 호출"),
          backgroundColor: blue,
        ),
        body: Center(
          child: Text(
            _emergencyText.isNotEmpty ? _emergencyText : "요양보호사 정보를 가져오는 중입니다...",
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

    // 기본 홈 화면
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 인사말 영역
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🧓 ${widget.seniorName} 어르신,\n안녕하세요!',
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                // 기능 타일 영역
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.95,
                      children: [
                        _buildTile(context, '추억공유', Icons.photo, '/reminiscence', blue),
                        _buildTile(context, '치매 예방 게임', Icons.extension, '/game', blue),
                        const StepTrackerTile(),
                        _buildTile(context, '지역 행사', Icons.event, '/local_event', blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 긴급 호출 버튼 하단 고정
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

  // 공통 기능 타일 생성 위젯
  Widget _buildTile(BuildContext context, String title, IconData icon, String routeName, Color color) {
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
}
