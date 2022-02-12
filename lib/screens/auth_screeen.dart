import 'dart:io';
import 'dart:math';
import 'package:chatapp/widgets/auth_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;

  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
    // TODO: implement initState
  }

  void authRequest(String userName, String userEmail, String userPassword,
      bool isLogin, File? image) async {
    final _auth = FirebaseAuth.instance;
    UserCredential authresult;
    setState(() {
      isLoading = true;
    });
    try {
      if (isLogin == true) {
        authresult = await _auth.signInWithEmailAndPassword(
            email: userEmail, password: userPassword);
      } else {
        authresult = await _auth.createUserWithEmailAndPassword(
            email: userEmail, password: userPassword);

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(authresult.user!.uid + '.jpg');
        ref.putFile(image!);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authresult.user!.uid)
            .set({'username': userName, 'userid': authresult.user!.uid});
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Colors.blueAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: deviceSize.width * .15),

                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).accentColor,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Text(
                        'Chat App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'dmsansbold',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(authRequest, isLoading),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
