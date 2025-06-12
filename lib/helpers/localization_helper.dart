import '../../models/app_localizations.dart';

String translate(key, context) {
  return AppLocalizations.of(context)!.translate(key);
}
