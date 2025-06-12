import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate(key: ValueKey('AppLocalizationsDelegate_'));

  Map<String, String> _localizedStrings = {};

  Future<void> _loadFromAssets() async {
    try {
      print(
          '--- Fallback: Loading translations from local assets for ${locale.languageCode}. ---');
      String jsonString =
          await rootBundle.loadString('l10n/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print(
          '--- Fallback failed: Could not load local asset for ${locale.languageCode}. Error: $e ---');
      // If even the fallback fails, default to an empty map.
      _localizedStrings = {};
    }
  }

  Future<void> load() async {
    const String baseUrl = "https://deins.s3.eu-central-1.amazonaws.com/l10n/";
    final Uri url = Uri.parse('$baseUrl${locale.languageCode}.json');

    try {
      // 2. Fetch the localization file from the server.
      final response = await http.get(url);

      // 3. Check for a successful response and decode the JSON.
      if (response.statusCode == 200) {
        // Use utf8.decode from 'dart:convert' to correctly handle special characters like German umlauts.
        final String jsonString = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonMap = json.decode(jsonString);

        _localizedStrings =
            jsonMap.map((key, value) => MapEntry(key, value.toString()));
      } else {
        // Handle cases where the server returns an error (e.g., 404 Not Found).
        print(
            'Failed to load localization file from $url. Status code: ${response.statusCode}');
        // As a fallback, you could load from local assets or have default hardcoded strings.
        await _loadFromAssets();
      }
    } catch (e) {
      // Handle network errors or other exceptions.
      print('Error loading localization file from $url: $e');
      // Fallback for when the request fails.
      await _loadFromAssets();
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate({this.key});
  final ValueKey? key;

  @override
  bool isSupported(Locale locale) => ['de', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
