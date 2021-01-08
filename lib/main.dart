import 'dart:async';
import 'dart:convert' show json;

import 'package:expandable/expandable.dart';
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
  TextEditingController additionalinformation = new TextEditingController();

  List<Widget> accountsContainer = [];
  final _formKey = GlobalKey<FormState>();
  String userMail;

  void addData(String websiteName, String username, String password,
      String mail, String additional) {
    _firestore.collection(userMail).add({
      'website/account name': websiteName,
      'username/card No': username,
      'password/PIN': password,
      'mail-id': mail,
      'additional details': additional
    });
  }

  List<Widget> generateContainers(var a) {
    accountsContainer.add(ExpandablePanel(
      header: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a['website/account name'],
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Username/card No : ",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  a['username/card No'],
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
      expanded: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
            color: Colors.orange[100],
            border: Border.all(
              color: Colors.orange,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: generateContainerTexts(a),
            )
          ],
        ),
      ),
      hasIcon: false,
    ));

    setState(() {
      this.accountsContainer = accountsContainer;
    });
  }

  void showData(String username) async {
    await for (var snapshot in _firestore.collection(username).snapshots()) {
      accountsContainer = [];
      for (var message in snapshot.documents) {
        print(message.data);

        generateContainers(message.data);
      }
    }
  }

  /** This function generate the Texts inside the orange box in accounts container by retuning a list of Texts **/

  List<Widget> generateContainerTexts(var a) {
    List<Widget> texts = [];

    (a['mail-id'].isEmpty)
        ? null
        : texts.add(
            Container(
              child: Row(
                children: [
                  Text(
                    "Mail-Id : ",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    a['mail-id'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          );
    (a['password/PIN'].isEmpty)
        ? null
        : texts.add(Container(
            margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: Row(
              children: [
                Text(
                  "password/PIN : ",
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  a['password/PIN'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              ],
            )));
    (a['additional details'].isEmpty)
        ? null
        : texts.add(Container(
            margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: Row(
              children: [
                Text(
                  "additional details : ",
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  a['additional details'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )
              ],
            )));

    return texts;
  }

  @override
  void initState() {
    loading = true;
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
        userMail = _currentUser.email;
        print('-------------------user is : ' +
            userMail +
            '---------------------');
        showData(userMail);
      });
    });
    _googleSignIn.signInSilently();
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

  Future<void> _handleSignOut() {
    setState(() {
      _currentUser = null;
      _googleSignIn.disconnect();
    });
  }

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GoogleUserCircleAvatar(identity: _currentUser),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
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
                                  color: Colors.black.withOpacity(0.5),
                                  fontSize: 12))
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
                                          return "Website/Account Name is required!";
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
                                        if (EmailValidator.validate(value) ||
                                            value.isEmpty) {
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
                                        labelText: "Username/Account No",
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
                                        labelText: "Password/PIN",
                                        hintText: "Enter here",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: new BorderSide(
                                                color: Colors.blue)),
                                      ),
                                    )),
                                Container(
                                    height: 150,
                                    child: TextFormField(
                                      initialValue: null,
                                      maxLines: 8,
                                      controller: additionalinformation,
                                      cursorColor: Colors.blue,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(12, 10, 0, 20),
                                        labelText: "Additional Information",
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
                                  addData(
                                      websiteText.text,
                                      username.text,
                                      password.text,
                                      emailController.text,
                                      additionalinformation.text);
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
                    elevation: 250,
                    color: Colors.orange,
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
          Column(
            children: (accountsContainer.length == 0)
                ? [Text("accounts container is empty")]
                : accountsContainer,
          ),
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
