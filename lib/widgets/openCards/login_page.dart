import 'package:flutter/material.dart';
import '../../auth/authenticate.dart';
import '../../main.dart';
import 'signup_page.dart';
import '../../api/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
            color: Colors.white, fontFamily: 'ChakraPetch', fontSize: 20),
      ),
      body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(children: [
            Image.asset(
              'assets/images/deins_logo.png',
              height: 200,
              width: 200,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final navigator = Navigator.of(context);
                          String username = _usernameController.text;
                          String password = _passwordController.text;
                          var confirm =
                              await authenticateUser(username, password, false);
                          if (confirm == true) {
                            final user = await getUserByEmail(username);
                            final prefs = await SharedPreferences.getInstance();
                            if (user != null) {
                              final userId = user['userId'].toString();
                              prefs.setString('userId', userId);
                            }
                            navigator.push(MaterialPageRoute(
                                builder: (context) => MyHomePage(
                                    title: 'Kloppocar App Home',
                                    qrcode: 'Scan a Collectible!')));
                          }
                        } else {
                          setState(() {
                            _errorMessage = 'Invalid username or password';
                          });
                        }
                        setState(() {
                          _errorMessage = 'Invalid username or password';
                        });
                      },
                      child: Text('Login')),
                  SizedBox(height: 10),
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'ChakraPetch',
                              fontSize: 15)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupPage()));
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ])),
    );
  }
}
