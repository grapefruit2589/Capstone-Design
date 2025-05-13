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

    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLimit--;
      });

      if (timeLimit <= 0) {
        timer.cancel();
        _showTimeoutDialog();
      }
    });

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
    if (isProcessing || isCountdown) return;
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
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('축하합니다!'),
                content: Text('모든 그림을 맞췄어요!\n시도횟수: $count번'),
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

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('시간 초과'),
        content: Text('제한시간이 끝났습니다.\n시도횟수: $count번'),
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

  @override
  Widget build(BuildContext context) {
    double cellSize = MediaQuery.of(context).size.width / nW;

    return Scaffold(
      appBar: AppBar(
        title: Text('그림 짝 찾기 - 시도: $count | 남은시간: $timeLimit초'),
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: isCountdown ? 0.3 : 1.0,
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

          // 카운트다운 표시
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
        ],
      ),
    );
  }
}
