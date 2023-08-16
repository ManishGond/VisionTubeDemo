import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final FirestoreUser authorId;
  final String title;
  final String desc;
  final String category;
  final String thumbnailUrl;
  final int duration;
  final DateTime timestamp;
  final int viewCount; // Change to int
  final int likes; // Change to int
  final int dislikes; // Change to int
  final String videoUrl;

  Video({
    required this.id,
    required this.authorId,
    required this.title,
    required this.desc,
    required this.category,
    required this.thumbnailUrl,
    required this.duration,
    required this.timestamp,
    required this.viewCount,
    required this.likes,
    required this.dislikes,
    required this.videoUrl,
  });

  factory Video.fromFirestore(Map<String, dynamic> data) {
    final dynamic durationData = data['duration'];
    final int duration =
        durationData is int ? durationData : int.tryParse(durationData) ?? 0;

    final dynamic viewCountData = data['viewCount'];
    final int viewCount =
        viewCountData is int ? viewCountData : int.tryParse(viewCountData) ?? 0;

    return Video(
      id: data['id'] ?? '',
      authorId: FirestoreUser(
        username: data['authorId'] ?? '',
        photoURL: 'https://bookofachievers.com/img/default_dp.jpg',
        subscribers: 0,
      ),
      title: data['title'] ?? '',
      desc: data['desc'] ?? '',
      category: data['category'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      duration: duration,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewCount: viewCount,
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      videoUrl: data['videoUrl'] ?? '',
    );
  }
}

class FirestoreUser {
  final String username;
  final String photoURL;
  final int subscribers;

  FirestoreUser({
    required this.username,
    required this.photoURL,
    required this.subscribers,
  });
}
