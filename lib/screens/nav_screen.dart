import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:visiontube/models/data.dart';
import 'package:visiontube/screens/video_screen.dart';
import 'package:visiontube/widgets/video_service.dart';

import 'add_page.dart';
import 'home_screen.dart';

final selectedVideoProvider = StateProvider<Video?>((ref) => null);

final miniPlayerControllerProvider =
    StateProvider.autoDispose<MiniplayerController>(
  (ref) => MiniplayerController(),
);

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NavScreenState createState() => _NavScreenState();
}

void _signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    // Handle sign-out errors if any
    if (kDebugMode) {
      print('Error signing out: $e');
    }
  }
}

class _NavScreenState extends State<NavScreen> {
  static const double _playerMinHeight = 60.0;

  int selectedIndex = 0;
  final firebase_auth.User? currentUser =
      firebase_auth.FirebaseAuth.instance.currentUser;

  void _onBottomNavigationBarItemTapped(BuildContext context, int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 2) {
      selectedIndex = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UploadPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoService = VideoService();
    final screens = [
      HomeScreen(currentUser: currentUser),
      const Scaffold(body: Center(child: Text('Explore'))),
      const Scaffold(body: Center(child: Text('Upload Page'))),
      const Scaffold(body: Center(child: Text('Subscriptions'))),
      const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Log Out'),
          ElevatedButton(
            onPressed: _signOut, // Replace _signOut with the sign-out function
            child: Text('Log Out'),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: Consumer(
        builder: (context, watch, _) {
          final selectedVideo = watch(selectedVideoProvider).state;
          final miniPlayerController =
              watch(miniPlayerControllerProvider).state;
          return Stack(
            children: screens
                .asMap()
                .map((i, screen) => MapEntry(
                      i,
                      Offstage(
                        offstage: selectedIndex != i,
                        child: screen,
                      ),
                    ))
                .values
                .toList()
              ..add(
                Offstage(
                  offstage: selectedVideo == null,
                  child: Miniplayer(
                    controller: miniPlayerController,
                    minHeight: _playerMinHeight,
                    maxHeight: MediaQuery.of(context).size.height,
                    builder: (height, percentage) {
                      if (selectedVideo == null) return const SizedBox.shrink();

                      if (height <= _playerMinHeight + 50.0) {
                        return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.network(
                                    selectedVideo.thumbnailUrl,
                                    height: _playerMinHeight - 4.0,
                                    width: 120.0,
                                    fit: BoxFit.cover,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              selectedVideo.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              selectedVideo.authorId.username,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      context
                                          .read(selectedVideoProvider)
                                          .state = null;
                                    },
                                  ),
                                ],
                              ),
                              const LinearProgressIndicator(
                                value: 0.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return FutureBuilder<List<Video>>(
                        future: videoService.getVideos(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return VideoScreen(videos: snapshot.data ?? []);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: (i) => _onBottomNavigationBarItemTapped(context, i),
          selectedFontSize: 10.0,
          unselectedFontSize: 10.0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.subscriptions_outlined),
              activeIcon: Icon(Icons.subscriptions),
              label: 'Subscriptions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout_outlined),
              activeIcon: Icon(Icons.logout),
              label: 'LogOut',
            ),
          ]),
    );
  }
}
