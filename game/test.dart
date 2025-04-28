
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

  int tx = -1, ty = -1; // TEMP 셀 좌표
  int count = 0; // 시도 횟수
  bool isProcessing = false; // 클릭 잠금

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    imageList = [
      'assets/shape0.png',  // 기본 숨겨진 이미지
      'assets/shape1.png',
      'assets/shape2.png',
      'assets/shape3.png',
      'assets/shape4.png',
      'assets/shape5.png',
      'assets/shape6.png',
      'assets/shape7.png',
      'assets/shape8.png',
    ];
    // 4x4 보드 초기화
    board = List.generate(nH, (_) => List.filled(nW, 0));
    status = List.generate(nH, (_) => List.filled(nW, 0));

    randomImagePair();
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
    if (isProcessing) return;
    if (status[y][x] != 0) return; // 이미 뒤집혔거나 보여지는 셀 클릭 무시

    setState(() {
      status[y][x] = 1; // TEMP 상태로 변경
    });

    if (tx == -1) {
      tx = x;
      ty = y;
    } else {
      count++;
      if (board[ty][tx] == board[y][x]) {
        // 맞췄을 때
        setState(() {
          status[ty][tx] = 2; // FLIP
          status[y][x] = 2;
          tx = ty = -1;
        });
        if (checkWin()) {
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
                            initGame();
                          },
                          child: Text('다시 시작'),
                        )
                      ],
                    ));
          });
        }
      } else {
        // 틀렸을 때
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

  @override
  Widget build(BuildContext context) {
    double cellSize = MediaQuery.of(context).size.width / nW;

    return Scaffold(
      appBar: AppBar(
        title: Text('그림 짝 찾기 게임 - 시도: $count'),
      ),
      body: GridView.builder(
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
            imgPath = imageList[0]; // 뒷면
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
    );
  }
}
