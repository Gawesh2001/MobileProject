// ignore_for_file: prefer_const_constructors, unused_import

import 'package:gofinder/screnns/authentication/register.dart';
import 'package:gofinder/screnns/authentication/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Sign_In();
  }
}
