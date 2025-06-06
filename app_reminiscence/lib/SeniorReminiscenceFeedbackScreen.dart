import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';


class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> recentImages = [];
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
  }

  Future<void> _loadRecentImages() async {
    try {
      final images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() => recentImages.addAll(images));
      }
    } catch (e) {
      print("이미지 불러오기 실패: $e");
    }
  }

  void _openFeedback(XFile imageFile) {
    Navigator.pushNamed(
      context,
      '/reminiscence_feedback',
      arguments: {
        'imageFile': File(imageFile.path),
        'mood': 'calm',
      },
    );
  }

  Widget _buildImageTile(int index, XFile image) {
    final isSelected = selectedIndex == index;
    final duration = const Duration(milliseconds: 300);
    final double width = isSelected ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.42;
    final double height = isSelected ? MediaQuery.of(context).size.height * 0.4 : MediaQuery.of(context).size.width * 0.42;

    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index == selectedIndex ? null : index);
      },
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeInOut,
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _openFeedback(image),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.music_note, color: Colors.white, size: 30),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('최근 사진', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: recentImages.isEmpty
                ? Center(
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('최근 사진이 없습니다.', style: TextStyle(color: Colors.black54)),
                ),
              ),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(recentImages.length, (index) {
                  return _buildImageTile(index, recentImages[index]);
                }),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              type: MaterialType.transparency,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                shape: CircleBorder(),
                elevation: 3,
                mini: true,
                child: Icon(Icons.library_add_rounded, size: 24, color: Colors.blue),
                onPressed: _loadRecentImages,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  final File imageFile;
  final String mood;

  FeedbackPage({required this.imageFile, required this.mood});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  bool isLooping = false;

  final Map<String, String> moodMelodies = {
    'calm': 'calm.mp3',
    'happy': 'happy.mp3',
    'sad': 'sad.mp3',
  };

  final Map<String, Color> moodColors = {
    'calm': Colors.lightBlueAccent,
    'happy': Colors.yellow,
    'sad': Colors.grey,
  };

  String get melodyPath => 'music/${moodMelodies[widget.mood] ?? 'calm.mp3'}';
  Color get backgroundColor => moodColors[widget.mood] ?? Colors.white;

  void _togglePlayback() async {
    print("▶ 버튼 클릭됨, 현재 isPlaying: $isPlaying");

    if (isPlaying) {
      await player.stop();
      print("⏹ 정지됨");
    } else {
      try {
        await player.setReleaseMode(
          isLooping ? ReleaseMode.loop : ReleaseMode.release,
        );
        await player.play(AssetSource(melodyPath), volume: 1.0);
        print("🎵 재생 시작: $melodyPath");
      } catch (e) {
        print("❌ 재생 실패: $e");
      }
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _downloadMusic() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('다운로드 기능은 추후 지원됩니다')),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('추천 결과')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(widget.imageFile, height: 200),
            ),
            const SizedBox(height: 20),
            Text(
              '분위기 분석 결과: ${widget.mood.toUpperCase()}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? '멜로디 정지' : '추천 멜로디 재생'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _togglePlayback,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('반복 재생'),
              value: isLooping,
              onChanged: (value) {
                setState(() {
                  isLooping = value;
                  player.setReleaseMode(
                    isLooping ? ReleaseMode.loop : ReleaseMode.release,
                  );
                });
              },
              secondary: const Icon(Icons.repeat),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('멜로디 다운로드'),
              onPressed: _downloadMusic,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: const BorderSide(color: Colors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
