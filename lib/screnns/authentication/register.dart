// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gofinder/models/user_model.dart';
import 'package:gofinder/screnns/authentication/sign_in.dart';
import 'package:gofinder/services/auth.dart';
import 'package:gofinder/screnns/authentication/sign_in.dart';

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
  String _selectedRole = 'worker'; // Default role selection

  // Function to register user
  void _register() async {
    String userName = userNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

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

    if (!_agreeToTerms) {
      setState(() {
        errorMessage = 'Please agree to the terms and conditions.';
      });
      return;
    }

    AuthServices authServices = AuthServices();
    try {
      UserModel? userModel = await authServices.registerWithEmailAndPassword(
          email, password, userName);

      if (userModel != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userModel.uid)
            .set({
          "userName": userName,
          "email": email,
          "role": _selectedRole,
          "createdAt": FieldValue.serverTimestamp(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Sign_In()),
        );
      }
    } catch (err) {
      setState(() {
        errorMessage = err.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
      });
    }
  }

  // Function to toggle password visibility
  void _togglePasswordVisibility(bool isConfirm) {
    setState(() {
      if (isConfirm) {
        _obscureConfirmPassword = !_obscureConfirmPassword;
      } else {
        _obscurePassword = !_obscurePassword;
      }
    });
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
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(75)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 48),
                          Text("Create ",
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text("Account",
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
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
                      icon: () => _togglePasswordVisibility(false)),
                  const SizedBox(height: 20),
                  _buildTextField(confirmPasswordController, "Confirm Password",
                      obscureText: _obscureConfirmPassword,
                      icon: () => _togglePasswordVisibility(true)),
                  const SizedBox(height: 20),

                  // Role Selection Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                    items: ["worker", "customer"]
                        .map((role) =>
                            DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: "Select Role",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Terms & Conditions
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
                          style: TextStyle(color: Colors.black)),
                      GestureDetector(
                        onTap: () {},
                        child: const Text("Terms and Conditions",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (errorMessage.isNotEmpty)
                    Text(errorMessage,
                        style: const TextStyle(color: Colors.red)),

                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 285,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0079C2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _register,
                        child: const Text("Register",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Navigate to Sign In
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Sign_In()),
                            );
                          },
                          child: const Text("Sign In",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.blue)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: icon != null
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: icon)
            : null,
      ),
    );
  }
}
