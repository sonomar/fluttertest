import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_localizations.dart';
import '../../models/locale_provider.dart';

/// Translates a static key from the app's local JSON files (e.g., en.json, de.json).
String translate(key, context) {
  return AppLocalizations.of(context)!.translate(key);
}

List<dynamic> decodeJsonFields(
    List<dynamic> dataList, List<String> keysToDecode) {
  if (dataList.isEmpty) return [];

  return dataList.map((item) {
    final newItem = Map<String, dynamic>.from(item);
    for (String key in keysToDecode) {
      if (newItem.containsKey(key) && newItem[key] is String) {
        try {
          // Check if the string is not empty before trying to decode
          if (newItem[key].isNotEmpty) {
            newItem[key] = jsonDecode(newItem[key]);
          }
        } catch (e) {
          print(
              'Failed to decode key "$key" with value: ${newItem[key]}. Error: $e');
          // If decoding fails, we might want to set it to a default value or leave as is
        }
      }
    }
    return newItem;
  }).toList();
}

String getTranslatedString(BuildContext context, dynamic jsonText,
    {String fallbackText = ''}) {
  // 1. Handle cases where the data is not a Map (e.g., it's null or already a String).
  // This provides backward compatibility for any fields you haven't converted to JSON yet.
  if (jsonText == null || jsonText is! Map<String, dynamic>) {
    return jsonText?.toString() ?? fallbackText;
  }

  // 2. Get the current language code (e.g., 'en' or 'de') from your LocaleProvider.
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  final String langCode = localeProvider.locale!.languageCode;

  // 3. Try to get the translation for the current app language.
  if (jsonText.containsKey(langCode) && jsonText[langCode] != null) {
    return jsonText[langCode].toString();
  }

  // 4. If the current language isn't available, try to fall back to English as a default.
  if (jsonText.containsKey('en') && jsonText['en'] != null) {
    return jsonText['en'].toString();
  }

  // 5. If English is also not found, grab the first available translation in the map.
  // This ensures that something is always displayed, even if it's not in the preferred language.
  if (jsonText.values.isNotEmpty) {
    final firstValue =
        jsonText.values.firstWhere((v) => v != null, orElse: () => null);
    if (firstValue != null) {
      return firstValue.toString();
    }
  }

  // 6. If the map is empty or contains only null values, return the final fallback text.
  return fallbackText;
}
