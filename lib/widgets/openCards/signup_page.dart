import 'package:flutter/material.dart';
import 'package:deins_app/widgets/splash_screen.dart';
import 'login_page.dart';
import '../../auth/register.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPassController = TextEditingController();
  final TextEditingController _emailCodeController = TextEditingController();
  String _errorMessage = '';
  String _codeErrorMessage = '';

  Future<void> getEmailCode() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Email'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                    'Thank you for registering. You should receive an email shortly with a confirmation code.'),
                const Text('Please enter your email confirmation code below'),
                Material(
                    child: Form(
                  child: TextFormField(
                    controller: _emailCodeController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(labelText: 'Email Code'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your confirmation code';
                      }
                      return null;
                    },
                  ),
                )),
                Text(
                  _codeErrorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await emailConfirmUser(
                    _emailController.text,
                    _passwordController.text,
                    _emailCodeController.text,
                    context);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        height: MediaQuery.of(context).size.height - 50,
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 60.0),
                  const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Create your account",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  )
                ],
              ),
              Column(children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _reenterPassController,
                        style: TextStyle(color: Colors.black),
                        decoration:
                            InputDecoration(labelText: 'Reenter Password'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please reenter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Material(
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  String email = _emailController.text;
                                  String password = _passwordController.text;
                                  String reenter = _reenterPassController.text;
                                  if (reenter == password) {
                                    var confirm = await signUpUser(
                                        context, email, password);
                                    if (confirm == true) {
                                      await getEmailCode();
                                    } else {
                                      setState(() {
                                        _errorMessage =
                                            'Invalid username or password';
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _errorMessage = 'Passwords do not match.';
                                    });
                                  }
                                  setState(() {
                                    _errorMessage =
                                        'Invalid username or password';
                                  });
                                }
                              },
                              child: Text('Register'))),
                      SizedBox(height: 10),
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 10),
                      const Center(child: Text("Or")),
                      // Container(
                      //   height: 45,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(25),
                      //     border: Border.all(
                      //       color: Colors.black,
                      //     ),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.white.withOpacity(0.5),
                      //         spreadRadius: 1,
                      //         blurRadius: 1,
                      //         offset:
                      //             const Offset(0, 1), // changes position of shadow
                      //       ),
                      //     ],
                      //   ),
                      //   child: TextButton(
                      //     onPressed: () {},
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Container(
                      //           height: 30.0,
                      //           width: 30.0,
                      //           decoration: const BoxDecoration(
                      //             image: DecorationImage(
                      //                 image: AssetImage(
                      //                     'assets/images/login_signup/google.png'),
                      //                 fit: BoxFit.cover),
                      //             shape: BoxShape.circle,
                      //           ),
                      //         ),
                      //         const SizedBox(width: 18),
                      //         const Text(
                      //           "Sign In with Google",
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             color: Colors.purple,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Already have an account?"),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.blue),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ]),
            ]),
      )),
    );
  }
}
