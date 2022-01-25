import 'package:chatapp/screens/auth_screeen.dart';
import 'package:chatapp/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

void main() {
  runApp( MaterialApp(debugShowCheckedModeBanner: false,theme: ThemeData(primaryColor: Colors.redAccent), home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const CircularProgressIndicator()
                : StreamBuilder(
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? const CircularProgressIndicator()
                            : snapshot.hasData
                                ? const HomePage()
                                : const AuthScreen(),
                    stream: FirebaseAuth.instance.authStateChanges(),
                  ));
  }
}
