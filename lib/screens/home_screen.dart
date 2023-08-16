import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../models/data.dart';
import '../widgets/custom_sliver_appbar.dart';
import '../widgets/video_card.dart';
import '../widgets/video_service.dart';

class HomeScreen extends StatefulWidget {
  final firebase.User? currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VideoService _videoService = VideoService();

  List<Video> _videos = [];

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    List<Video> videos = await _videoService.getVideos();
    setState(() {
      _videos = videos.reversed.toList();
    });
  }

  Future<void> _refreshVideos() async {
    await _fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshVideos,
        child: CustomScrollView(
          slivers: [
            CustomSliverAppBar(currentUser: widget.currentUser),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 60.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = _videos[index];
                    return VideoCard(video: video);
                  },
                  childCount: _videos.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
