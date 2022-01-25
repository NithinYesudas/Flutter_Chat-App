import 'dart:io';
import 'package:chatapp/widgets/image_picker.dart';
import 'package:flutter/material.dart';

enum AuthMode { Signup, Login }

class AuthCard extends StatefulWidget {
  final Function authRequest;
  late bool isLoading;

  AuthCard(this.authRequest, this.isLoading, {Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  final _passwordController = TextEditingController();


  late String userEmail, username = '', userPassword;
   File? userImage;
  void imageGetter(File image){
    userImage = image;
    print('image Getter calling');

  }

  void submit() {
    print('submit fn calling.......................');
    if(_authMode == AuthMode.Login)print('login mode');
    final valid = _formKey.currentState!.validate();

    FocusScope.of(context).unfocus();
    if( _authMode == AuthMode.Signup){
      if(userImage == null ){
        print('no image found');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No image found")));
        return;
      }

    }
    if (valid) {
      print('isvalid');
      _formKey.currentState!.save();
      widget.authRequest(username.trim(), userEmail.trim(), userPassword.trim(),
          _authMode == AuthMode.Login ? true : false, userImage);
    }
  }

  void errorDialog(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  late AnimationController _controller;
  late Animation<double> opacityAnimation;
  late Animation<Size> animation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animation = Tween(
            begin: const Size(double.infinity, 260),
            end: const Size(double.infinity, 360))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    opacityAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    slideAnimation = Tween<Offset>(
            begin: const Offset(0, -1), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedBuilder(
        animation: animation,
        builder: (ctx, child) {
          return Container(
              height: animation.value.height,
              constraints: BoxConstraints(minHeight: animation.value.height),
              width: deviceSize.width * 0.75,
              padding: const EdgeInsets.all(16.0),
              child: child);
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_authMode == AuthMode.Signup)
                 UserImagePicker(imageGetter),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 180 : 0),
                  child: FadeTransition(
                    opacity: opacityAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: TextFormField(
                        key: const ValueKey('username'),
                        decoration: const InputDecoration(
                            labelText: 'Username', hintText: 'eg: Max'),
                        keyboardType: TextInputType.name,
                        validator: _authMode == AuthMode.Signup? (value) {
                          if (value!.isEmpty) {
                            return "Can't leave empty";
                          } else {
                            return null;
                          }
                        }: null,
                        onSaved: (value) {
                          username = value!;
                        },
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  key: const ValueKey('email'),
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    userEmail = value!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('password'),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    userPassword = value!;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  AnimatedContainer(
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 300),
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                    child: FadeTransition(
                      opacity: opacityAnimation,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          decoration: const InputDecoration(
                              labelText: 'Confirm Password'),
                          obscureText: true,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (widget.isLoading)
                  const CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    onPressed: submit,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                    color: Colors.orange[700],
                    textColor: Colors.white,
                  ),
                if (!widget.isLoading)
                  FlatButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAuthMode,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Colors.orange[700],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
