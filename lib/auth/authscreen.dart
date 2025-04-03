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
        title: Text("Taskify"),
        centerTitle: true,
      ),
      body: Theme(
        data: ThemeData.dark(),
        child: AuthForm(),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mydo/auth/authform.dart';

// // حالة التوثيق
// class AuthState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class AuthInitial extends AuthState {}

// class AuthLoading extends AuthState {}

// class AuthError extends AuthState {
//   final String message;
//   AuthError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// class AuthSuccess extends AuthState {}

// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(AuthInitial());

//   void startAuthentication() {
//     emit(AuthLoading());
//   }

//   void authenticationError(String message) {
//     emit(AuthError(message));
//   }

//   void authenticationSuccess() {
//     emit(AuthSuccess());
//   }
// }

// class AuthScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AuthCubit(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Taskify"),
//           centerTitle: true,
//         ),
//         body: AuthForm(),
//       ),
//     );
//   }
// }

// class AuthForm extends StatelessWidget {
//   final _formKey = GlobalKey<FormState>();
//   var _email = '';
//   var _password = '';
//   var _username = '';
//   bool isLoginPage = false;
//   String? _errorText;

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthCubit, AuthState>(
//       listener: (context, state) {
//         if (state is AuthLoading) {
//           // يمكنك إظهار شاشة التحميل هنا
//         }
//         if (state is AuthError) {
//           // عرض رسالة الخطأ
//           _errorText = state.message;
//         }
//         if (state is AuthSuccess) {
//           // انتقل إلى الصفحة الرئيسية أو أي مكان آخر عند النجاح
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           backgroundColor: Colors.grey.shade800,
//           body: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset('assets/todo.png', height: 160),
//                     SizedBox(height: 20),
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           if (!isLoginPage)
//                             buildTextField('username', 'Enter Username'),
//                           buildTextField('email', 'Enter Email'),
//                           buildTextField('password', 'Enter Password',
//                               isPassword: true),
//                           if (_errorText != null)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               child: Text(
//                                 _errorText!,
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           SizedBox(height: 10),
//                           buildSubmitButton(context),
//                           SizedBox(height: 10),
//                           buildSwitchAuthButton(),
//                         ],
//                       ),
//                     ),
//                     if (state is AuthLoading) CircularProgressIndicator(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildTextField(String key, String label, {bool isPassword = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: TextFormField(
//         key: ValueKey(key),
//         obscureText: isPassword,
//         validator: (value) => value!.isEmpty ? '$label is required' : null,
//         onSaved: (value) {
//           if (key == 'email') _email = value!;
//           if (key == 'password') _password = value!;
//           if (key == 'username') _username = value!;
//         },
//         style: TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20.0),
//             borderSide: BorderSide(),
//           ),
//           labelText: label,
//           labelStyle: GoogleFonts.roboto(color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget buildSubmitButton(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       child: ElevatedButton(
//         child: Text(isLoginPage ? 'Login' : 'SignUp',
//             style: TextStyle(fontSize: 16)),
//         style: ButtonStyle(
//           shape: MaterialStateProperty.all(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//           ),
//           backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
//         ),
//         onPressed: () {
//           final cubit = context.read<AuthCubit>();
//           cubit.startAuthentication();
//           startAuthentication(context, cubit);
//         },
//       ),
//     );
//   }

//   void startAuthentication(BuildContext context, AuthCubit cubit) {
//     final formState = _formKey.currentState;
//     if (formState != null) {
//       final validity = formState.validate();
//       FocusScope.of(context).unfocus();
//       if (validity) {
//         formState.save();
//         cubit.startAuthentication();
//         submitForm(_email, _password, _username, cubit);
//       }
//     }
//   }

//   submitForm(
//       String email, String password, String username, AuthCubit cubit) async {
//     final auth = FirebaseAuth.instance;
//     try {
//       UserCredential authResult;

//       if (isLoginPage) {
//         authResult = await auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//       } else {
//         try {
//           authResult = await auth.createUserWithEmailAndPassword(
//             email: email,
//             password: password,
//           );

//           String? uid = authResult.user?.uid;
//           String? token = await FirebaseMessaging.instance.getToken();

//           await FirebaseFirestore.instance.collection('users').doc(uid).set({
//             'username': username,
//             'email': email,
//             'fcmToken': token, // حفظ توكن الإشعارات في Firestore
//           });

//           // إرسال الإشعار الترحيبي
//           if (token != null) {
//             await sendWelcomeNotification(token, username);
//           }

//           cubit.authenticationSuccess();
//         } catch (e) {
//           cubit.authenticationError(e.toString());
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       cubit.authenticationError('Invalid Email or Password!');
//     } catch (e) {
//       print(e);
//     }
//   }

//   Widget buildSwitchAuthButton() {
//     return TextButton(
//       onPressed: () {
//         isLoginPage = !isLoginPage;
//         _errorText = null;
//       },
//       child: Text(
//         isLoginPage ? 'Not a member?' : 'Already a Member?',
//         style: TextStyle(fontSize: 16, color: Colors.white),
//       ),
//     );
//   }
// }
