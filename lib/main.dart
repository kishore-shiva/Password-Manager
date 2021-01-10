import 'dart:async';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:password_manager/assets/icon/my_flutter_app_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

void main() {
  runApp(
    MaterialApp(
      title: "Kishore's Password Manager",
      theme:
          ThemeData(primaryColor: Colors.blue, highlightColor: Colors.orange),
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
  final ScrollController _scrollController = new ScrollController();
  static const IconData delete = IconData(0xe6a1, fontFamily: 'MaterialIcons');
  static const IconData edit = IconData(0xe6e5, fontFamily: 'MaterialIcons');

  List<Widget> accountsContainer = [];
  final _formKey = GlobalKey<FormState>();

  void addData(String websiteName, String username, String password,
      String mail, String additional) {
    _firestore.collection(_currentUser.email).add({
      'website or account name': websiteName,
      'username or card No': username,
      'password or PIN': password,
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 0.55 * MediaQuery.of(context).size.width,
                  child: Text(
                    a['website or account name'],
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: IconButton(
                            color: Colors.white,
                            icon: Icon(
                              edit,
                              size: 20,
                            ),
                            onPressed: () {
                              print('this');
                              websiteText.text = a['website or account name'];
                              emailController.text = a['mail-id'];
                              username.text = a['username or card No'];
                              password.text = a['password or PIN'];
                              additionalinformation.text =
                                  a['additional details'];
                              Alert(
                                  context: context,
                                  title: "Edit Account Details",
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
                                                    EdgeInsets.fromLTRB(
                                                        12, 10, 0, 0),
                                                labelText:
                                                    "Website/Account name",
                                                hintText: "Enter here",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                                if (EmailValidator.validate(
                                                        value) ||
                                                    value.isEmpty) {
                                                  return null;
                                                } else {
                                                  return "Enter email in proper format!";
                                                }
                                              },
                                              controller: emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              cursorColor: Colors.blue,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        12, 10, 0, 0),
                                                labelText: "Associated Mail-Id",
                                                hintText: "Enter here",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                                    EdgeInsets.fromLTRB(
                                                        12, 10, 0, 0),
                                                labelText:
                                                    "Username/Account No",
                                                hintText: "Enter here",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                                    EdgeInsets.fromLTRB(
                                                        12, 10, 0, 0),
                                                labelText: "Password/PIN",
                                                hintText: "Enter here",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                                    EdgeInsets.fromLTRB(
                                                        12, 10, 0, 20),
                                                labelText:
                                                    "Additional Information",
                                                hintText: "Enter here",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                          print(websiteText.text);
                                          getDocumentId(websiteText.text).then(
                                              (value) => _firestore
                                                      .collection(
                                                          _currentUser.email)
                                                      .document(value)
                                                      .updateData({
                                                    'website or account name':
                                                        websiteText.text,
                                                    'mail-id':
                                                        emailController.text,
                                                    'password or PIN':
                                                        password.text,
                                                    'additional details':
                                                        additionalinformation
                                                            .text,
                                                    'username or card No':
                                                        username.text
                                                  }));
                                          print('document updated');
                                          Navigator.pop(context);
                                        } else {
                                          print("form invalid");
                                        }
                                      },
                                      child: Text(
                                        "SAVE CHANGES",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ]).show();
                            }),
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () {
                            print("this");
                            //deleteDocument(a['website/account name']);
                            //showData(userMail);
                            showDialog(
                              context: context,
                              child: new AlertDialog(
                                title: const Text("Delete Account"),
                                content: const Text(
                                    "Are you sure want to delete this account and its details ?"),
                                actions: [
                                  new FlatButton(
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      deleteDocument(
                                          a['website or account name']);
                                      showData(_currentUser.email);
                                      Fluttertoast.showToast(
                                          msg: "Account deleted successfully !",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.orange,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  new FlatButton(
                                    child: const Text(
                                      "No",
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            delete,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                SelectableText(
                  a['username or card No'],
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
                  SelectableText(
                    a['mail-id'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          );
    (a['password or PIN'].isEmpty)
        ? null
        : texts.add(Container(
            margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: Row(
              children: [
                Text(
                  "Password/PIN : ",
                  style: TextStyle(fontSize: 14),
                ),
                SelectableText(
                  a['password or PIN'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              ],
            )));
    (a['additional details'].isEmpty)
        ? null
        : texts.add(Container(
            margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Additional details : ",
                  style: TextStyle(fontSize: 14),
                ),
                Container(
                  width: 0.52 * MediaQuery.of(context).size.width,
                  child: Text(
                    a['additional details'],
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )));

    return texts;
  }

  @override
  void initState() {
    loading = true;
    super.initState();
    loading = true;
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
        print('-------------------user is : ' +
            _currentUser.email +
            '---------------------');
        showData(_currentUser.email);
      });
    });
    _googleSignIn.signInSilently();
    loading = false;
    showModal = false;
  }

  void showIDs() async {
    final messages = await _firestore
        .collection(_currentUser.email)
        .getDocuments()
        .catchError((e) {
      print('-------------------------Error from firestore: ' +
          e +
          '----------------------------');
    });
    for (var message in messages.documents) {
      print('_________________Document ID is :' + message.documentID);
    }
  }

  void deleteDocument(String websiteName) async {
    final messages =
        await _firestore.collection(_currentUser.email).getDocuments();
    for (var message in messages.documents) {
      if (message.data['website or account name'] == websiteName) {
        _firestore
            .collection(_currentUser.email)
            .document(message.documentID)
            .delete();
      }
    }
  }
  // The udpate function returns a String of the Document ID in which the data has to be updated:

  Future<String> getDocumentId(String websiteName) async {
    final messages =
        await _firestore.collection(_currentUser.email).getDocuments();
    for (var message in messages.documents) {
      if (message.data['website or account name'] == websiteName) {
        return message.documentID;
      }
    }
    return "document not present";
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
      loading = false;
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
                        onPressed: _handleSignOut),
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
                      websiteText = new TextEditingController();
                      emailController = new TextEditingController();
                      username = new TextEditingController();
                      password = new TextEditingController();
                      additionalinformation = new TextEditingController();
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
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 4,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Scrollbar(
                    isAlwaysShown: true,
                    controller: _scrollController,
                    radius: Radius.circular(10),
                    thickness: 4,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: (accountsContainer.length == 0)
                            ? [Text("accounts container is empty")]
                            : accountsContainer,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      loading = false;
      return Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 70),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  MyFlutterApp.unnamed,
                  size: 150,
                  color: Colors.orange,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Password Manager",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "- created by kishore shiva",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  height: 0.0555 * MediaQuery.of(context).size.height,
                  width: 0.75 * MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    onPressed: _handleSignIn,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            height: 30,
                            width: 30,
                            child: Image.asset('assets/icon/google_logo.png')),
                        Text(
                          "  Sign in with google",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          title: Center(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              MyFlutterApp.unnamed,
              color: Colors.orange,
              size: 32,
            ),
            Text(" Password Manager")
          ])),
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
