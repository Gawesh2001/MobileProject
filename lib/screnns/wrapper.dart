// ignore_for_file: prefer_const_constructors, unused_import

import 'package:gofinder/models/user_model.dart';
import 'package:gofinder/screnns/authentication/authenticate.dart';
import 'package:gofinder/screnns/home/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
