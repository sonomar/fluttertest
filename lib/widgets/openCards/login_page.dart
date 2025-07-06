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
        title: const Text('Cancel Process?'),
        content: const Text(
            'Are you sure? This will cancel the current process and take you back to the main login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Go Back', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _handleBackPress() async {
    final bool confirmed = await _showCancelConfirmationDialog();
    if (confirmed && mounted) {
      Provider.of<AppAuthProvider>(context, listen: false).clearErrorMessage();
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
    // Clear previous errors first
    setState(() => _uiErrorMessage = '');
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);

    // Validate the form
    if (!(_formKey.currentState?.validate() ?? false)) {
      // If validation fails, set the UI error message and stop
      setState(() {
        _uiErrorMessage = 'Please correct the errors shown below.';
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

    switch (_formType) {
      case AuthFormType.loginWithPassword:
        success = await authProvider.signIn(email, password);
        if (success) {
          shouldNavigateToSplash = true;
        } else {
          setState(() {
            _uiErrorMessage =
                authProvider.errorMessage ?? 'Incorrect email or password.';
            _isSubmitting = false;
          });
          return;
        }
        break;
      case AuthFormType.loginWithEmailCode:
        success = await authProvider
            .answerEmailCodeChallenge(_loginCodeController.text.trim());
        if (success) {
          shouldNavigateToSplash = true;
        } else {
          // FIX: Apply the same pattern here.
          setState(() {
            _uiErrorMessage = authProvider.errorMessage ??
                'The code provided is incorrect or has expired.';
            _isSubmitting = false;
          });
          return;
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
          setState(() {
            _formType = AuthFormType.confirm;
            _isSubmitting = false;
          });
          return;
        }
        if (result == 'UsernameExistsException' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email is already registered. Please log in.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _formType = AuthFormType.loginInitial;
            _isSubmitting = false;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
          return;
        }
        // Handle generic registration failure
        setState(() {
          _uiErrorMessage = authProvider.errorMessage ??
              'An unknown registration error occurred.';
          _isSubmitting = false;
        });
        return;
      case AuthFormType.confirm:
        success = await authProvider.confirmSignUp(
            email: email, confirmationCode: _loginCodeController.text.trim());
        if (success) {
          success =
              await authProvider.signIn(email, password, isRegister: true);
          if (success) {
            shouldNavigateToSplash = true;
          } else {
            // FIX: Handle failure after confirmation but before sign-in
            setState(() {
              _uiErrorMessage = authProvider.errorMessage ??
                  'Sign in after confirmation failed.';
              _isSubmitting = false;
            });
            return;
          }
        } else {
          // FIX: Handle confirmation code failure
          setState(() {
            _uiErrorMessage =
                authProvider.errorMessage ?? 'Incorrect confirmation code.';
            _isSubmitting = false;
          });
          return;
        }
        break;
      default:
        break;
    }

    if (shouldNavigateToSplash && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
      return;
    }
  }

  Future<void> _handleEmailLoginRequest() async {
    setState(() => _uiErrorMessage = '');
    Provider.of<AppAuthProvider>(context, listen: false).setErrorMessage(null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _uiErrorMessage = 'Please enter a valid email address.';
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
      // On failure, the provider will have the error message.
      // We just need to stop the loading indicator and trigger a rebuild.
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
        _uiErrorMessage = 'Please enter a valid email address.';
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
        _uiErrorMessage = 'Please correct the errors shown below.';
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
        const SnackBar(
          content: Text('Your password has been successfully reset.'),
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
    final providerErrorMessage = authProvider.errorMessage;
    final bool showBackButton = _formType != AuthFormType.loginInitial &&
        _formType != AuthFormType.register;
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
                        if (providerErrorMessage != null ||
                            _uiErrorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              providerErrorMessage ?? _uiErrorMessage,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ..._buildActionButtons(),
                        // const SizedBox(height: 12),
                        // _buildSocialLoginDivider(),
                        // const SizedBox(height: 12),
                        // _buildSocialLoginButtons(),
                        const SizedBox(height: 20),
                        if (_formType == AuthFormType.loginInitial ||
                            _formType == AuthFormType.loginWithPassword ||
                            _formType == AuthFormType.loginWithEmailCode)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?",
                                  style: TextStyle(color: Colors.white)),
                              TextButton(
                                  onPressed:
                                      _isSubmitting ? null : _switchFormType,
                                  child: const Text("Register")),
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

  // NEW WIDGET: A divider for the social logins
  Widget _buildSocialLoginDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(thickness: 1, endIndent: 10)),
        Text("OR", style: TextStyle(color: Colors.white70)),
        Expanded(child: Divider(thickness: 1, indent: 10)),
      ],
    );
  }

  // NEW WIDGET: Builds the social login buttons
  Widget _buildSocialLoginButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: Image.asset('assets/images/google_logo.png', height: 24.0),
          label: const Text('Sign in with Google'),
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
            label: const Text('Sign in with Apple'),
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
        return 'Forgot Your Password?';
      case AuthFormType.resetPassword:
        return 'Reset Your Password';
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
            child: const Text('Log in with Email'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() => _formType = AuthFormType.loginWithPassword);
            },
            child: const Text('Log in with Password',
                style: TextStyle(
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                )),
          ),
        ];
      case AuthFormType.loginWithPassword:
        return [
          ElevatedButton(onPressed: _submit, child: const Text("Log In")),
          TextButton(
            onPressed: () {
              setState(() => _formType = AuthFormType.loginInitial);
            },
            child: const Text('Log in with Email',
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
            child: const Text('Forgot Your Password?',
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
          ElevatedButton(onPressed: _submit, child: const Text("Confirm Code"))
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
            validator: (v) =>
                (v?.isEmpty ?? true) ? 'Please enter your email' : null,
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
            validator: (v) =>
                (v?.isEmpty ?? true) ? 'Please enter your email' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: translate("login_password_label", context),
                border: const OutlineInputBorder()),
            obscureText: true,
            validator: (v) =>
                (v?.isEmpty ?? true) ? 'Please enter your password' : null,
          ),
        ];
      case AuthFormType.loginWithEmailCode:
      case AuthFormType.confirm:
        return [
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.grey),
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
            enabled: false,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _loginCodeController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: _formType == AuthFormType.loginWithEmailCode
                    ? 'Login Code'
                    : 'Confirmation Code',
                border: const OutlineInputBorder()),
            validator: (v) => (v?.isEmpty ?? true)
                ? 'Please enter the code from your email'
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
            validator: (value) => value != _passwordController.text
                ? translate("register_reenter_password_validator", context)
                : null,
          ),
        ];
      case AuthFormType.forgotPassword:
        return [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Enter your email below to receive a code to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v?.isEmpty ?? true) ? 'Please enter your email' : null,
          ),
        ];
      case AuthFormType.resetPassword:
        return [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Please enter the code from your email below and enter your new password twice to add your new password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          TextFormField(
            controller: _loginCodeController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Code', border: OutlineInputBorder()),
            validator: (v) => (v?.isEmpty ?? true)
                ? 'Please enter the code from your email'
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'New Password', border: OutlineInputBorder()),
            obscureText: true,
            validator: (v) => (v?.length ?? 0) < 8
                ? 'Password must be at least 8 characters'
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder()),
            obscureText: true,
            validator: (v) =>
                v != _passwordController.text ? 'Passwords do not match' : null,
          ),
        ];
    }
  }
}
