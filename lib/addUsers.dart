import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';

import 'globle.dart';

class AddUsers extends StatefulWidget {
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<AddUsers> {
  final _editFormUsers = GlobalKey<FormState>();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  String name;
  String username;
  String password;
  int role = 0;
  String email;
  String managerId;
  String userId;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: BottomAppBar(
            child: GestureDetector(
          onTap: () {
            setState(() {
              if (_editFormUsers.currentState.validate()) {
                _editFormUsers.currentState.save();
              } else {
                return;
              }

              editUsers();
            });
          },
          child: Material(
            color: Color(0xffffe900),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Submit",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        )),
        appBar: AppBar(
          title: Text('Add User'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(
            children: <Widget>[
              Form(
                key: _editFormUsers,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Please enter user ID',
                        labelText: 'User ID',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          userId = value;
                        });
                      },
                      validator: (x) => x.length > 100
                          ? "Please enter a valid user ID"
                          : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person_add),
                        hintText: 'Please enter your name',
                        labelText: 'Name',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          name = value;
                        });
                      },
                      validator: (x) =>
                          x.length > 100 ? "Please enter your name" : null,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person_pin),
                        hintText: 'Please enter employee no',
                        labelText: 'Employee No',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          username = value;
                        });
                      },
                      validator: (x) =>
                          x.length > 100 ? "Please enter employee no" : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.keyboard_hide),
                        hintText: 'Please enter your password',
                        labelText: 'Password',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          password = value;
                        });
                      },
                      validator: (x) => x.length < 3 || x.length > 100
                          ? "Please enter your password"
                          : null,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      //check box
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text('Role Name'),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 30,
                            child: ToggleSwitch(
                              minWidth: 90.0,
                              totalSwitches: 2,
                              cornerRadius: 10.0,
                              activeFgColor: Colors.white,
                              inactiveBgColor: Colors.grey,
                              inactiveFgColor: Colors.white,
                              labels: ['Admin', 'Empolyee'],
                              activeBgColors: [
                                [Colors.red],
                                [Colors.green]
                              ],
                              onToggle: (index) {
                                // setState(() {
                                // setState(() {
                                role = index;
                                print(role);
                                // });
                                // });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        hintText: 'Please enter your email',
                        labelText: 'Email',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          email = value;
                        });
                      },
                      validator: (x) => x.length < 3 || x.length > 100
                          ? "Please enter your email"
                          : null,
                      // validator: (String value) {
                      //   return value.contains('@')
                      //       ? 'Do not use the @ char.'
                      //       : null;
                      // },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        icon: Icon(Icons.verified_user),
                        hintText: 'Please enter manager id',
                        labelText: 'Manager Id',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          managerId = value;
                        });
                      },
                      validator: (x) =>
                          x.length > 100 ? "Please enter manager id" : null,
                      // validator: (String value) {
                      //   return value.contains('@')
                      //       ? 'Do not use the @ char.'
                      //       : null;
                      // },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
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
                    editUsers();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future editUsers() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/Users/UpdateUsers/'),
        body: {
          'userid': userId,
          'username': username,
          'password': password,
          'emailid': email,
          'managerid': managerId,
          'name': name,
          'rolename': role == 0 ? 'admin' : 'Employee',
          'mode': "Add",
        },
      );

      if (response.statusCode == 200) {
        final snackBar = SnackBar(content: Text('User Has Been added'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        setState(
          () {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/users', (Route<dynamic> route) => false);
            });
          },
        );
        _showLoading(false);

        loggedin = true;
      } else if (response.statusCode == 401) {
        final snackBar = SnackBar(content: Text('User Already Exists'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        _showLoading(false);
      } else {
        final snackBar = SnackBar(content: Text('Something went wrong'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        _showLoading(false);
      }
    } catch (x) {
      print(x);
      _showError();
    }
  }
}
