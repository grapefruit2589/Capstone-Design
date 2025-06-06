import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import '../../module/bottomNavigationBar.dart';
import '../../module/StepTrackerTile.dart';

class SeniorHomeScreen extends StatefulWidget {
  final String seniorName;
  const SeniorHomeScreen({Key? key, required this.seniorName}) : super(key: key);

  @override
  _SeniorHomeScreenState createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;
  final int _targetSteps = 3000;

  @override
  void initState() {
    super.initState();
    initPedometer();
  }

  void initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
    });
  }

  void onStepCountError(error) {
    debugPrint('걸음 수 센서 에러: $error');
  }

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
                // 상단 인사말
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
                        _buildTile(context, '추억공유', Icons.photo, '/reminiscence', blue),
                        _buildTile(context, '치매 예방 게임', Icons.extension, '/game', blue),
                        const StepTrackerTile(), // 걸음수 모듈
                        _buildTile(context, '지역 행사', Icons.event, '/local_event', blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 긴급 호출 버튼
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
      ),
    );
  }

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


