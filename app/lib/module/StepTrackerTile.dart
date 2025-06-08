import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class StepTrackerTile extends StatefulWidget {
  const StepTrackerTile({super.key});

  @override
  _StepTrackerTileState createState() => _StepTrackerTileState();
}

class _StepTrackerTileState extends State<StepTrackerTile> {
  late Stream<StepCount> _stepCountStream;
  int _stepsToday = 0;
  int _startOfDaySteps = 0;
  final int _targetSteps = 3000;
  DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    requestPermissionAndStart();
  }

  Future<void> requestPermissionAndStart() async {
    final status = await Permission.activityRecognition.request();
    if (status == PermissionStatus.granted) {
      debugPrint('권한 허용됨, pedometer 시작');
      initPedometer();
    } else {
      debugPrint('ACTIVITY_RECOGNITION 권한 거부됨');
    }
  }

  void initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(
      onStepCount,
      onError: onStepCountError,
      onDone: () {
        debugPrint('걸음수 스트림 종료됨');
      },
      cancelOnError: true,
    );

    debugPrint('걸음수 스트림 시작됨');
  }

  void onStepCount(StepCount event) {
    debugPrint('걸음 수 업데이트: ${event.steps}');
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    if (_startOfDaySteps == 0) {
      _startOfDaySteps = event.steps;
    }

    if (_today.isBefore(startOfToday)) {
      _today = startOfToday;
      _startOfDaySteps = event.steps;
      _stepsToday = 0;
    } else {
      setState(() {
        _stepsToday = event.steps - _startOfDaySteps;
        if (_stepsToday < 0) _stepsToday = 0;
      });
    }
  }

  void onStepCountError(error) {
    debugPrint('걸음 수 센서 에러: $error');
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_stepsToday / _targetSteps).clamp(0.0, 1.0);

    return SizedBox( // ✅ 전체 높이를 강제로 확보
      height: 230,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('오늘 걸음수', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const Icon(Icons.directions_walk, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text('$_stepsToday보 / $_targetSteps보',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
