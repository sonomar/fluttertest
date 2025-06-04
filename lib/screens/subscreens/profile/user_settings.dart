import 'package:flutter/material.dart';
import '../../../api/collectible.dart';

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
        appBar: AppBar(title: const Text("User Settings")),
        body: ListView(
          padding: const EdgeInsets.all(8),
        ));
  }
}
