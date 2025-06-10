import 'package:flutter/material.dart';
import 'package:kloppocar_app/widgets/auth/auth_widgets.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ChangePasswordForm(),
              const SizedBox(height: 24),
              ChangeEmailForm(),
            ],
          ),
        ),
      ),
    );
  }
}
