// ignore_for_file: unused_local_variable, use_build_context_synchronously, unused_element

import 'package:gofinder/models/user_model.dart';
import 'package:gofinder/services/auth.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart'; // Ensure this import is correct for your project

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _agreeToTerms = false;
  String errorMessage = "";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() async {
    String userName = userNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Validate password length
    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters long.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }

    if (_agreeToTerms) {
      // Call the register method from AuthServices
      AuthServices authServices = AuthServices();
      try {
        UserModel? userModel = await authServices.registerWithEmailAndPassword(
            email, password, userName);

        if (userModel != null) {
          // If registration is successful, navigate to the Sign_In page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Sign_In()),
          );
        }
      } catch (err) {
        // If an error occurred, display the Firebase error message
        setState(() {
          errorMessage = err.toString(); // Display the error message directly
        });
      }
    } else {
      setState(() {
        errorMessage = 'Please agree to the terms and conditions to proceed.';
      });
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

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
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
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 243, 243, 243),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 48),
                          Text(
                            "Create ",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          Text(
                            "Account",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildTextField(userNameController, "User Name"),
                  const SizedBox(height: 20),
                  _buildTextField(emailController, "Email"),
                  const SizedBox(height: 20),
                  _buildTextField(passwordController, "Password",
                      obscureText: _obscurePassword,
                      icon: _togglePasswordVisibility),
                  const SizedBox(height: 20),
                  _buildTextField(confirmPasswordController, "Confirm Password",
                      obscureText: _obscureConfirmPassword,
                      icon: _toggleConfirmPasswordVisibility),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value!;
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                      const Text("Agree to ",
                          style: TextStyle(
                              color: Color.fromARGB(255, 15, 15, 15))),
                      GestureDetector(
                        onTap: () {
                          // Handle Terms and Conditions click
                        },
                        child: const Text("Terms and Conditions",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Display the error message if there is one
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
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
                        onPressed: _register,
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Sign_In()),
                            );
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ),
                      ],
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, Function()? icon}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: icon != null
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: icon,
                color: Colors.grey,
              )
            : null,
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }
}
