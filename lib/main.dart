import 'package:chatapp/data_model/message.dart';
import 'package:chatapp/screens/auth_screeen.dart';
import 'package:chatapp/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox<Message>('messages');

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xff1e5aff),
          accentColor: const Color(0xffff8c20)),
      home: const MyApp()));
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
