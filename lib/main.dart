import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:email_validator/email_validator.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

void main() {
  runApp(
    MaterialApp(
      title: "Kishore's Password Manager",
      theme: ThemeData(primaryColor: Colors.blue, highlightColor: Colors.white),
      home: SignInDemo(),
    ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount _currentUser;
  String _contactText;
  bool loading;
  bool showModal;
  final _firestore = Firestore.instance;
  TextEditingController emailController = new TextEditingController();
  TextEditingController websiteText = new TextEditingController();
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void addData() {
    _firestore
        .collection('Kishore shiva')
        .add({'name': "Kishore shiva", "Contacts": 0});
  }

  @override
  void initState() {
    loading = true;
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    addData();
    loading = false;
    showModal = false;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  // To sign in: _handleSignIn, sign out: _handleSignOut, referesh: _handleGetContact

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                height: 65,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GoogleUserCircleAvatar(identity: _currentUser),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser.displayName,
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.7)),
                          ),
                          Text(_currentUser.email,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.5)))
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    RaisedButton(
                      highlightColor: Colors.blueGrey,
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: const Text(
                        'SIGN OUT',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _handleSignOut,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            height: 1.5,
            width: MediaQuery.of(context).size.width - 20,
            color: Colors.black.withOpacity(0.8),
          ),
          Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                children: [
                  RaisedButton(
                    highlightColor: Colors.blueGrey,
                    onPressed: () {
                      websiteText.clear();
                      emailController.clear();
                      username.clear();
                      password.clear();
                      Alert(
                          context: context,
                          title: "Enter Account Details",
                          content: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    height: 65,
                                    child: TextFormField(
                                      initialValue: null,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Website Name is required!";
                                        } else
                                          return null;
                                      },
                                      controller: websiteText,
                                      cursorColor: Colors.blue,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(12, 10, 0, 0),
                                        labelText: "Website/Account name",
                                        hintText: "Enter here",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: new BorderSide(
                                                color: Colors.blue)),
                                      ),
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    height: 65,
                                    child: TextFormField(
                                      initialValue: null,
                                      validator: (value) {
                                        if (EmailValidator.validate(value)) {
                                          return null;
                                        } else {
                                          return "Enter email in proper format!";
                                        }
                                      },
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      cursorColor: Colors.blue,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(12, 10, 0, 0),
                                        labelText: "Associated Mail-Id",
                                        hintText: "Enter here",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: new BorderSide(
                                                color: Colors.blue)),
                                      ),
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    height: 65,
                                    child: TextFormField(
                                      initialValue: null,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Username is required!";
                                        } else {
                                          return null;
                                        }
                                      },
                                      controller: username,
                                      cursorColor: Colors.blue,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(12, 10, 0, 0),
                                        labelText: "Username",
                                        hintText: "Enter here",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: new BorderSide(
                                                color: Colors.blue)),
                                      ),
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    height: 65,
                                    child: TextFormField(
                                      initialValue: null,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Password required!";
                                        } else {
                                          return null;
                                        }
                                      },
                                      controller: password,
                                      cursorColor: Colors.blue,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(12, 10, 0, 0),
                                        labelText: "Password",
                                        hintText: "Enter here",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: new BorderSide(
                                                color: Colors.blue)),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          buttons: [
                            DialogButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  print("form validated");
                                  Navigator.pop(context);
                                } else {
                                  print("form invalid");
                                }
                              },
                              child: Text(
                                "SAVE",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            )
                          ]).show();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 10,
                    color: Colors.black,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "+",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "     Add Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ],
      );
    } else {
      loading = false;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Kishore's Password Manager"),
        ),
        body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ModalProgressHUD(
                inAsyncCall: loading,
                opacity: 0.6,
                color: Colors.black,
                progressIndicator: SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                    backgroundColor: Colors.orange,
                    strokeWidth: 7,
                  ),
                ),
                child: _buildBody(),
              ),
            )));
  }
}
