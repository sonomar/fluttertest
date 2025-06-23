import 'package:flutter/material.dart';
import 'package:deins_app/widgets/auth/auth_widgets.dart';
import '../../../helpers/localization_helper.dart';
import 'package:provider/provider.dart';
import '../../../models/app_auth_provider.dart';
import '../../../models/user_model.dart';
import '../../../widgets/profile/profile_menu_item.dart';
import 'package:url_launcher/url_launcher.dart';

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
            title: const Text('Delete Account?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('This action is permanent and cannot be undone.'),
                  const Text('Are you sure you want to delete your account?'),
                  if (isDeleting) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 10),
                    const Center(child: Text("Deleting account...")),
                  ]
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: isDeleting
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop();
                      },
              ),
              // Styled Delete Button
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
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Error: Could not find user ID to delete account.")));
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
                child: const Text('Delete'),
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
              // The form widgets will be styled in the next step
              ProfileMenuItem(
                icon: Icons.gavel_outlined,
                title: translate("profile_pp_label", context),
                onTap: () => launchUrlHelper(ppUrl),
              ),
              const SizedBox(height: 24),
              const ChangePasswordForm(),
              const SizedBox(height: 24),
              const ChangeEmailForm(),
              const SizedBox(height: 40),

              // Restyled Delete Button Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.2))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Danger Zone",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        "This action cannot be undone. All your data and collectibles will be permanently removed.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirmationDialog(context),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete My Account Permanently'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
