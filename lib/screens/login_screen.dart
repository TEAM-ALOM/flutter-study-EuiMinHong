import 'package:arom_study_quiz/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginService _loginService = LoginService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentUser != null) ...[
              Text("Logged in as: ${_currentUser!.displayName ?? 'Unknown'}"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _loginService.signOut();
                  setState(() {
                    _currentUser = null;
                  });
                  print("User logged out");
                },
                child: Text("Sign out"),
              ),
            ] else ...[
              Text("You are not logged in"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  User? user = await _loginService.signInWithGoogle();
                  if (user != null) {
                    setState(() {
                      _currentUser = user;
                    });
                    print("User logged in: ${user.displayName}");
                  } else {
                    print("Google sign-in failed");
                  }
                },
                child: Text("Sign in with Google"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
