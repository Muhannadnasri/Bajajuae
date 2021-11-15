import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'addUsers.dart';
import 'drawer.dart';
import 'editUsers.dart';
import 'globle.dart';

class Users extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Users> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var seachCnt = TextEditingController();
  String selectedName = "";
  List itemsToShow = [];

  List itemsJson = [];
  @override
  void initState() {
    super.initState();
    getUsers();
    selectedName = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: SafeArea(
            child: AppDrawer(
          selected: 'Users',
        )),
        appBar: AppBar(
          title: Text('Users'),
        ),
        body: ListView(
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: seachCnt,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Please enter employee number',
                      labelText: 'Employee Number',
                    ),
                    onChanged: (x) {
                      setState(() {
                        selectedName = x;
                        searchItems();
                      });
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddUsers(),
                            ),
                          );
                        },
                        color: Color(0xffffe900),
                        // textColor: Colors.white,
                        child: Text('Add New'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: itemsToShow.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return buildItems(index);
                }),
          ],
        ));
  }

  buildItems(index) {
    return Card(
      child: Container(
        child: ListTile(
          trailing: Column(
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUser(
                          userId: itemsToShow[index]['userid'],
                          name: itemsToShow[index]['name'].toString(),
                          username: itemsToShow[index]['username'].toString(),
                          password: itemsToShow[index]['password'].toString(),
                          role: itemsToShow[index]['role_name'] == 'admin'
                              ? 0
                              : 1,
                          email: itemsToShow[index]['email_id'].toString(),
                          managerId: itemsToShow[index]['managerid'].toString(),
                        ),
                      ),
                    );
                  },
                  child: Container(child: Icon(Icons.edit))),
            ],
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child:
                    Text('User ID:' + itemsToShow[index]['userid'].toString()),
              ),
              Container(
                child: Text('Name:' + itemsToShow[index]['name'].toString()),
              ),
              Container(
                child: Text(
                    'UserName:' + itemsToShow[index]['username'].toString()),
              ),
              Container(
                child: Text(
                    'employee No:' + itemsToShow[index]['userid'].toString()),
              ),
              Container(
                child:
                    Text('Role:' + itemsToShow[index]['role_name'].toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void searchItems() {
    setState(() {
      itemsToShow = itemsJson.where((i) {
        if (selectedName != "" &&
            !i['userid'].toString().contains(selectedName)) {
          return false;
        } else {
          return true;
        }
        // if(archive==0){}
      }).toList();
    });
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
                    getUsers();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future getUsers() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/Users/GetUsers/'),
        body: {
          'empid': loginJson['role_ID'] == 1 ? '0' : username.toString(),
        },
      );
      if (response.statusCode == 200) {
        setState(
          () {
            itemsJson = json.decode(response.body);
            itemsToShow = itemsJson;
            selectedName = '';
            seachCnt.text = '';
          },
        );

        _showLoading(false);
      } else {
        _showError();
      }
    } catch (x) {
      _showError();
    }
  }
}
