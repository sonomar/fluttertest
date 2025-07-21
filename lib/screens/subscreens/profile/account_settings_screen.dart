import 'package:flutter/material.dart';
import 'package:deins_app/widgets/auth/auth_widgets.dart';
import '../../../helpers/localization_helper.dart';
import 'package:provider/provider.dart';
import '../../../models/app_auth_provider.dart';
import '../../../models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/profile/permissions_widgets.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
                translate("account_settings_delete_dialog_title", context)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(translate(
                      "account_settings_delete_dialog_perm", context)),
                  const SizedBox(height: 10),
                  Text(translate(
                      "account_settings_delete_dialog_confirm", context)),
                  if (isDeleting) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 10),
                    Center(
                        child: Text(translate(
                            "account_settings_delete_dialog_progress",
                            context))),
                  ]
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: isDeleting
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop();
                      },
                child: Text(translate("cancel_button", context)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: isDeleting
                    ? null
                    : () async {
                        setState(() {
                          isDeleting = true;
                        });
                        final authProvider = Provider.of<AppAuthProvider>(
                            context,
                            listen: false);
                        final userModel =
                            Provider.of<UserModel>(context, listen: false);
                        final String? userId =
                            userModel.currentUser?['userId']?.toString();

                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(translate(
                                  "account_settings_delete_dialog_error",
                                  context))));
                          if (dialogContext.mounted)
                            Navigator.of(dialogContext).pop();
                          return;
                        }

                        await authProvider.deleteAccount(userId: userId);

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext)
                              .popUntil((route) => route.isFirst);
                        }
                      },
                child: Text(translate(
                    "account_settings_delete_dialog_delete", context)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Uri ppUrl = Uri.parse('https://deins.io/data-privacy');
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(translate("account_header", context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black, // Makes back button black
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const ChangePasswordForm(),
              const SizedBox(height: 24),
              const ChangeEmailForm(),
              const SizedBox(height: 40), // Spacing before new section
              // New Permissions Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('permissions_header', context) ?? 'Permissions',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Divider(height: 20, thickness: 1),
                    const CameraPermissionSwitch(),
                    const PushNotificationPermissionSwitch(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                  child: InkWell(
                child: Text(
                  translate("account_settings_build_terms", context),
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () =>
                    launchUrl(Uri.parse('https://deins.io/data-privacy')),
              )),
              const SizedBox(height: 24),
              Center(
                  child: InkWell(
                child: Text(
                  translate("account_settings_build_privacy", context),
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () =>
                    launchUrl(Uri.parse('https://deins.io/data-privacy')),
              )),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.2))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirmationDialog(context),
                      icon: const Icon(Icons.delete_forever),
                      label: Text(translate(
                          "account_settings_build_delete_btn", context)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                            translate("account_settings_build_delete_warning",
                                context),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.redAccent))),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Consumer<AppAuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
