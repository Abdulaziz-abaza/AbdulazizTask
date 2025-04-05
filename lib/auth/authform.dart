import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:lottie/lottie.dart';

import 'package:mydo/core/notificationService.dart';
import 'package:mydo/cubit/task_cubit.dart';
import 'package:mydo/screens/home.dart';

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';
  bool isLoginPage = false;
  String? _errorText;
  bool isLoading = false;

  startAuthentication() {
    final formState = _formKey.currentState;
    if (formState != null) {
      final validity = formState.validate();
      FocusScope.of(context).unfocus();
      if (validity) {
        formState.save();
        setState(() {
          isLoading = true;
          _errorText = null;
        });
        submitForm(_email, _password, _username);
      }
    }
    NotificationService.sendNotificationToAll(
      "🎉 مرحبًا بك في التطبيق!",
      "تم إنشاء حسابك بنجاح! نحن متحمسون لوجودك معنا.",
    );
  }

  submitForm(String email, String password, String username) async {
    final auth = FirebaseAuth.instance;
    try {
      UserCredential authResult;

      if (isLoginPage) {
        NotificationService.sendNotificationToAll(
          "🎉 مرحبًا بك مره اخرى!",
          "تابع إنجاز مهامك!",
        );
        authResult = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        NotificationService.sendNotificationToAll(
          "🎉 مرحبًا بك مره اخرى!",
          "تابع إنجاز مهامك!",
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<TaskCubit>(
              create: (_) => TaskCubit(),
              child: Home(),
            ),
          ),
        );
      } else {
        try {
          authResult = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
            (route) => false,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider<TaskCubit>(
                create: (_) => TaskCubit(),
                child: Home(),
              ),
            ),
          );

          String? uid = authResult.user?.uid;
          String? token = await FirebaseMessaging.instance.getToken();

          if (token != null) {
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'username': username,
              'email': email,
              'fcmToken': token,
            });
          }
        } catch (e) {
          print("  Error during user creation: $e");
          setState(() {
            _errorText = e.toString().split("]")[1].trim();
          });
          isLoading = false;
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      print("  Firebase Authentication Error: ${e.message}");
      setState(() {
        _errorText = 'Invalid Email or Password!';
      });
    } catch (e) {
      print(" Unexpected error: $e");
    } finally {
      isLoading = false;
    }
  }

  Future<String> getAccessToken() async {
    final jsonString = await rootBundle.loadString(
        'assets/chatmodule-ac96c-firebase-adminsdk-92f4m-34eb1d1107.json');
    final jsonData = jsonDecode(jsonString);

    final credentials = auth.ServiceAccountCredentials.fromJson(jsonData);
    final client = await auth.clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );

    return client.credentials.accessToken.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //     isLoginPage
                //         ? 'Login to continue managing your tasks '
                //         : 'Please create an account first to be able to create tasks',
                //     style: GoogleFonts.poppins(
                //       color: Colors.white,
                //       fontSize: 20,
                //       fontWeight: FontWeight.bold,
                //     )),
                Lottie.asset("assets/regtodo.json"),
                // Image.asset('assets/todo.png', height: 160),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!isLoginPage)
                        buildTextField('username', 'Enter Username'),
                      buildTextField('email', 'Enter Email'),
                      buildTextField('password', 'Enter Password',
                          isPassword: true),
                      if (_errorText != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _errorText!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 10),
                      buildSubmitButton(),
                      SizedBox(height: 10),
                      buildSwitchAuthButton(),
                    ],
                  ),
                ),
                if (isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String key, String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        key: ValueKey(key),
        obscureText: isPassword,
        validator: (value) => value!.isEmpty ? '$label is required' : null,
        onSaved: (value) {
          if (key == 'email') _email = value!;
          if (key == 'password') _password = value!;
          if (key == 'username') _username = value!;
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(),
          ),
          labelText: label,
          labelStyle: GoogleFonts.roboto(color: Colors.white),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        child: Text(isLoginPage ? 'Login' : 'SignUp',
            style: TextStyle(fontSize: 16)),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
          backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
        ),
        onPressed: () {
          setState(() => _errorText = null);
          startAuthentication();
        },
      ),
    );
  }

  Widget buildSwitchAuthButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLoginPage = !isLoginPage;
          _errorText = null;
        });
      },
      child: Text(
        isLoginPage ? 'Not a member?' : 'Already a Member?',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
