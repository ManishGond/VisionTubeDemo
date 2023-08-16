import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/data.dart';

class VideoInfo extends StatelessWidget {
  final Video video;

  const VideoInfo({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.title,
            style:
                Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            '${video.viewCount} views • ${timeago.format(video.timestamp)}',
            style:
                Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14.0),
          ),
          const Divider(),
          _ActionsRow(video: video),
          const Divider(),
          _AuthorInfo(
              authorId: video.authorId.username), // Pass the authorId here
          const Divider(),
        ],
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  final String authorId;

  const _AuthorInfo({
    Key? key,
    required this.authorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future:
          FirebaseFirestore.instance.collection('users').doc(authorId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('User not found');
        }

        final userData = snapshot.data!.data()!;

        final firestoreUser = FirestoreUser(
          username: userData['username'] ?? '',
          photoURL: userData['photoURL'] ?? '',
          subscribers: userData['subscribers'] ?? 0,
        );

        return GestureDetector(
          // ignore: avoid_print
          onTap: () => print('Navigate to profile'),
          child: Row(
            children: [
              CircleAvatar(
                foregroundImage: NetworkImage(firestoreUser.photoURL),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        firestoreUser.username,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 15.0),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${firestoreUser.subscribers} subscribers',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'SUBSCRIBE',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.red),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final Video video;

  const _ActionsRow({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAction(context, Icons.thumb_up_outlined, video.likes.toString()),
        _buildAction(
            context, Icons.thumb_down_outlined, video.dislikes.toString()),
        _buildAction(context, Icons.reply_outlined, 'Share'),
        _buildAction(context, Icons.download_outlined, 'Download'),
        _buildAction(context, Icons.library_add_outlined, 'Save'),
      ],
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 6.0),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
