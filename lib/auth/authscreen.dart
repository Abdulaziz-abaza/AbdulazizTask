import 'package:flutter/material.dart';
import '/auth/authform.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To Do Task"),
        centerTitle: true,
      ),
      body: Theme(
        data: ThemeData.dark(),
        child: AuthForm(),
      ),
    );
  }
}
