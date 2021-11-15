import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'globle.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _logInForm = GlobalKey<FormState>();
  var usernameCnt = TextEditingController();
  var passwordCnt = TextEditingController();
  @override
  void initState() {
    super.initState();
    loginJson = {};

    getString();
  }

  Future getString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    username = (prefs.getString('username') ?? '');
    password = (prefs.getString('password') ?? '');

    if (username != "" && password != "") {
      usernameCnt.text = username;
      passwordCnt.text = password;
      login();
    } else {
      usernameCnt.text = username;
      passwordCnt.text = password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Container(
                    height: 100,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/logo.png'))),
                  ),
                ),
                Form(
                    key: _logInForm,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: usernameCnt,
                            validator: (x) => x.length < 3 || x.length > 100
                                ? "Please enter a valid username"
                                : null,
                            onSaved: (x) {
                              username = x;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'User Name',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: TextFormField(
                            controller: passwordCnt,
                            onSaved: (x) {
                              password = x;
                            },
                            obscureText: true,
                            validator: (x) => x.length < 3 || x.length > 100
                                ? "Please enter a valid password"
                                : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 30,
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      color: Color(0xffffe900),
                      child: Text('Login'),
                      onPressed: () {
                        if (_logInForm.currentState.validate()) {
                          _logInForm.currentState.save();
                        } else {
                          return;
                        }
                        setState(() {
                          login();
                        });
                      },
                    )),
                SizedBox(
                  height: 40,
                ),
              ],
            )));
  }

  void _showLoading(isLoading) {
    if (isLoading) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () {},
              child: new AlertDialog(
                  content: new Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0),
                    child: new CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: new Text('Please Wait...'),
                  )
                ],
              )),
            );
          });
    } else {
      Navigator.pop(context);
    }
  }

  void _showError() {
    _showLoading(false);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {},
            child: new AlertDialog(
              content: new Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: new Icon(Icons.signal_wifi_off),
                  ),
                  new Text("Unable to connect")
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    login();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future login() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/authenticateuser/?userName=$username&Password=$password'),
      );

      if (response.statusCode == 200) {
        setState(
          () {
            loginJson = json.decode(response.body);
          },
        );
        _showLoading(false);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setString('password', password);
        loggedin = true;
        if (loginJson['role_ID'] == 2 || loginJson['role_ID'] == 1) {
          // showFace();
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/report', (Route<dynamic> route) => false);
        } else if (loginJson['role_ID'] == 3) {
          showFace();
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/attendance', (Route<dynamic> route) => false);
        }
      } else if (response.statusCode != 200) {
        final snackBar =
            SnackBar(content: Text('Login credential are not valid'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        _showLoading(false);
      }
    } catch (x) {
      _showError();
    }
  }

  Future showFace() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/Geofence/getphoto'),
        body: {
          'userId': loginJson['userName'],
        },
      );
      if (response.statusCode == 200) {
        base64All = json.decode(response.body)['photo'];
        bytesAll = Base64Codec().decode(base64All);
      } else {
        // Fluttertoast.showToast(
        //     msg: "Something wrong try again.",
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
      }
    } catch (x) {
      _showError();
    }
  }
}
