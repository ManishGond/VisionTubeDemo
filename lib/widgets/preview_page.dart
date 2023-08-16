import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.videoFile}) : super(key: key);

  final XFile videoFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Preview'),
      ),
      body: Center(
        child: VideoPlayer(VideoPlayerController.file(File(videoFile.path))),
      ),
    );
  }
}
