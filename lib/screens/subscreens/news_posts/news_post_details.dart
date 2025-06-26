import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/locale_provider.dart';
import '../../../widgets/news_posts/news_item.dart';
import '../../../helpers/date_formatter.dart';

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
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final date = widget.selectedNewsPost['updatedDt'] ?? '';

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // Use the formatted date in the title.
        title: Text(formatDate(context, date, format: "d MMMM, yyyy - h:mm")),
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
