import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/search_page.dart';

class CustomSliverAppBar extends StatelessWidget {
  final User? currentUser;
  const CustomSliverAppBar({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const SliverAppBar();
    }
    final usersCollection = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
      future: usersCollection.doc(currentUser!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverAppBar();
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;

        final profileUrl = userData?['profileUrl'] ??
            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";

        return SliverAppBar(
          floating: true,
          pinned: true,
          leadingWidth: 150.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Image.asset(
              'assets/logo.png',
              width: 700,
              height: 700,
              fit: BoxFit.cover,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.cast),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
            ),
            IconButton(
              iconSize: 40.0,
              icon: Padding(
                padding: const EdgeInsets.all(3.0),
                child: CircleAvatar(
                  foregroundImage: profileUrl != null
                      ? NetworkImage(profileUrl)
                      : const NetworkImage(
                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png",
                        ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
