import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:io';

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

Future<void> sendWelcomeNotification(String token, String username) async {
  final String serverKey = "34eb1d1107a84d5b0e7f9b05576c0d1ff04823cf";

  final String fcmUrl = "https://fcm.googleapis.com/fcm/send";

  final Map<String, dynamic> message = {
    "to": token,
    "notification": {
      "title": "Welcome to Taskify!",
      "body": "Hello $username, thank you for signing up!",
    },
  };

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "key=$serverKey",
    },
    body: jsonEncode(message),
  );

  if (response.statusCode == 200) {
    print("✅ Welcome notification sent successfully!");
  } else {
    print("❌ Failed to send welcome notification: ${response.statusCode}");
    print("🔴 Error: ${response.body}");
  }
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
  }

  submitForm(String email, String password, String username) async {
    final auth = FirebaseAuth.instance;
    try {
      UserCredential authResult;

      if (isLoginPage) {
        authResult = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        try {
          authResult = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          String? uid = authResult.user?.uid;
          String? token = await FirebaseMessaging.instance.getToken();

          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'username': username,
            'email': email,
            'fcmToken': token, // حفظ توكن الإشعارات في Firestore
          });

          // إرسال الإشعار الترحيبي
          if (token != null) {
            await sendWelcomeNotification(token, username);
          }
        } catch (e) {
          setState(() {
            _errorText = e.toString().split("]")[1].trim();
          });
          isLoading = false;
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = 'Invalid Email or Password!';
      });
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
    }
  }

  Future<void> sendNotification(String token, String title, String body) async {
    final String serverKey =
        "34eb1d1107a84d5b0e7f9b05576c0d1ff04823cf"; // ضع هنا مفتاح الخادم
    final String fcmUrl = "https://fcm.googleapis.com/fcm/send";

    final Map<String, dynamic> message = {
      "to": token,
      "notification": {
        "title": title,
        "body": body,
      },
    };

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$serverKey",
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("✅ تم إرسال الإشعار بنجاح!");
    } else {
      print("❌ فشل إرسال الإشعار: ${response.statusCode}");
      print("🔴 الخطأ: ${response.body}");
    }
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
                Image.asset('assets/todo.png', height: 160),
                SizedBox(height: 20),
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
