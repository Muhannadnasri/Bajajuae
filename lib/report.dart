import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drawer.dart';
import 'globle.dart';

class Report extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Report> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Map locationReportJson = {};
  final _reportFormKey = GlobalKey<FormState>();
  bool _isChecked = true;
  String fromDateSend;
  String toDateSend;

  List reportStatusJson = [];
  List reportJson = [];
  var fromDateText = TextEditingController();
  var toDateText = TextEditingController();
  DateTime ifValue;
  final DateFormat format = DateFormat('yyyy-MM-dd');
  final DateFormat formatSend = DateFormat('yyyyMMdd');
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
      ),
      drawer: SafeArea(
          child: AppDrawer(
        selected: 'Report',
      )),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Form(
              key: _reportFormKey,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          // minTime: DateTime(2018, 3, 5),
                          maxTime: DateTime.now(),
                          theme: DatePickerTheme(
                              headerColor: Color(0xffffe900),
                              backgroundColor: Color(0xffffe900),
                              itemStyle: TextStyle(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                              doneStyle: TextStyle(fontSize: 16)),
                          onConfirm: (date) {
                        setState(() {
                          ifValue = date;
                          fromDateSend = formatSend.format(date);
                          fromDateText.text = format.format(date);
                        });
                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        validator: (x) =>
                            x.length == 0 ? "Please enter a valid date" : null,
                        decoration: new InputDecoration(
                          icon: new Icon(Icons.date_range),
                          labelText: "From Date",
                        ),
                        controller: fromDateText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: ifValue,
                          maxTime: DateTime.now(),
                          theme: DatePickerTheme(
                              headerColor: Color(0xffffe900),
                              backgroundColor: Color(0xffffe900),
                              itemStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                              doneStyle: TextStyle(fontSize: 16)),
                          onConfirm: (date) {
                        toDateSend = formatSend.format(date);
                        toDateText.text = format.format(date);
                        print('confirm $date');
                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        validator: (x) =>
                            x.length == 0 ? "Please enter a valid date" : null,
                        decoration: new InputDecoration(
                          icon: new Icon(Icons.date_range),
                          labelText: "To Date",
                        ),
                        controller: toDateText,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            if (_reportFormKey.currentState.validate()) {
                              _reportFormKey.currentState.save();
                            } else {
                              return;
                            }

                            getReport();
                          });
                        },
                        color: Color(0xffffe900),
                        // textColor: Colors.white,
                        child: Text('Load Report'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: reportJson.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            side: BorderSide.none,
                            borderRadius: BorderRadius.circular(10)),
                        title: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text('Name: '),
                                ),
                                Container(
                                  child: Text(
                                      reportJson[index]['name'].toString()),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text('Emp No: '),
                                ),
                                Container(
                                  child: Text(reportJson[index]
                                          ['employeE_NUMBER']
                                      .toString()),
                                ),
                                Container(
                                  child: Text('Date: '),
                                ),
                                Container(
                                  child: Text(
                                      reportJson[index]['date'].toString()),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text('Time: '),
                                ),
                                Container(
                                  child: Text(
                                      reportJson[index]['timeIn'].toString()),
                                ),
                                Container(
                                  child: Text('Status: '),
                                ),
                                Container(
                                  child: Text(
                                    reportJson[index]['presentStatus']
                                        .toString(),
                                    style: TextStyle(
                                        color: reportJson[index]
                                                    ['presentStatus'] ==
                                                'Pending'
                                            ? Colors.blue
                                            : Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                child: RaisedButton(
                                  elevation: 5,
                                  onPressed: () {
                                    setState(() {
                                      _launchMaps(reportJson[index]['latitude'],
                                          reportJson[index]['longtitude']);
                                    });
                                  },
                                  child: const Text('View in Map',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: loginJson['role_ID'] != 3
                            ? Checkbox(
                                value: reportStatusJson[index]
                                            ['presentStatus'] ==
                                        'Pending'
                                    ? false
                                    : true,
                                onChanged: (val) {
                                  setState(() {
                                    switch (val) {
                                      case false:
                                        {}
                                        break;
                                      case true:
                                        {
                                          if (loginJson['role_ID'] != 3) {
                                            approveReport(index);
                                            getReport();
                                            reportStatusJson[index]
                                                ['presentStatus'] = 'Approved';
                                          }
                                        }
                                        break;
                                      default:
                                    }
                                  });
                                },
                              )
                            : SizedBox(),
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
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
                    getReport();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future getReport() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/GetEmployeeAttendance'),
        body: {
          "empId": username,
          'fromDt': fromDateSend,
          'toDt': toDateSend,
          'Status': 'List',
        },
      );
      if (response.statusCode == 200) {
        setState(
          () {
            _showLoading(false);

            reportJson = json.decode(response.body);
            reportStatusJson = json.decode(response.body);
          },
        );
      } else {
        _showError();
      }
    } catch (x) {
      print(x);

      _showError();
    }
  }

  Future approveReport(int index) async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/UpdateEmployeeAttendance'),
        body: {
          'ids': reportStatusJson[index]['id'].toString(),
          'empId': loginJson['userName'],
          'fromDt': fromDateSend,
          'toDt': toDateSend,
          'Status': 'Approve',
        },
      );
      if (response.statusCode == 200) {
        setState(
          () {
            _showLoading(false);

            getReport();
          },
        );
      } else {
        _showError();
      }
    } catch (x) {
      print(x);

      _showError();
    }
  }
}

_launchMaps(latitude, longitude) async {
  String googleUrl =
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  // String appleUrl = 'http://maps.apple.com/?ll=$latitude,$longitude';

  if (await canLaunch(googleUrl)) {
    print('launching com googleUrl $googleUrl');
    await launch(googleUrl);
  }
  //  else if (await canLaunch(appleUrl)) {
  //   print('launching apple url');
  //   await launch(appleUrl);
  // } else {
  //   print('Cant Open Map');
  // }
}
