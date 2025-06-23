import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/localization_helper.dart';
import '../../models/app_auth_provider.dart';
import '../../widgets/splash_screen.dart';
import 'package:crypto/crypto.dart';

String encryptPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

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
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);
    setState(() {
      _formType = (_formType == AuthFormType.login)
          ? AuthFormType.register
          : AuthFormType.login;
    });
  }

  Future<void> _submit() async {
    setState(() => _uiErrorMessage = '');
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final hashPass = encryptPassword(password);
      final customAttributes = {
        'passwordHashed': hashPass,
        'appUsername': 'test',
      };
      bool success = false;

      if (_formType == AuthFormType.login) {
        success = await authProvider.signIn(email, password);
      } else if (_formType == AuthFormType.register) {
        success = await authProvider.signUp(
            email: email,
            password: password,
            customAttributes: customAttributes);
        if (success) {
          setState(() {
            _formType = AuthFormType.confirm;
            _isSubmitting = false;
          });
          return;
        }
      } else if (_formType == AuthFormType.confirm) {
        final code = _confirmationCodeController.text.trim();
        success = await authProvider.confirmSignUp(
            email: email, confirmationCode: code);
        if (success) {
          success =
              await authProvider.signIn(email, password, isRegister: true);
        }
      }

      // --- CORRECTED NAVIGATION ---
      // If any step resulted in a successful authentication, navigate to the
      // SplashScreen. It will handle the rest of the logic.
      if (mounted && success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
        return;
      }

      // If we reach here, a step failed. Reset the submitting state.
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final providerErrorMessage = authProvider.errorMessage;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.fromARGB(255, 214, 34, 112),
                Color.fromARGB(255, 150, 21, 141),
                Color(0xff333333),
              ],
              center: Alignment.topCenter,
              radius: 0.7,
            ),
          ),
          child: Column(children: [
            Padding(
                padding: EdgeInsets.only(
                    top: 200.0, bottom: 50.0, left: 40.0, right: 40.0),
                child: SizedBox(
                    child: Image.asset('assets/images/deins_logo.png'))),
            SingleChildScrollView(
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
                    ..._buildFormFields(),
                    const SizedBox(height: 20),
                    if (providerErrorMessage != null ||
                        _uiErrorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          providerErrorMessage ?? _uiErrorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                    if (_formType != AuthFormType.confirm)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formType == AuthFormType.login
                                ? translate(
                                    "login_register_switch_text", context)
                                : translate(
                                    "register_login_switch_text", context),
                            style: const TextStyle(color: Colors.white),
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
          ])),
    );
  }

  List<Widget> _buildFormFields() {
    // This logic remains the same as your version.
    if (_formType == AuthFormType.login) {
      return [
        TextFormField(
          style: const TextStyle(color: Colors.white),
          controller: _emailController,
          decoration: InputDecoration(
              labelText: translate("login_email_label", context),
              border: const OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => (value?.isEmpty ?? true)
              ? translate("login_email_validator", context)
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          controller: _passwordController,
          decoration: InputDecoration(
              labelText: translate("login_password_label", context),
              border: const OutlineInputBorder()),
          obscureText: true,
          validator: (value) => (value?.isEmpty ?? true)
              ? translate("login_password_validator", context)
              : null,
        ),
      ];
    } else if (_formType == AuthFormType.register) {
      return [
        TextFormField(
          style: const TextStyle(color: Colors.white),
          controller: _emailController,
          decoration: InputDecoration(
              labelText: translate("register_email_label", context),
              border: const OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => (value?.isEmpty ?? true)
              ? translate("register_email_validator", context)
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          controller: _passwordController,
          decoration: InputDecoration(
              labelText: translate("register_password_label", context),
              border: const OutlineInputBorder()),
          obscureText: true,
          validator: (value) => (value?.length ?? 0) < 8
              ? translate("register_password_validator", context)
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          controller: _confirmPasswordController,
          decoration: InputDecoration(
              labelText: translate("register_reenter_password_label", context),
              border: const OutlineInputBorder()),
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
          style: const TextStyle(color: Colors.white),
          controller: _confirmationCodeController,
          decoration: const InputDecoration(
              labelText: "code", border: OutlineInputBorder()),
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
