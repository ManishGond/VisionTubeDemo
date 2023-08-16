import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final usersCollection = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // You can put your refresh logic here, for example fetching new data from Firestore
          await Future.delayed(
              Duration(seconds: 2)); // Simulating refresh delay
        },
        child: FutureBuilder<DocumentSnapshot>(
          future: usersCollection.doc(currentUser!.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>?;

            final username = userData?['username'] ?? 'Username';
            final email = userData?['email'] ?? 'Email Address';
            final profileUrl = userData?['profileUrl'] ??
                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png';

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(profileUrl),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 243, 78, 78),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                final storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child('profile_images/${currentUser.uid}');
                                final storageTask =
                                    storageRef.putFile(File(pickedFile.path));

                                // Wait for the upload to complete
                                await storageTask;

                                // Get the updated download URL
                                final downloadUrl =
                                    await storageRef.getDownloadURL();

                                final userDocRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid);
                                await userDocRef
                                    .update({'profileUrl': downloadUrl});

                                // No need to call setState here, as FutureBuilder will handle the UI update
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    username,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Sign out the user
                      await FirebaseAuth.instance.signOut();

                      // Navigate to LoginPage
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login', // Replace with the route name of your LoginPage
                        (route) =>
                            false, // This removes all routes from the stack
                      );
                    },
                    child: Text('Log Out'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
