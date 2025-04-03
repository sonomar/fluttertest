import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/signout.dart';
import './openCards/login_page.dart';
import './widgets/item_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white,
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
                  _launchUrl(mailingListUrl);
                },
                title: "Mailing List"),
            ItemButton(
                onTap: () {
                  _launchUrl(ppUrl);
                },
                title: "Privacy Policy"),
            ItemButton(
                onTap: () {
                  _launchUrl(mailingListUrl);
                },
                title: "Imprint"),
            ItemButton(
                onTap: () {
                  _launchUrl(resetDemo());
                },
                title: "Reset Demo"),
            ItemButton(
                onTap: () {
                  final navigator = Navigator.of(context);
                  getUserEmail().then((email) => {
                        logOut(email).then((value) => {
                              navigator.push(MaterialPageRoute(
                                  builder: (context) => LoginPage()))
                            })
                      });
                },
                title: "Sign Out"),
          ],
        ));
  }
}
