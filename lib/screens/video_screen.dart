import 'package:flutter/material.dart';
// ignore: deprecated_member_use
import 'package:flutter_riverpod/all.dart';
import 'package:miniplayer/miniplayer.dart';
import '../models/data.dart';
import '../widgets/video_card.dart';
import '../widgets/video_info.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'nav_screen.dart';

List<Video> generateSuggestedVideos(
    List<Video> allVideos, int numberOfSuggestions) {
  int maxSuggestions = numberOfSuggestions > allVideos.length
      ? allVideos.length
      : numberOfSuggestions;
  allVideos.shuffle();
  return allVideos.sublist(0, maxSuggestions);
}

class VideoScreen extends StatefulWidget {
  final List<Video> videos;
  const VideoScreen({super.key, required this.videos});

  @override
  // ignore: library_private_types_in_public_api
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  ScrollController? _scrollController;
  late VideoPlayerController _videoPlayerController;
  ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration.zero);
  late bool _isPlaying = false;
  late bool _isFullScreen = false;

  void _togglePlayPause() {
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
      }
      _isPlaying = _videoPlayerController.value.isPlaying;
    });
  }

  void _seekVideo(Duration position) {
    _videoPlayerController.seekTo(position);
  }

  void _toggleFullScreen() {
    _isFullScreen = !_isFullScreen;

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    if (_isFullScreen) {
      _videoPlayerController.pause();
    }

    if (!_isFullScreen) {
      _videoPlayerController.play();
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final selectedVideo = context.read(selectedVideoProvider).state;
    // Initialize the VideoPlayerController with the video URL
    _videoPlayerController =
        // ignore: deprecated_member_use
        VideoPlayerController.network(selectedVideo!.videoUrl)
          ..initialize().then((_) {
            setState(() {});
          });
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isInitialized) {
        _currentPosition.value = _videoPlayerController.value.position;
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _videoPlayerController.dispose(); //
    _currentPosition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Video> suggestedVideos = generateSuggestedVideos(widget.videos, 3);
    return GestureDetector(
      onTap: () => context
          .read(miniPlayerControllerProvider)
          .state
          .animateToHeight(state: PanelState.MAX),
      child: Scaffold(
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: CustomScrollView(
            controller: _scrollController,
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, watch, _) {
                    final selectedVideo = watch(selectedVideoProvider).state;

                    if (selectedVideo == null) {
                      return const CircularProgressIndicator();
                    }
                    return SafeArea(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              //video player
                              AspectRatio(
                                aspectRatio: 9 / 16,
                                child: Stack(
                                  children: [
                                    VideoPlayer(_videoPlayerController),
                                    if (!_isPlaying)
                                      Center(
                                        child: IconButton(
                                          icon: const Icon(Icons.play_arrow),
                                          onPressed: _togglePlayPause,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                iconSize: 30.0,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                onPressed: () => context
                                    .read(miniPlayerControllerProvider)
                                    .state
                                    .animateToHeight(state: PanelState.MIN),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(_isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow),
                                onPressed: _togglePlayPause,
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: () => _seekVideo(
                                    _videoPlayerController.value.position -
                                        const Duration(seconds: 10)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                onPressed: () => _seekVideo(
                                    _videoPlayerController.value.position +
                                        const Duration(seconds: 10)),
                              ),
                              IconButton(
                                icon: Icon(_isFullScreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen),
                                onPressed: _toggleFullScreen,
                              ),
                            ],
                          ),
                          ValueListenableBuilder<Duration>(
                            valueListenable: _currentPosition,
                            builder: (context, currentPosition, _) {
                              double progress = 0.0;
                              if (_videoPlayerController
                                      .value.duration.inMilliseconds !=
                                  0) {
                                progress = currentPosition.inMilliseconds /
                                    _videoPlayerController
                                        .value.duration.inMilliseconds;
                              }
                              return LinearProgressIndicator(
                                value: progress,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              );
                            },
                          ),
                          VideoInfo(video: selectedVideo),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = suggestedVideos[index];
                    return VideoCard(
                      video: video,
                      hasPadding: true,
                      onTap: () => _scrollController!.animateTo(
                        0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn,
                      ),
                    );
                  },
                  childCount: suggestedVideos.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
