import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/locale_provider.dart';
import '../../../helpers/localization_helper.dart';

// A simple class to hold our language data
class Language {
  final String name;
  final Locale locale;

  Language(this.name, this.locale);
}

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Language> supportedLanguages = [
      Language(
          translate("lang_page_build_english", context), const Locale('en')),
      Language(
          translate("lang_page_build_german", context), const Locale('de')),
    ];

    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('profile_language_label', context)),
        backgroundColor: const Color(0xFFF7F8FC),
        scrolledUnderElevation: 0.0,
      ),
      backgroundColor: const Color(0xFFF7F8FC),
      body: ListView.builder(
        itemCount: supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = supportedLanguages[index];
          final bool isSelected = language.locale == localeProvider.locale;

          return ListTile(
            title: Text(language.name),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              // Set the new locale and pop the screen
              localeProvider.setLocale(language.locale);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
