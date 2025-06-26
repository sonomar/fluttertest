import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/news_posts/news_item.dart'; // Import the new reusable widget

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
  /// Formats the date string for the AppBar title.
  String _formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      // Example format: 30 June, 2025 - 10:30am GMT
      final DateFormat formatter = DateFormat("d MMMM, yyyy - h:mma 'GMT'");
      return formatter.format(dateTime.toUtc());
    } catch (e) {
      // If parsing fails, return the original string as a fallback.
      print("Error parsing date: $e");
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.selectedNewsPost['updatedDt'] ?? '';

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // Use the formatted date in the title.
        title: Text(_formatDate(date)),
        titleTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontFamily: 'Roboto',
        ),
      ),
      body: SingleChildScrollView(
        // The body is now much cleaner, just calling the reusable widget.
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: NewsItem(newsPost: widget.selectedNewsPost),
        ),
      ),
    );
  }
}
