import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../helpers/localization_helper.dart';
import '../../models/user_model.dart';
import '../../models/app_auth_provider.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submitAndFinish() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final userModel = context.read<UserModel>();
    final authProvider = context.read<AppAuthProvider>();
    final newUsername = _usernameController.text.trim().toLowerCase();

    // This attempts to update the username and the userType in one API call.
    final success = await userModel.updateUsername(newUsername);

    // Ensure the widget is still mounted before interacting with context.
    if (mounted && success) {
      // THIS IS THE KEY STEP:
      // If the user was a "new user", this resets the flag.
      authProvider.completeNewUserOnboarding();

      // Close the onboarding dialog.
      Navigator.of(context).pop();
    }
    // If it fails, the error message will automatically appear in the form
    // thanks to the Consumer widget listening to UserModel.
  }
  // --- END: MODIFIED SUBMISSION LOGIC ---

  @override
  Widget build(BuildContext context) {
    // Prevent the user from backing out of the onboarding.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        return;
      },
      child: AlertDialog(
        title: Text(translate("onboarding_build_createtitle", context)),
        content: Consumer<UserModel>(
          builder: (context, userModel, _) {
            // The view is now simpler and only needs to show the form.
            return _buildFormView(userModel);
          },
        ),
        // Actions are now part of the form itself.
      ),
    );
  }

  Widget _buildFormView(UserModel userModel) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate("onboarding_form_body", context)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: translate("onboarding_form_usernamelabel", context),
                border: const OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return translate("onboarding_form_uservalidator1", context);
                }
                if (value.length < 5) {
                  return translate("onboarding_form_uservalidator2", context);
                }
                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                  return translate("onboarding_form_uservalidator3", context);
                }
                return null;
              },
            ),
            if (userModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  // Use the helper to translate known error keys
                  translate(userModel.errorMessage!, context),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 20),
            if (userModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  // The button now calls the combined submit and finish function.
                  onPressed: _submitAndFinish,
                  child:
                      Text(translate("onboarding_form_submitbutton", context)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
