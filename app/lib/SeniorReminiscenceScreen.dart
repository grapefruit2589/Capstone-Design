import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'SeniorReminiscenceFeedbackScreen.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackPage(
          imageFile: File(imageFile.path),
          mood: 'calm',
        ),
      ),
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
            bottom: 10,
            right: 2,
            child: Material(
              type: MaterialType.transparency,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                shape: CircleBorder(),
                elevation: 3,
                mini: true,
                child: Icon(Icons.library_add_rounded, size: 35, color: Colors.blue),
                onPressed: _loadRecentImages,
              ),
            ),
          )
        ],
      ),
    );
  }
}
