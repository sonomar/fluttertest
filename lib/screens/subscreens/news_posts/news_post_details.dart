import 'package:flutter/material.dart';
import '../../../widgets/news_posts/news_item.dart';

class NewsPostDetails extends StatefulWidget {
  const NewsPostDetails({
    super.key,
    required this.selectedNewsPost,
  });
  final Map selectedNewsPost;

  @override
  State<NewsPostDetails> createState() => _NewsPostDetailsDetailsState();
}

class _NewsPostDetailsDetailsState extends State<NewsPostDetails> {
  @override
  Widget build(BuildContext context) {
    final post = widget.selectedNewsPost;
    final type = post['type'] ?? '';
    final date = post['updatedDt'] ?? '';
    final header = post['header'] ?? '';
    final body = post['body'] ?? '';
    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.selectedNewsPost["updatedDt"]),
        ),
        body: Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(child: newsItem(type, date, header, body))));
  }
}
