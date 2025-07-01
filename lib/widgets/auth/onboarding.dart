import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

    final success = await userModel.updateUsername(newUsername);

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
          _isSuccess ? "Welcome to the DEINS App!" : "Create a Username",
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
                  child: const Text('Start Exploring'),
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
            const Text(
                'Welcome to the DEINS app! Please create a username for yourself.'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a username.';
                }
                if (value.length < 5) {
                  return 'Username must be at least 5 characters.';
                }
                // 4. Add a validation rule to double-check the format
                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                  return 'Only letters and numbers are allowed.';
                }
                return null;
              },
            ),
            if (userModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  userModel.errorMessage!.contains('duplicate')
                      ? 'Username already in use. Please try another.'
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
                  child: const Text('Submit'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(UserModel userModel) {
    final username = userModel.currentUser?['username'] ?? 'Explorer';
    return Text('Your new username is: $username');
  }
}
