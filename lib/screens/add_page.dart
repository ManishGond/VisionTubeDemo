import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../models/data.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Gaming';
  File? _thumbnailFile;
  File? _videoFile;
  String formattedDuration = '';
  FirestoreUser? user;
  Video? newVideo;
  VideoPlayerController? _videoPlayerController;

  final firebase_auth.User? currentUser =
      firebase_auth.FirebaseAuth.instance.currentUser;

  bool _isFormValid() {
    return _titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _selectedCategory.isNotEmpty;
  }

  void _uploadVideo() async {
    String thumbnailUrl = '';
    String videoUrl = '';
    int videoDurationInSeconds = 0;
    if (_thumbnailFile != null && _videoFile != null) {
      thumbnailUrl = await uploadThumbnailToFirebaseStorage();
      videoUrl = await uploadVideoToFirebaseStorage();

      Fluttertoast.showToast(
        msg: 'Video uploaded successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized) {
        videoDurationInSeconds =
            _videoPlayerController!.value.duration.inSeconds;
      }

      final CollectionReference videosCollection =
          FirebaseFirestore.instance.collection('videos');
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        videosCollection.add({
          'authorId': currentUser.uid,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'thumbnailUrl': thumbnailUrl,
          'videoUrl': videoUrl,
          'duration': videoDurationInSeconds,
          'timestamp': FieldValue.serverTimestamp(),
          'viewCount': 0,
          'likes': 0,
          'dislikes': 0,
        });
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  // Function to upload thumbnail image to Firebase Cloud Storage
  Future<String> uploadThumbnailToFirebaseStorage() async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('thumbnails')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    firebase_storage.UploadTask uploadTask = ref.putFile(_thumbnailFile!);
    firebase_storage.TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadVideoToFirebaseStorage() async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('videos')
        .child('${DateTime.now().millisecondsSinceEpoch}.mp4');

    firebase_storage.UploadTask uploadTask = ref.putFile(_videoFile!);
    firebase_storage.TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void _selectVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            if (kDebugMode) {
              print('VideoPlayerController initialized successfully.');
            }
            if (kDebugMode) {
              print(
                  'Video duration: ${_videoPlayerController!.value.duration}');
            }
            setState(() {});
          });
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision+ Creator Studio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description TextFormField
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Gaming', 'People & Bloggs', 'Science', 'Music']
                    .map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category must be selected';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Select Category'),
              ),
              const SizedBox(height: 16),

              // Thumbnail Image Upload
              ElevatedButton(
                onPressed: _selectThumbnail,
                child: const Text('Select Thumbnail Image'),
              ),
              const SizedBox(height: 16),
              _thumbnailFile != null
                  ? Container(
                      height: 300,
                      width: 400,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_thumbnailFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(), // Show an empty container if _thumbnailFile is null

              ElevatedButton(
                onPressed: _selectVideo,
                child: const Text('Select a Video'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Record a Video'),
              ),
              const SizedBox(height: 16),

              Stack(
                alignment: Alignment.center,
                children: [
                  if (_videoFile != null)
                    SizedBox(
                      width:
                          440, // Set the width to a smaller value for the preview rectangle
                      height:
                          440, // Set the height to a smaller value for the preview rectangle
                      child: AspectRatio(
                        aspectRatio:
                            1280 / 720, // Set the aspect ratio to 1280:720
                        child: _videoPlayerController != null &&
                                _videoPlayerController!.value.isInitialized
                            ? VideoPlayer(_videoPlayerController!)
                            : Container(),
                      ),
                    ),
                ],
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _isFormValid() ? _uploadVideo : null,
                  child: const Text('Upload [+]'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectThumbnail() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }
}
