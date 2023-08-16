import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchKeyword = '';
  List<Map<String, dynamic>> _searchResults =
      []; // Replace with actual video data

  void _searchVideos() async {
    final videosCollection = FirebaseFirestore.instance.collection('videos');

    // Retrieve videos that match the search keyword
    final QuerySnapshot querySnapshot = await videosCollection
        .where('title', isGreaterThanOrEqualTo: _searchKeyword)
        .get();

    final List<Map<String, dynamic>> searchResults = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    setState(() {
      _searchResults = searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Search Videos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter search keyword...',
              ),
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchVideos,
              child: Text('Search'),
            ),
            SizedBox(height: 16),
            if (_searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Results:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final videoData = _searchResults[index];
                      final videoTitle = videoData['title'];
                      final videoThumbnailUrl = videoData['thumbnailUrl'];

                      return GestureDetector(
                        onTap: () {},
                        child: Card(
                          child: ListTile(
                            leading: Image.network(videoThumbnailUrl),
                            title: Text(videoTitle),
                            // Add other video details here
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
