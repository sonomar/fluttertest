import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/localization_helper.dart';
import '../../models/app_auth_provider.dart';

enum AuthFormType { login, register, confirm }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.userData});
  final dynamic userData;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _confirmationCodeController =
      TextEditingController();

  var _formType = AuthFormType.login;
  bool _isSubmitting = false;
  bool isNewUser = false;
  String _uiErrorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }

  void _switchFormType() {
    _formKey.currentState?.reset();
    _uiErrorMessage = '';
    // Clear the provider's error message when switching forms
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);
    setState(() {
      _formType = (_formType == AuthFormType.login)
          ? AuthFormType.register
          : AuthFormType.login;
    });
  }

  //

  /// Main submission logic
  Future<void> _submit() async {
    // Clear previous UI-specific errors
    setState(() {
      _uiErrorMessage = '';
    });
    // Clear provider error
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      bool success = false;

      if (_formType == AuthFormType.login) {
        // --- LOGIN LOGIC ---
        await authProvider.signIn(email, password);
        // The provider's status change will trigger navigation in main.dart
        // No need to set isSubmitting to false if navigation occurs.
        // If it fails, the provider will hold the error and notify listeners.
      } else if (_formType == AuthFormType.register) {
        // --- REGISTER LOGIC ---
        success = await authProvider.signUp(email: email, password: password);
        if (success) {
          // If sign-up is successful, switch to the confirmation form
          setState(() {
            _formType = AuthFormType.confirm;
            _isSubmitting = false;
          });
          return; // Return to prevent setting _isSubmitting to false again
        }
      } else if (_formType == AuthFormType.confirm) {
        // --- CONFIRMATION LOGIC ---
        final code = _confirmationCodeController.text.trim();
        success = await authProvider.confirmSignUp(
            email: email, confirmationCode: code);
        if (success) {
          // If confirmation is successful, automatically log the user in
          // Use the isRegister flag to trigger user record update in your DB
          print(
              'Login Page: Post-registration sign-in. Adding a short delay...');
          await Future.delayed(const Duration(seconds: 2));
          print('Login Page: Delay complete. Proceeding with user data fetch.');
          await authProvider.signIn(email, password, isRegister: true);
          return; // Navigation will be handled by the provider status change
        }
      }

      // If we reach here, a step failed and did not navigate.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Future<void> getEmailCode() async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Confirm Email'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               const Text(
  //                   'Thank you for registering. You should receive an email shortly with a confirmation code.'),
  //               const Text('Please enter your email confirmation code below'),
  //               Material(
  //                   child: Form(
  //                 child: TextFormField(
  //                   controller: _emailCodeController,
  //                   style: TextStyle(color: Colors.black),
  //                   decoration: InputDecoration(labelText: 'Email Code'),
  //                   validator: (value) {
  //                     if (value!.isEmpty) {
  //                       return 'Please enter your confirmation code';
  //                     }
  //                     return null;
  //                   },
  //                 ),
  //               )),
  //               Text(
  //                 _codeErrorMessage,
  //                 style: TextStyle(color: Colors.red),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Confirm'),
  //             onPressed: () async {
  //               final navigator = Navigator.of(context);
  //               await emailConfirmUser(
  //                   _emailController.text,
  //                   _passwordController.text,
  //                   _emailCodeController.text,
  //                   context);
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final providerErrorMessage = authProvider.errorMessage;
    return Scaffold(
      backgroundColor: Colors.black, // Page background is black
      appBar: AppBar(
        backgroundColor: Colors.black, // App bar background is black
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensures back button/menu icons are white
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _formType == AuthFormType.login
                      ? translate('login_header', context)
                      : _formType == AuthFormType.register
                          ? translate('register_header', context)
                          : translate('confirm_code_header', context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // --- DYNAMIC FORM FIELDS ---
                ..._buildFormFields(),
                const SizedBox(height: 20),

                // --- ERROR MESSAGE ---
                if (providerErrorMessage != null || _uiErrorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      providerErrorMessage ?? _uiErrorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // --- SUBMIT BUTTON ---
                if (_isSubmitting)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _formType == AuthFormType.login
                          ? translate('login_header', context)
                          : _formType == AuthFormType.register
                              ? translate('register_header', context)
                              : translate('confirm_code_header', context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 20),

                // --- FORM TYPE SWITCHER ---
                if (_formType != AuthFormType.confirm)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formType == AuthFormType.login
                            ? translate("login_register_switch_text", context)
                            : translate("register_login_switch_text", context),
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                          onPressed: _isSubmitting ? null : _switchFormType,
                          child: Text(
                            _formType == AuthFormType.login
                                ? translate(
                                    "login_register_switch_link", context)
                                : translate(
                                    "register_login_switch_link", context),
                          )),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    if (_formType == AuthFormType.login) {
      return [
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: _emailController,
          decoration: InputDecoration(
              labelText: translate("login_email_label", context),
              border: OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => (value?.isEmpty ?? true)
              ? translate("login_email_validator", context)
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: _passwordController,
          decoration: InputDecoration(
              labelText: translate("login_password_label", context),
              border: OutlineInputBorder()),
          obscureText: true,
          validator: (value) => (value?.isEmpty ?? true)
              ? translate("login_password_validator", context)
              : null,
        ),
      ];
    } else if (_formType == AuthFormType.register) {
      return [
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: _emailController,
          decoration: InputDecoration(
              labelText: translate("register_email_label", context),
              border: OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => (value?.isEmpty ?? true)
              ? translate("register_email_validator", context)
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: _passwordController,
          decoration: InputDecoration(
              labelText: translate("register_password_label", context),
              border: OutlineInputBorder()),
          obscureText: true,
          validator: (value) => (value?.length ?? 0) < 8
              ? translate("register_password_validator", context)
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: _confirmPasswordController,
          decoration: InputDecoration(
              labelText: translate("register_reenter_password_label", context),
              border: OutlineInputBorder()),
          obscureText: true,
          validator: (value) => value != _passwordController.text
              ? translate("register_reenter_password_validator", context)
              : null,
        ),
      ];
    } else {
      // AuthFormType.confirm
      return [
        Text(
          translate("confirm_code_text", context),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: _confirmationCodeController,
          decoration: InputDecoration(
              labelText: translate("confirm_code_validator", context),
              border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          validator: (value) => (value?.isEmpty ?? true)
              ? translate("confirm_code_validator", context)
              : null,
        ),
      ];
    }
  }
}
