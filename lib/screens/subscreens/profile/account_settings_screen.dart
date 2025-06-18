import 'package:flutter/material.dart';
import 'package:deins_app/widgets/profile/permissions_widgets.dart';
import 'package:deins_app/widgets/auth/auth_widgets.dart';
import '../../../helpers/localization_helper.dart';
import 'package:provider/provider.dart';
import '../../../models/app_auth_provider.dart';
import '../../../models/user_model.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // A loading state local to the dialog
        bool isDeleting = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
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
                // Disable cancel button while deleting
                onPressed: isDeleting
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop();
                      },
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                // Disable delete button while deleting
                onPressed: isDeleting
                    ? null
                    : () async {
                        // --- START OF FIX ---
                        // Show a loading indicator inside the dialog
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

                        final success =
                            await authProvider.deleteAccount(userId: userId);

                        // After the operation, regardless of success or failure,
                        // if the dialog is still visible, close it.
                        // The authProvider's state change will handle navigating to the login screen.
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext)
                              .popUntil((route) => route.isFirst);
                        }
                        // --- END OF FIX ---
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
              const Divider(thickness: 1, color: Colors.black),
              Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Card(
                    color: Colors.red[50],
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        onPressed: () => _showDeleteConfirmationDialog(context),
                        icon: const Icon(Icons.warning, color: Colors.red),
                        label: const Text(
                          'Delete Account',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )),
              Consumer<AppAuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
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
