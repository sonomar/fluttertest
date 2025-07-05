import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../helpers/localization_helper.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable widget to display a full news post with all its components.
class NewsItem extends StatelessWidget {
  const NewsItem({
    super.key,
    required this.newsPost,
  });

  final Map<dynamic, dynamic> newsPost;

  /// Safely launches a URL.
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data from the map with null safety
    final type = newsPost['type'] ?? '';
    final header = newsPost['header'] ?? '';
    final body = newsPost['body'] ?? '';
    final headerImageUrl = newsPost['imgRef']?['header'];
    final linkButtonUrl = newsPost['embedRef']?['linkButtonRef'];
    final linkButtonText = newsPost['embedRef']?['linkButtonTextDe'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Text(
            type.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: Colors.white,
                fontFamily: 'ChakraPetch',
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),

        // Header Text
        Text(
          getTranslatedString(context, header),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'ChakraPetch',
          ),
        ),
        const SizedBox(height: 20),

        // Conditionally display the header image or a divider
        if (headerImageUrl != null && headerImageUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Image.network(
              headerImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error_outline),
            ),
          )
        else
          const Divider(height: 20, thickness: 1, color: Colors.grey),

        // Render the body content as HTML, which is safe from injections.
        Html(
          data: getTranslatedString(context, body),
          style: {
            "body": Style(
              fontSize: FontSize(16.0),
              fontFamily: 'Roboto',
            ),
            "a": Style(
              color: Theme.of(context).primaryColor,
              textDecoration: TextDecoration.underline,
            ),
          },
          onLinkTap: (url, _, __) {
            if (url != null) {
              _launchUrl(url);
            }
          },
        ),

        // Conditionally display the link button
        if (linkButtonUrl != null && linkButtonUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffd622ca),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'ChakraPetch',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _launchUrl(linkButtonUrl),
                child: Text(
                  (linkButtonText != null && linkButtonText.isNotEmpty)
                      ? linkButtonText
                      : 'More Information',
                ),
              ),
            ),
          ),
      ],
    );
  }
}
