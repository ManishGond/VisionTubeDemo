import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/data.dart';

class VideoService {
  final CollectionReference _videosCollection =
      FirebaseFirestore.instance.collection('videos');

  Future<List<Video>> getVideos() async {
    try {
      QuerySnapshot querySnapshot = await _videosCollection.get();
      List<Video> videos = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Video.fromFirestore(data);
      }).toList();

      return videos;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }
}

class VideoServiceScreen extends StatefulWidget {
  const VideoServiceScreen({super.key});

  @override
  State<VideoServiceScreen> createState() => _VideoServiceScreenState();
}

class _VideoServiceScreenState extends State<VideoServiceScreen> {
  final VideoService _videoService = VideoService();
  List<Video> _videos = [];

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  void _fetchVideos() async {
    List<Video> videos = await _videoService.getVideos();
    setState(() {
      _videos = videos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Service Screen'),
      ),
      body: ListView.builder(
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return ListTile(
            title: Text(video.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Video URL: ${video.videoUrl}'),
                Text('Thumbnail URL: ${video.thumbnailUrl}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
