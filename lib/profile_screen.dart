import 'package:flutter/material.dart';
import './profile/user_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/signout.dart';
import './openCards/login_page.dart';
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

    Future<void> _launchUrl(url) async {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 50,
              child: Material(
                  child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const UserSettings() //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
                        ),
                  );
                }, // Image tapped
                splashColor: Colors.white10, // Splash color over image
                child: Ink(
                    height: 50,
                    width: 100,
                    child: const Center(child: Text("User Options"))),
              )),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 50,
              child: Material(
                  child: InkWell(
                onTap: () {
                  _launchUrl(mailingListUrl);
                }, // Image tapped
                splashColor: Colors.white10, // Splash color over image
                child: Ink(
                    height: 50,
                    width: 100,
                    child: const Center(child: Text("Mailing List"))),
              )),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 50,
              child: Material(
                  child: InkWell(
                onTap: () {
                  _launchUrl(ppUrl);
                }, // Image tapped
                splashColor: Colors.white10, // Splash color over image
                child: Ink(
                    height: 50,
                    width: 100,
                    child: const Center(child: Text("Privacy Policy"))),
              )),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 50,
              child: Material(
                  child: InkWell(
                onTap: () {
                  _launchUrl(mailingListUrl);
                }, // Image tapped
                splashColor: Colors.white10, // Splash color over image
                child: Ink(
                    height: 50,
                    width: 100,
                    child: const Center(child: Text("Imprint"))),
              )),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 50,
              child: Material(
                  child: InkWell(
                onTap: () {
                  final navigator = Navigator.of(context);
                  getUserEmail().then((email) => {
                        logOut(email).then((value) => {
                              navigator.push(MaterialPageRoute(
                                  builder: (context) => LoginPage()))
                            })
                      });
                }, // Image tapped
                splashColor: Colors.white10, // Splash color over image
                child: Ink(
                    height: 50,
                    width: 100,
                    child: const Center(child: Text("Sign Out"))),
              )),
            ),
          ],
        ));
  }
}
