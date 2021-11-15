import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'globle.dart';

class Notifications extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Notifications> {
  List notificationsJson = [];

  @override
  void initState() {
    super.initState();
    notifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
        ),
        body: Container(
          child: ListView.builder(
              itemCount: notificationsJson.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return Card(
                  child: Container(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      leading: notificationsJson[index]['notificationMsg'] ==
                              "Your attendance has been recorded successfully."
                          ? Icon(
                              Icons.done,
                              color: Colors.green,
                              size: 40,
                            )
                          : Icon(
                              Icons.clear,
                              color: Colors.red,
                              size: 40,
                            ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          child: Text(notificationsJson[index]
                                  ['notificationMsg']
                              .toString()),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          child: Text(notificationsJson[index]
                                      ['notificationDate']
                                  .toString() +
                              ' ' +
                              notificationsJson[index]['notificationDayName']
                                  .toString()),
                        ),
                      ),
                    ),
                  ),
                );
              }),
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
                    notifications();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future notifications() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/GetNotificationByEmpId/$username'),
      );
      if (response.statusCode == 200) {
        setState(
          () {
            notificationsJson = json.decode(response.body);
          },
        );
        _showLoading(false);

        loggedin = true;
      } else if (response.statusCode != 200) {
        _showLoading(false);
      }
    } catch (x) {
      _showError();
    }
  }
}
