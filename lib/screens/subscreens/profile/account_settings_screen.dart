import 'package:flutter/material.dart';
import 'package:kloppocar_app/widgets/profile/permissions_widgets.dart';
import 'package:kloppocar_app/widgets/auth/auth_widgets.dart';
import '../../../helpers/localization_helper.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate("account_header", context)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ChangePasswordForm(),
              const SizedBox(height: 24),
              ChangeEmailForm(),
              const SizedBox(height: 24),
              const CameraPermissionSwitch(),
            ],
          ),
        ),
      ),
    );
  }
}
