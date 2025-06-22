import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_auth_provider.dart';
import '../../../helpers/localization_helper.dart';
import 'package:google_fonts/google_fonts.dart';

enum EmailFormStep { enterEmail, enterCode }

// --- A styled container for the forms ---
Widget _buildFormContainer({required String title, required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.chakraPetch(
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

// --- Common InputDecoration for TextFormFields ---
InputDecoration _buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.grey),
    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffd622ca), width: 2),
    ),
  );
}

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
    // Clear previous messages
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);
    setState(() {
      _successMessage = '';
    });

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final success = await authProvider.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success && mounted) {
        setState(() {
          _successMessage = 'Password changed successfully!';
        });
        _formKey.currentState?.reset();
      }
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    return _buildFormContainer(
      title: translate("account_change_password_header", context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              decoration: _buildInputDecoration(
                  translate("account_change_password_old", context)),
              obscureText: true,
              validator: (val) =>
                  val!.isEmpty ? 'Please enter your current password' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: _buildInputDecoration(
                  translate("account_change_password_new", context)),
              obscureText: true,
              validator: (val) => (val?.length ?? 0) < 8
                  ? 'Password must be at least 8 characters'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: _buildInputDecoration(
                  translate("account_change_password_confirm", context)),
              obscureText: true,
              validator: (val) => val != _newPasswordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 20),
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xffd622ca),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child:
                    Text(translate("account_change_password_button", context)),
              ),
            if (authProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              ),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(_successMessage,
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center),
              ),
          ],
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
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _successMessage = '';
    });
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success =
        await authProvider.updateUserEmail(newEmail: _emailController.text);

    if (success && mounted) {
      setState(() => _currentStep = EmailFormStep.enterCode);
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _submitCode() async {
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _successMessage = '';
    });
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success = await authProvider.verifyUserEmail(
        verificationCode: _codeController.text);

    if (success && mounted) {
      setState(() {
        _successMessage = translate("account_change_email_success", context);
        _currentStep = EmailFormStep.enterEmail;
      });
      _formKey.currentState?.reset();
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    return _buildFormContainer(
      title: translate("account_change_email_header", context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentStep == EmailFormStep.enterEmail) ...[
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration(
                    translate("account_change_email_new", context)),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => !(val?.contains('@') ?? false)
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 20),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                    onPressed: _submitEmail,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xffd622ca),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(
                        translate("account_change_email_button", context))),
            ] else ...[
              // enterCode step
              Text(
                  '${translate("account_change_email_message_a", context)} ${_emailController.text}. ${translate("account_change_email_message_b", context)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: _buildInputDecoration(
                    translate("account_change_email_code", context)),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val!.isEmpty ? 'Please enter the code' : null,
              ),
              const SizedBox(height: 20),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                    onPressed: _submitCode,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xffd622ca),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(translate(
                        "account_change_email_verify_button", context))),
            ],
            if (authProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              ),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(_successMessage,
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}
