import 'package:flutter/material.dart';
import './profile/user_settings.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri imprintUrl = Uri.parse('https://deins.io/Imprint');
    final Uri ppUrl = Uri.parse('https://deins.io/data-privacy');
    final Uri mailingListUrl = Uri.parse('https://deins.io/data-privacy');

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
                    child: const Center(child: Text("Sign Up!"))),
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
          ],
        ));
  }
}
