import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Container(
          decoration: BoxDecoration(border: Border.all()),
          height: 50,
          child: const Center(child: Text('User Settings')),
        ),
        Container(
          decoration: BoxDecoration(border: Border.all()),
          height: 50,
          child: const Center(child: Text('Sign Up Today!')),
        ),
        Container(
          decoration: BoxDecoration(border: Border.all()),
          height: 50,
          child: const Center(child: Text('Terms & Conditions')),
        ),
        Container(
          decoration: BoxDecoration(border: Border.all()),
          height: 50,
          child: const Center(child: Text('Privacy Policy')),
        ),
      ],
    );
  }
}
