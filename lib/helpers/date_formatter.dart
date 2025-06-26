import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/locale_provider.dart';

String formatDate(BuildContext context, String dateString,
    {String format = "d MMMM, yyyy - h:mm"}) {
  try {
    // Get the current locale from your LocaleProvider.
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final DateTime dateTime = DateTime.parse(dateString);
    final String languageCode = locale?.languageCode ?? 'en';

    // Create a formatter with the specified format and locale.
    final DateFormat formatter = DateFormat(format, languageCode);
    return formatter.format(dateTime.toUtc());
  } catch (e) {
    // If parsing fails, return the original string as a fallback.
    print("Error parsing date in helper: $e");
    return dateString;
  }
}
