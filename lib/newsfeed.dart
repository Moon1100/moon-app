import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class NewsFeedPage1 extends StatefulWidget {
  const NewsFeedPage1({super.key});

  @override
  State<NewsFeedPage1> createState() => _NewsFeedPage1State();
}

class _NewsFeedPage1State extends State<NewsFeedPage1> {
  List<FeedItem> _feedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

Future<void> fetchNews() async {
  const url =
      "https://real-time-news-data.p.rapidapi.com/topic-news-by-section?topic=TECHNOLOGY&section=CAQiSkNCQVNNUW9JTDIwdk1EZGpNWFlTQldWdUxVZENHZ0pKVENJT0NBUWFDZ29JTDIwdk1ETnliSFFxQ2hJSUwyMHZNRE55YkhRb0FBKi4IACoqCAoiJENCQVNGUW9JTDIwdk1EZGpNWFlTQldWdUxVZENHZ0pKVENnQVABUAE&limit=10&country=US&lang=en";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "x-rapidapi-key": "6c4b6bab23mshaa927ad6022961cp170e32jsn025a1defbb7a",
        "x-rapidapi-host": "real-time-news-data.p.rapidapi.com",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List articles = (data['data'] ?? []) as List;

      if (!mounted) return; // Prevent setState on disposed widget

      setState(() {
        _feedItems = articles.map((item) {
          return FeedItem(
            content: item['title'] ?? 'No title available',
            imageUrl: (item['photo_url']?.isNotEmpty ?? false)
                ? item['photo_url']
                : null,
            user: User(
              item['source_name'] ?? 'Unknown Source',
              (item['source_name'] ?? 'source').toLowerCase().replaceAll(' ', '_'),
              "https://picsum.photos/80/80", // Placeholder avatar
            ),
          );
        }).toList();
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint("Failed to load news: ${response.statusCode} ${response.body}");
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    debugPrint("Error fetching news: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ListView.separated(
                  itemCount: _feedItems.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(color: Colors.grey[800]);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final item = _feedItems[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AvatarImage(item.user.imageUrl),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.user.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.content != null)
                                    Text(
                                      item.content!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (item.imageUrl != null)
                                    Container(
                                      height: 200,
                                      margin: const EdgeInsets.only(top: 8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(item.imageUrl!),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String url;
  const _AvatarImage(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: NetworkImage(url)),
        border: Border.all(color: Colors.grey[800]!, width: 2),
      ),
    );
  }
}

class FeedItem {
  final String? content;
  final String? imageUrl;
  final User user;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;

  FeedItem({
    this.content,
    this.imageUrl,
    required this.user,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.retweetsCount = 0,
  });
}

class User {
  final String fullName;
  final String imageUrl;
  final String userName;

  User(this.fullName, this.userName, this.imageUrl);
}
