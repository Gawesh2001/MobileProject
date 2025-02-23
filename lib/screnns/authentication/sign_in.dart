// ignore_for_file: camel_case_types, avoid_print, use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../services/auth.dart';
import 'register.dart'; // Import the Register page
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gofinder/screnns/home/home.dart';

class Sign_In extends StatefulWidget {
  const Sign_In({super.key});

  @override
  State<Sign_In> createState() => _Sign_InState();
}

class _Sign_InState extends State<Sign_In> {
  final AuthServices _auth = AuthServices();

  String email = '';
  String password = '';
  bool _passwordVisible = false; // Manage visibility of password

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        email = prefs.getString('email') ?? '';
        password = prefs.getString('password') ?? '';
        _emailController.text = email;
        _passwordController.text = password;
      }
    });
  }

  // Function to validate and perform login
  Future<void> _login() async {
    if (email.isEmpty || password.isEmpty) {
      _showDialog('Email and Password cannot be empty.');
      return;
    }

    if (password.length < 6) {
      _showDialog('Password must be at least 6 characters long.');
      return;
    }

    //Save & Clear Credentials Functions
    Future<void> saveCredentials() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    }

    Future<void> clearSavedCredentials() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', false);
      await prefs.remove('email');
      await prefs.remove('password');
    }

    // Call your sign-in function here
    dynamic result = await _auth.signInWithEmailAndPassword(email, password);

    if (result == null) {
      _showDialog('Login failed. Please check your credentials.');
    } else {
      if (_rememberMe) {
        saveCredentials();
      } else {
        clearSavedCredentials();
      }
      // Navigate to the Home page after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  // Function to reset the password
  void _forgotPassword() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Enter your email',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  await _auth.resetPassword(emailController.text);
                  Navigator.of(context).pop();
                  _showDialog(
                      'A password reset link has been sent to your email.');
                } else {
                  _showDialog('Please enter a valid email.');
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Function to handle Google sign-in
  Future<void> _signInWithGoogle() async {
    dynamic result = await _auth.signInWithGoogle();
    if (result == null) {
      _showDialog('Google sign-in failed.');
    } else {
      // Navigate to the Home page after successful Google sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _rememberMe = false; // To track the checkbox state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xff0060D0),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(75),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    Container(
                      padding: const EdgeInsets.only(left: 0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color.fromARGB(255, 250, 248, 247)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 30),
                            Text(
                              "Welcome ",
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 250, 249, 249),
                              ),
                            ),
                            Text(
                              "Back",
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 250, 249, 249),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  TextField(
                    controller: _emailController,
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    style: const TextStyle(color: Color.fromARGB(255, 2, 2, 2)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    onChanged: (value) {
                      password = value;
                    },
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle:
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _forgotPassword,
                      child: const Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 88, 139),
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        activeColor: const Color.fromARGB(255, 8, 8, 8),
                      ),
                      const Text(
                        'Remember me',
                        style: TextStyle(color: Color.fromARGB(255, 2, 2, 2)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 90),
                  Center(
                    child: SizedBox(
                      width: 285,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0079C2),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                        onPressed: _login,
                        child: const Text(
                          'Log in',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Sign Up with Google',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 33, 88, 139),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _signInWithGoogle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't Have An Account? ",
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 33, 88, 139),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Register(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () async {
                          dynamic result = await _auth.signInAnonymouse();
                          if (result == null) {
                            print("Error in sign-in: User is null");
                          } else {
                            print("Signed in successfully");
                            print("User ID is: ${result.uid}");
                            // Navigate to the Home page after successful sign-in
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }
                        },
                        child: const Center(
                          child: Text(
                            'Login as Guest',
                            style: TextStyle(
                              color: Color.fromARGB(255, 33, 88, 139),
                              //decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
