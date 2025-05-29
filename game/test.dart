import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: CoupleGame(),
    debugShowCheckedModeBanner: false,
  ));
}

class CoupleGame extends StatefulWidget {
  @override
  _CoupleGameState createState() => _CoupleGameState();
}

class _CoupleGameState extends State<CoupleGame> {
  final int nW = 4;
  final int nH = 4;
  List<String> imageList = [];
  List<List<int>> board = [];
  List<List<int>> status = [];

  int tx = -1, ty = -1;
  int count = 0;
  bool isProcessing = false;

  // 제한시간 관련
  Timer? gameTimer;
  int timeLimit = 60;

  // 카운트다운 관련
  int countdownValue = 3;
  bool isCountdown = true;

  // 일시정지 상태
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    countdownValue = 3;
    isCountdown = true;

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countdownValue--;
      });

      if (countdownValue == 0) {
        timer.cancel();
        isCountdown = false;
        initGame();
      }
    });
  }

  void initGame() {
    imageList = [
      'assets/shape0.png',
      'assets/shape1.png',
      'assets/shape2.png',
      'assets/shape3.png',
      'assets/shape4.png',
      'assets/shape5.png',
      'assets/shape6.png',
      'assets/shape7.png',
      'assets/shape8.png',
    ];

    board = List.generate(nH, (_) => List.filled(nW, 0));
    status = List.generate(nH, (_) => List.filled(nW, 0));
    randomImagePair();

    gameTimer?.cancel();
    timeLimit = 60;
    startTimer();

    count = 0;
    tx = ty = -1;
    isProcessing = false;

    setState(() {});
  }

  void randomImagePair() {
    List<int> pairs = [];
    for (int i = 1; i < imageList.length; i++) {
      pairs.add(i);
      pairs.add(i);
    }
    pairs.shuffle();

    int idx = 0;
    for (int y = 0; y < nH; y++) {
      for (int x = 0; x < nW; x++) {
        board[y][x] = pairs[idx++];
      }
    }
  }

  void onCellTap(int x, int y) {
    if (isProcessing || isCountdown || isPaused) return;
    if (status[y][x] != 0) return;

    setState(() {
      status[y][x] = 1;
    });

    if (tx == -1) {
      tx = x;
      ty = y;
    } else {
      count++;
      if (board[ty][tx] == board[y][x]) {
        setState(() {
          status[ty][tx] = 2;
          status[y][x] = 2;
          tx = ty = -1;
        });
        if (checkWin()) {
          gameTimer?.cancel();
          Future.delayed(Duration(milliseconds: 500), () {
            showResultDialog('축하합니다!', '모든 그림을 맞췄어요!\n시도횟수: $count번');
          });
        }
      } else {
        isProcessing = true;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            status[ty][tx] = 0;
            status[y][x] = 0;
            tx = ty = -1;
            isProcessing = false;
          });
        });
      }
    }
  }

  bool checkWin() {
    for (var row in status) {
      if (row.contains(0) || row.contains(1)) return false;
    }
    return true;
  }

  void showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startCountdown();
            },
            child: Text('다시 시작'),
          ),
        ],
      ),
    );
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          timeLimit--;
        });

        if (timeLimit <= 0) {
          timer.cancel();
          showResultDialog('시간 초과', '제한시간이 끝났습니다.\n시도횟수: $count번');
        }
      }
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void endGameEarly() {
    gameTimer?.cancel();
    showResultDialog('게임 종료', '게임을 조기 종료했습니다.\n시도횟수: $count번');
  }

  @override
  Widget build(BuildContext context) {
    double cellSize = MediaQuery.of(context).size.width / nW;

    return Scaffold(
      appBar: AppBar(
        title: Text('🧩 그림 짝 찾기'),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: isCountdown ? null : togglePause,
            tooltip: isPaused ? '재시작' : '일시정지',
          ),
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: isCountdown ? null : endGameEarly,
            tooltip: '조기 종료',
          ),
        ],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: (isCountdown || isPaused) ? 0.3 : 1.0,
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: nW * nH,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: nW,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                int x = index % nW;
                int y = index ~/ nW;

                String imgPath;
                if (status[y][x] == 0) {
                  imgPath = imageList[0];
                } else {
                  imgPath = imageList[board[y][x]];
                }

                return GestureDetector(
                  onTap: () => onCellTap(x, y),
                  child: Container(
                    color: Colors.grey[300],
                    child: Image.asset(imgPath, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          if (isCountdown)
            Center(
              child: Text(
                '$countdownValue',
                style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          if (isPaused)
            Center(
              child: Text(
                '⏸️ 일시정지 중',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              '시도: $count회',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Text(
              '남은 시간: $timeLimit초',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
