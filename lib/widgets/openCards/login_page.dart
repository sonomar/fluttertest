import 'package:flutter/material.dart';
import 'package:kloppocar_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../../models/app_auth_provider.dart';
import '../../main.dart';
import 'signup_page.dart';
import '../../api/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final navigator = Navigator.of(context);

    // Basic validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
        _isLoading = false;
      });
      return;
    }

    try {
      final appAuthProvider = context.read<AppAuthProvider>();

      final bool success = await appAuthProvider.signIn(email, password);

      if (success) {
        print('Login successful!');
        navigator.push(MaterialPageRoute(
            builder: (context) => MyHomePage(
                title: 'Kloppocar App Home', qrcode: 'Scan a Collectible!')));
      } else {
        setState(() {
          _errorMessage =
              appAuthProvider.errorMessage ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
      print('Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Page background is black
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white), // App bar title is white
        ),
        centerTitle: true,
        backgroundColor: Colors.black, // App bar background is black
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensures back button/menu icons are white
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Image Logo ---
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/deins_logo.png', // Update this path to your logo!
                  height: 120, // Adjust height as needed
                  width: 120, // Adjust width as needed
                ),
              ),
              const SizedBox(height: 32.0), // Space after the logo

              TextField(
                controller: _emailController,
                style:
                    const TextStyle(color: Colors.white), // Input text is white
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white), // Label is white
                  enabledBorder: OutlineInputBorder(
                    // Border when not focused
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Border when focused
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  prefixIcon:
                      Icon(Icons.email, color: Colors.white), // Icon is white
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                style:
                    const TextStyle(color: Colors.white), // Input text is white
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white), // Label is white
                  enabledBorder: OutlineInputBorder(
                    // Border when not focused
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Border when focused
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  prefixIcon:
                      Icon(Icons.lock, color: Colors.white), // Icon is white
                ),
                obscureText: true, // Hide password input
              ),
              const SizedBox(height: 24.0),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14.0), // Error message is still red
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button background is white
                  foregroundColor: Colors.black, // Button text color is black
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black), // Spinner is black
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 24.0),

              // --- "Not registered? Sign up here" section ---
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupPage()));
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    // Changed to const as all children are const
                    text: "Not registered? ",
                    style: TextStyle(
                      color:
                          Colors.white70, // Slightly faded white for main text
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: "Sign up here",
                        style: TextStyle(
                          color: Colors.white, // Pure white for the link
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
