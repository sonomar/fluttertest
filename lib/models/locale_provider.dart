import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // Load the saved locale from device storage
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // If no language preference is saved, default to German.
      _locale = Locale('de');
    }
    notifyListeners();
  }

  // Set the new locale and save it to device storage
  void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    _locale = locale;
    notifyListeners();
  }

  // A simple method to toggle between English and German
  void toggleLocale() {
    if (_locale == null || _locale!.languageCode == 'en') {
      setLocale(Locale('de'));
    } else {
      setLocale(Locale('en'));
    }
  }
}
