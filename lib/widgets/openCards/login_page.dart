import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/localization_helper.dart';
import '../../models/app_auth_provider.dart';
import '../../widgets/splash_screen.dart';
import 'package:crypto/crypto.dart';
import 'dart:io' show Platform;

String encryptPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

enum AuthFormType {
  loginInitial,
  loginWithPassword,
  loginWithEmailCode,
  register,
  confirm,
  forgotPassword,
  resetPassword
}

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
  final TextEditingController _loginCodeController = TextEditingController();

  var _formType = AuthFormType.loginInitial;
  bool _isSubmitting = false;
  String _uiErrorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _loginCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSubmitting = true);
    await Provider.of<AppAuthProvider>(context, listen: false)
        .launchSignInWithProvider('Google');
    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isSubmitting = true);
    await Provider.of<AppAuthProvider>(context, listen: false)
        .launchSignInWithProvider('Apple');
    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<bool> _showCancelConfirmationDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate("login_page_dialog_canceltitle", context)),
        content: Text(translate("login_page_dialog_cancelbody", context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(translate("login_page_dialog_staybutton", context)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(translate("login_page_dialog_gobackbutton", context),
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _handleBackPress() async {
    final bool confirmed = await _showCancelConfirmationDialog();
    if (confirmed && mounted) {
      Provider.of<AppAuthProvider>(context, listen: false)
          .setErrorMessage(null);
      setState(() {
        _formKey.currentState?.reset();
        _clearControllers();
        _uiErrorMessage = '';
        _formType = AuthFormType.loginInitial;
      });
    }
  }

  void _clearControllers() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _loginCodeController.clear();
  }

  void _switchFormType() {
    _formKey.currentState?.reset();
    _clearControllers();
    _uiErrorMessage = '';
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);
    setState(() {
      _formType = (_formType == AuthFormType.register)
          ? AuthFormType.loginInitial
          : AuthFormType.register;
    });
  }

  Future<void> _submit() async {
    setState(() => _uiErrorMessage = '');
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _uiErrorMessage = translate("login_page_submit_formerror", context);
      });
      return;
    }

    if (_formType == AuthFormType.register &&
        _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        // Set the specific "Passwords do not match" error and stop.
        _uiErrorMessage =
            translate("register_reenter_password_validator", context);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool success = false;
    bool shouldNavigateToSplash = false;

    try {
      switch (_formType) {
        case AuthFormType.loginWithPassword:
          success = await authProvider.signIn(email, password);
          if (success) {
            shouldNavigateToSplash = true;
          }
          break;

        case AuthFormType.loginWithEmailCode:
          success = await authProvider
              .answerEmailCodeChallenge(_loginCodeController.text.trim());
          if (success) {
            shouldNavigateToSplash = true;
          }
          break;

        case AuthFormType.register:
          final String result = await authProvider.signUp(
            email: email,
            password: password,
            customAttributes: {
              'passwordHashed': encryptPassword(password),
              'appUsername': 'test'
            },
          );
          if (result == 'success' && mounted) {
            // On success, we don't navigate yet, just change the form.
            _formType = AuthFormType.confirm;
          } else if (result == 'UsernameExistsException' && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(translate("login_page_submit_emailexists", context)),
                backgroundColor: Colors.orange,
              ),
            );
            _formType = AuthFormType.loginInitial;
            _passwordController.clear();
            _confirmPasswordController.clear();
          }
          // For other errors, the provider has already notified listeners.
          break;

        case AuthFormType.confirm:
          success = await authProvider.confirmSignUp(
              email: email, confirmationCode: _loginCodeController.text.trim());
          if (success) {
            success =
                await authProvider.signIn(email, password, isRegister: true);
            if (success) {
              shouldNavigateToSplash = true;
            }
          }
          break;
        default:
          break;
      }
    } finally {
      // MODIFICATION: This `finally` block ensures that no matter what happens
      // (success or failure), the loading spinner is turned off.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    if (shouldNavigateToSplash && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    }
  }

  Future<void> _handleEmailLoginRequest() async {
    setState(() => _uiErrorMessage = '');
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _uiErrorMessage =
            translate("login_page_emailreq_invalidemail", context);
      });
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success =
        await authProvider.initiateEmailLogin(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _formType = AuthFormType.loginWithEmailCode;
        _isSubmitting = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    setState(() => _uiErrorMessage = '');
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _uiErrorMessage =
            translate("login_page_emailreq_invalidemail", context);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success =
        await authProvider.forgotPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _formType = AuthFormType.resetPassword;
        _isSubmitting = false;
        _passwordController.clear();
        _confirmPasswordController.clear();
        _loginCodeController.clear();
      });
    } else if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleResetPassword() async {
    setState(() => _uiErrorMessage = '');
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _uiErrorMessage = translate("login_page_submit_formerror", context);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success = await authProvider.confirmForgotPassword(
      email: _emailController.text.trim(),
      confirmationCode: _loginCodeController.text.trim(),
      newPassword: _passwordController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate("login_page_reset_success", context)),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _formKey.currentState?.reset();
        _clearControllers();
        _uiErrorMessage = '';
        _formType = AuthFormType.loginInitial;
        _isSubmitting = false;
      });
    } else if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final String? errorKey = authProvider.errorMessage;
    String? displayError;
    final bool showBackButton = _formType != AuthFormType.loginInitial &&
        _formType != AuthFormType.register;
    if (errorKey != null) {
      // If an error key exists in the provider, translate it.
      displayError = translate(errorKey, context);
    } else if (_uiErrorMessage.isNotEmpty) {
      // Otherwise, use the local error message for form validation.
      displayError = _uiErrorMessage;
    }
    return PopScope(
      canPop: !showBackButton,
      onPopInvokedWithResult: (bool didPop, dynamic _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _handleBackPress,
                    )
                  : null,
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.only(
                        top: 100.0, bottom: 50.0, left: 40.0, right: 40.0),
                    child: SizedBox(
                        child: Image.asset('assets/images/deins_logo.png'))),
                Padding(
                  padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0,
                      MediaQuery.of(context).viewInsets.bottom),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _getHeaderText(context),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        ..._buildFormFields(),
                        const SizedBox(height: 20),
                        if (displayError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              displayError,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ..._buildActionButtons(),
                        const SizedBox(height: 20),
                        if (_formType == AuthFormType.loginInitial ||
                            _formType == AuthFormType.loginWithPassword ||
                            _formType == AuthFormType.loginWithEmailCode)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  translate(
                                      "login_register_switch_text", context),
                                  style: TextStyle(color: Colors.white)),
                              TextButton(
                                  onPressed:
                                      _isSubmitting ? null : _switchFormType,
                                  child: Text(translate(
                                      "register_button_label", context))),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, endIndent: 10)),
        Text(translate("signup_page_form_ordivider", context),
            style: TextStyle(color: Colors.white70)),
        const Expanded(child: Divider(thickness: 1, indent: 10)),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: Image.asset('assets/images/google_logo.png', height: 24.0),
          label: Text(translate("login_page_build_googlebutton", context)),
          onPressed: _isSubmitting ? null : _handleGoogleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (Platform.isIOS)
          ElevatedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.white),
            label: Text(translate("login_page_build_applebutton", context)),
            onPressed: _isSubmitting ? null : _handleAppleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  String _getHeaderText(BuildContext context) {
    switch (_formType) {
      case AuthFormType.loginInitial:
      case AuthFormType.loginWithPassword:
        return translate('login_header', context);
      case AuthFormType.register:
        return translate('register_header', context);
      case AuthFormType.loginWithEmailCode:
      case AuthFormType.confirm:
        return translate('confirm_code_header', context);
      case AuthFormType.forgotPassword:
        return translate("login_page_header_forgotpassword", context);
      case AuthFormType.resetPassword:
        return translate("login_page_header_resetpassword", context);
    }
  }

  List<Widget> _buildActionButtons() {
    if (_isSubmitting) {
      return [const Center(child: CircularProgressIndicator())];
    }
    switch (_formType) {
      case AuthFormType.loginInitial:
        return [
          ElevatedButton(
            onPressed: _handleEmailLoginRequest,
            child: Text(translate("login_page_actions_loginemail", context)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() => _formType = AuthFormType.loginWithPassword);
            },
            child: Text(translate("login_page_actions_loginpass", context),
                style: TextStyle(
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                )),
          ),
        ];
      case AuthFormType.loginWithPassword:
        return [
          ElevatedButton(
              onPressed: _submit,
              child:
                  Text(translate("login_page_actions_loginbutton", context))),
          TextButton(
            onPressed: () {
              setState(() => _formType = AuthFormType.loginInitial);
            },
            child: Text(translate("login_page_actions_loginemail", context),
                style: TextStyle(
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                )),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _formKey.currentState?.reset();
                _uiErrorMessage = '';
                _formType = AuthFormType.forgotPassword;
              });
            },
            child: Text(translate("login_page_header_forgotpassword", context),
                style: TextStyle(
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                )),
          ),
        ];
      case AuthFormType.loginWithEmailCode:
      case AuthFormType.confirm:
        return [
          ElevatedButton(
              onPressed: _submit,
              child: Text(translate("login_page_actions_confirmcode", context)))
        ];
      case AuthFormType.register:
        return [
          ElevatedButton(
              onPressed: _submit,
              child: Text(translate("register_button_label", context))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(translate("register_login_switch_text", context),
                  style: TextStyle(color: Colors.white)),
              TextButton(
                  onPressed: _isSubmitting ? null : _switchFormType,
                  child: Text(translate("register_button_label", context))),
            ],
          )
        ];
      case AuthFormType.forgotPassword:
        return [
          ElevatedButton(
              onPressed: _handleForgotPassword,
              child: Text(translate("onboarding_form_submitbutton", context)))
        ];
      case AuthFormType.resetPassword:
        return [
          ElevatedButton(
              onPressed: _handleResetPassword,
              child: Text(
                translate("confirm_code_button", context),
              ))
        ];
    }
  }

  List<Widget> _buildFormFields() {
    switch (_formType) {
      case AuthFormType.loginInitial:
        return [
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: translate("login_email_label", context),
                border: const OutlineInputBorder()),
            validator: (v) => (v?.isEmpty ?? true)
                ? translate("login_page_fields_emailvalidator", context)
                : null,
          ),
        ];
      case AuthFormType.loginWithPassword:
        return [
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: translate("login_email_label", context),
                border: const OutlineInputBorder()),
            validator: (v) => (v?.isEmpty ?? true)
                ? translate("login_page_fields_emailvalidator", context)
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: translate("login_password_label", context),
                border: const OutlineInputBorder()),
            obscureText: true,
            validator: (v) => (v?.isEmpty ?? true)
                ? translate("login_page_fields_passvalidator", context)
                : null,
          ),
        ];
      case AuthFormType.loginWithEmailCode:
      case AuthFormType.confirm:
        return [
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.grey),
            decoration: InputDecoration(
                labelText: translate("login_page_fields_emaillabel", context),
                border: OutlineInputBorder()),
            enabled: false,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _loginCodeController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: _formType == AuthFormType.loginWithEmailCode
                    ? translate("login_page_fields_logincodelabel", context)
                    : translate("login_page_fields_confirmcodelabel", context),
                border: const OutlineInputBorder()),
            validator: (v) => (v?.isEmpty ?? true)
                ? translate("login_page_fields_codevalidator", context)
                : null,
          ),
        ];
      case AuthFormType.register:
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
                labelText:
                    translate("register_reenter_password_label", context),
                border: const OutlineInputBorder()),
            obscureText: true,
            validator: (value) => (value?.isEmpty ?? true)
                ? translate("register_reenter_password_validator", context)
                : null,
          ),
        ];
      case AuthFormType.forgotPassword:
        return [
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              translate("login_page_fields_forgotpassbody", context),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: translate("login_page_fields_emaillabel", context),
                border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v?.isEmpty ?? true)
                ? translate("login_page_fields_emailvalidator", context)
                : null,
          ),
        ];
      case AuthFormType.resetPassword:
        return [
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              translate("login_page_fields_resetpassbody", context),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          TextFormField(
            controller: _loginCodeController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: translate("login_page_fields_codelabel", context),
                border: OutlineInputBorder()),
            validator: (v) => (v?.isEmpty ?? true)
                ? translate("login_page_fields_codevalidator", context)
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: translate("login_page_fields_newpasslabel", context),
                border: OutlineInputBorder()),
            obscureText: true,
            validator: (v) => (v?.length ?? 0) < 8
                ? translate("login_page_fields_passlengthvalidator", context)
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText:
                    translate("login_page_fields_confirmpasslabel", context),
                border: const OutlineInputBorder()),
            obscureText: true,
            validator: (v) => v != _passwordController.text
                ? translate("login_page_fields_passmismatch", context)
                : null,
          ),
        ];
    }
  }
}
