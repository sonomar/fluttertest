import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_auth_provider.dart';

enum EmailFormStep { enterEmail, enterCode }

// --- WIDGET FOR CHANGING PASSWORD ---
class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  String _successMessage = '';

  Future<void> _submit() async {
    setState(() {
      _successMessage = '';
      _isSubmitting = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final success = await authProvider.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success) {
        setState(() {
          _successMessage = 'Password changed successfully!';
          _formKey.currentState?.reset();
        });
      }
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Change Password',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                    labelText: 'Old Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) =>
                    val!.isEmpty ? 'Please enter your current password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                    labelText: 'New Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => (val?.length ?? 0) < 8
                    ? 'Password must be at least 8 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => val != _newPasswordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 16),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                    onPressed: _submit, child: const Text('Update Password')),
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                ),
              if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_successMessage,
                      style: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.center),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET FOR CHANGING EMAIL ---
class ChangeEmailForm extends StatefulWidget {
  const ChangeEmailForm({super.key});

  @override
  State<ChangeEmailForm> createState() => _ChangeEmailFormState();
}

class _ChangeEmailFormState extends State<ChangeEmailForm> {
  EmailFormStep _currentStep = EmailFormStep.enterEmail;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isSubmitting = false;
  String _successMessage = '';

  Future<void> _submitEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _successMessage = '';
    });

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success =
        await authProvider.updateUserEmail(newEmail: _emailController.text);

    if (success) {
      setState(() => _currentStep = EmailFormStep.enterCode);
    }
    setState(() => _isSubmitting = false);
  }

  Future<void> _submitCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _successMessage = '';
    });

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success = await authProvider.verifyUserEmail(
        verificationCode: _codeController.text);

    if (success) {
      setState(() {
        _successMessage =
            'Email updated successfully! Please log out and log back in for the change to take full effect.';
        _currentStep = EmailFormStep.enterEmail;
        _formKey.currentState?.reset();
      });
      // Optional: Automatically sign the user out to force re-authentication
      // await authProvider.signOut();
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Change Email',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              if (_currentStep == EmailFormStep.enterEmail) ...[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'New Email Address',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => !(val?.contains('@') ?? false)
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                if (_isSubmitting)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                      onPressed: _submitEmail,
                      child: const Text('Send Verification Code')),
              ] else ...[
                // enterCode step
                Text(
                    'A verification code was sent to ${_emailController.text}. Please enter it below.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter the code' : null,
                ),
                const SizedBox(height: 16),
                if (_isSubmitting)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                      onPressed: _submitCode,
                      child: const Text('Verify & Change Email')),
              ],
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                ),
              if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_successMessage,
                      style: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.center),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
