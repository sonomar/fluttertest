import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/app_auth_provider.dart';
import '../widgets/openCards/login_page.dart';
import '../widgets/item_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/collectible.dart';
import '../models/locale_provider.dart';
import '../models/app_localizations.dart';
import '../screens/subscreens/missions/award_screen.dart';
import './subscreens/profile/account_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri imprintUrl = Uri.parse('https://deins.io/Imprint');
    final Uri ppUrl = Uri.parse('https://deins.io/data-privacy');
    final Uri mailingListUrl = Uri.parse('https://deins.io/data-privacy');

    Future<String?> getUserEmail() async {
      final prefs = await SharedPreferences.getInstance();
      var email = prefs.getString('email');
      if (email != null) {
        return email;
      } else {
        return 'no email found';
      }
    }

    Future<void> resetDemo() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('item-test1', true);
      prefs.setBool('item-test2', false);
      prefs.setBool('item-test3', false);
      prefs.setBool('item-test4', false);
      prefs.setBool('item-test5', false);
      prefs.setBool('item-test6', false);
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Demo Reset'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('You have reset the demo.'),
                  Text('You now have only the first collectible.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _launchUrl(url) async {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Profile"),
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 28,
              color: Colors.black,
              fontFamily: 'ChakraPetch',
              fontWeight: FontWeight.w500,
            )),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ItemButton(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AccountSettingsScreen(),
                  ));
                },
                title: "Account Settings", // Or separate buttons if you prefer
                active: true),
            ItemButton(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const AwardScreen()),
                  );
                },
                title: "Awards",
                active: true),
            ItemButton(
                onTap: () {
                  _launchUrl(ppUrl);
                },
                title: "Privacy Policy",
                active: true),
            ItemButton(
                onTap: () {
                  // Use the provider to toggle the locale
                  Provider.of<LocaleProvider>(context, listen: false)
                      .toggleLocale();
                },
                // Use AppLocalizations to make the button text itself translatable
                title: AppLocalizations.of(context)!
                    .translate('profile_language_label'),
                active: true),
            ItemButton(
                onTap: () {
                  Provider.of<AppAuthProvider>(context, listen: false)
                      .signOut();
                  if (context.mounted) {
                    // Check if context is still valid
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                title: "Sign Out",
                active: true),
          ],
        ));
  }
}
