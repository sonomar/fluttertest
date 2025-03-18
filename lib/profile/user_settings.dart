import 'package:flutter/material.dart';
import '../api/collection.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("User Settings")),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 50,
              child: Material(
                  child: InkWell(
                onTap: () {
                  getAllCollectibles();
                }, // Image tapped
                splashColor: Colors.white10, // Splash color over image
                child: Ink(
                    height: 50,
                    width: 100,
                    child: const Center(child: Text("Get All Collectibles"))),
              )),
            )
          ],
        ));
  }
}
