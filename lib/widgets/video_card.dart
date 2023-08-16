import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: deprecated_member_use
import 'package:flutter_riverpod/all.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/data.dart';
import '../screens/nav_screen.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final bool hasPadding;
  final VoidCallback? onTap;

  const VideoCard({
    Key? key,
    required this.video,
    this.hasPadding = false,
    this.onTap,
  }) : super(key: key);

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      String hours = twoDigits(duration.inHours);
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$seconds';
    } else if (duration.inMinutes > 0) {
      String minutes = twoDigits(duration.inMinutes);
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds';
    } else {
      String minutes = twoDigits(duration.inMinutes);
      String seconds = twoDigits(duration.inSeconds);
      return '$minutes:$seconds';
    }
  }

  Future<void> updateVideoViewCount(String videoId) async {
    final videoDocRef =
        FirebaseFirestore.instance.collection('videos').doc(videoId);

    await videoDocRef.update({
      'viewCount': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        context.read(selectedVideoProvider).state = video;
        Fluttertoast.showToast(msg: "VIDEO CLICKED");

        context
            .read(miniPlayerControllerProvider)
            .state
            .animateToHeight(state: PanelState.MAX);
        if (onTap != null) onTap!();
        await updateVideoViewCount(video.id);
      },
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hasPadding ? 12.0 : 0,
                ),
                child: Image.network(
                  video.thumbnailUrl,
                  height: 220.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8.0,
                right: hasPadding ? 20.0 : 8.0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  color: Colors.black,
                  child: Text(
                    formatDuration(Duration(seconds: video.duration)),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to profile or perform any other action
                  },
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(video.authorId.username)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          backgroundColor:
                              Colors.grey, // Display a loading state
                        );
                      }

                      if (snapshot.hasError) {
                        return const CircleAvatar(
                          backgroundColor: Colors.red, // Display an error state
                        );
                      }

                      final userData =
                          snapshot.data?.data() as Map<String, dynamic>?;

                      final profileUrl = userData?['profileUrl'] ??
                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png';

                      return CircleAvatar(
                        foregroundImage: NetworkImage(profileUrl),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 15.0),
                        ),
                      ),
                      Flexible(
                        child: FutureBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(video.authorId.username)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading...');
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return const Text('User not found');
                            }

                            final userData = snapshot.data!.data();
                            if (userData == null) {
                              return const Text('User data not found');
                            }

                            final username = userData[
                                'username']; // Assuming the username field is 'username'
                            final viewCount = video.viewCount;
                            final timestamp = video.timestamp;

                            return Text(
                              '$username • $viewCount views • ${timeago.format(timestamp)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 14.0),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                //options menu rght here

                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.more_vert, size: 20.0),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
