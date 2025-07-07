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

  bool _isSuccess = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submitUsername() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final userModel = context.read<UserModel>();
    final newUsername = _usernameController.text.trim().toLowerCase();

    final success = await userModel.completeOnboarding(newUsername, context);

    if (mounted && success) {
      setState(() {
        _isSuccess = true;
      });
    }
  }

  void _finishOnboarding() {
    context.read<AppAuthProvider>().completeNewUserOnboarding();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // This prevents the pop gesture.
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        return;
      },
      child: AlertDialog(
        title: Text(
          _isSuccess
              ? translate("onboarding_build_welcometitle", context)
              : translate("onboarding_build_createtitle", context),
        ),
        content: Consumer<UserModel>(
          builder: (context, userModel, _) {
            return _isSuccess
                ? _buildSuccessView(userModel)
                : _buildFormView(userModel);
          },
        ),
        actions: _isSuccess
            ? [
                TextButton(
                  onPressed: _finishOnboarding,
                  child:
                      Text(translate("onboarding_build_startbutton", context)),
                ),
              ]
            : [],
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
                border: OutlineInputBorder(),
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
                // 4. Add a validation rule to double-check the format
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
                  userModel.errorMessage!.contains('duplicate')
                      ? translate("onboarding_form_duplicateuser", context)
                      : userModel.errorMessage!,
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
                  onPressed: _submitUsername,
                  child:
                      Text(translate("onboarding_form_submitbutton", context)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(UserModel userModel) {
    final username = userModel.currentUser?['username'] ?? 'Explorer';
    return Text('${translate("onboarding_success_body", context)} $username');
  }
}
