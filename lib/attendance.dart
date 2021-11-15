import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:ntp/ntp.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'globle.dart';
import 'package:http/http.dart' as http;
import 'drawer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class AttendanceMark extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<AttendanceMark> {
  CameraPosition _kInitialPosition;

  bool network = false;
  bool ignoringLocation = true;
  GoogleMapController mapController;
  LatLng _lastTap;
  Position _currentPosition;
  double attendanceLatitude;
  double attendanceLongitude;
  int checkAttendaceLocationJson = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // bool mode = false;
  int mode = 0;
  bool isVisible = true;
  int checkAttendaceJson = 0;

  Set<Marker> _markers = {};
  String address = '';

  final dateNow = TextEditingController();
  final timeNow = TextEditingController();
  final dateSend = TextEditingController();
  final timeSend = TextEditingController();
  Set<Circle> circles = {};
  String companyName = '';
  // openLocationSetting() async {
  //   final AndroidIntent intent = new AndroidIntent(
  //     action: 'android.settings.LOCATION_SOURCE_SETTINGS',
  //   );

  //   // bool permission = await Geolocator.isLocationServiceEnabled();

  //   // if (!permission) {
  //   await intent.launch();

  //   // Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  //   // if (statuses[Permission.location].isGranted) {
  //   //   // openCamera();
  //   // } else {
  //   //   showToast(
  //   //       "Camera needs to access your microphone, please provide permission",
  //   //       position: ToastPosition.bottom);
  //   // }
  //   // } else {}

  //   // print(statuses[Permission.location]);
  // }

  // void openLocationSetting() async {
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   print(permission);
  //   if (permission == LocationPermission.whileInUse) {
  //     print('done');
  //   } else {
  //     await Geolocator.openAppSettings();

  //     // await Geolocator.requestPermission();
  //   }
  //   // await Geolocator.openAppSettings();

  //   // if(permission.isDeny)
  // }
  // checkLocation() async {
  //   if (_currentPosition == null) {
  //     _kInitialPosition =
  //         CameraPosition(target: LatLng(-33.852, 151.211), zoom: 15.0);
  //   } else {
  //     _kInitialPosition = CameraPosition(
  //         target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
  //         zoom: 11.0);
  //   }
  // }

  initCurrentLocation() async {
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    ).then((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    }).catchError((e) {
      print(e);
      //
    });

    // await getCurrentPosition(

    //   desiredAccuracy: LocationAccuracy.best,
    // ).then((position) {
    //   if (mounted) {
    //     setState(() => _currentPosition = position);
    //   }
    // }).catchError((e) {
    //   //
    // });
    setState(() {
      _currentPosition = null;
    });

    setState(() {
      StreamSubscription<Position> positionStream =
          Geolocator.getPositionStream(
                  desiredAccuracy: LocationAccuracy.high, distanceFilter: 10)
              .listen((Position position) {
        _markers.clear();
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(position.toString()),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(
              title: 'I am a here',
            ),
          ));
        });

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17.0,
            ),
          ),
        );
        attendanceLatitude = position.latitude;
        attendanceLongitude = position.longitude;
        checkAttendaceLocation();

        circles = Set.from([
          Circle(
              circleId: CircleId("myCircle"),
              radius: 100,
              // center: _createCenter,
              center: LatLng(position.latitude, position.longitude),
              fillColor: Colors.transparent,
              strokeColor: Colors.green,
              onTap: () {
                print('circle pressed');
              })
        ]);
      });
    });
  }

  Future<void> _getStreet() async {
    placemarkFromCoordinates(attendanceLatitude, attendanceLongitude)
        .then((placemarks) {
      Placemark placeMark = placemarks[0];
      setState(() {
        address = placeMark.locality + ' ' + placeMark.street;
      });
    });
  }

  Future<void> _getTime() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        network = true;
      }
    } on SocketException catch (_) {
      network = false;
    }

    DateTime _myTime;
    DateTime _ntpTime;

    /// Or you could get NTP current (It will call DateTime.now() and add NTP offset to it)
    _myTime = await NTP.now();

    /// Or get NTP offset (in milliseconds) and add it yourself
    ///
    ///
    final int offset = await NTP.getNtpOffset(localTime: DateTime.now());
    _ntpTime = _myTime.add(Duration(milliseconds: offset));
    // final DateTime now = DateTime.now();

    // DateTime nowDate = DateTime.now();

    final String formattedDate = DateFormat('yyyy/MM/dd').format(_ntpTime);
    final String sendDate = DateFormat('yyyyMMdd').format(_ntpTime);

    final String formattedTime = DateFormat('hh:mm').format(_ntpTime);
    final String sendTime = DateFormat('HHmmss').format(_ntpTime);

    setState(() {
      dateNow.text = formattedDate;
      dateSend.text = sendDate;
      timeSend.text = sendTime;
      timeNow.text = formattedTime;
    });
  }

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (visible != true) isVisible = true;
      },
    );
    isVisible = true;

    initCurrentLocation();
    // checkLocation();
    _kInitialPosition =
        CameraPosition(target: LatLng(-33.852, 151.211), zoom: 15.0);
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusManager.instance.primaryFocus?.unfocus();
          isVisible = true;
        });
      },
      child: Scaffold(
          key: _scaffoldKey,
          drawer: SafeArea(
            child: AppDrawer(
              selected: 'Attendance',
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     setState(() {
          //       initCurrentLocation();
          //     });
          //   },
          // ),
          appBar: AppBar(
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/notification');
                  },
                  child: Container(
                    child: Icon(Icons.notifications_active),
                  ),
                ),
              )
            ],
            title: Text('Home'),
          ),
          body: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text('Date:'),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                child: Text(dateNow.text),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text('Time:'),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                child: Text(timeNow.text),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            child: Text('Checking:'),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: IgnorePointer(
                              ignoring: ignoringLocation,
                              child: ToggleSwitch(
                                minHeight: 30,
                                minWidth: 80.0,
                                cornerRadius: 10.0,
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey,
                                initialLabelIndex: mode,
                                inactiveFgColor: Colors.white,
                                totalSwitches: 2,

                                // changeOnTap: null,
                                // changeOnTap:
                                //     checkAttendaceJson == 2 ? null : false,
                                labels: ['In', 'Out'],
                                activeBgColors: [
                                  [Colors.green],
                                  [Colors.red]
                                ],
                                onToggle: (index) {
                                  setState(() {
                                    // mode = index;
                                    if (network && companyName != "") {
                                      sendAttendace();
                                    } else {
                                      final snackBar = SnackBar(
                                          content: Text(
                                              'Please check company name and your network and try again'));
                                      _scaffoldKey.currentState
                                          .showSnackBar(snackBar);
                                    }

                                    if (checkAttendaceJson == 1) {
                                      mode = 0;
                                    } else if (checkAttendaceJson == 2) {
                                      mode = 1;
                                    }
                                    // mode = index;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            child: Text('Checking:'),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                  hintText: 'company name'),
                              onTap: () {
                                setState(() {
                                  isVisible = false;
                                });
                              },
                              onChanged: (x) {
                                setState(() {
                                  companyName = x;
                                  // searchItems();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),

                  Expanded(
                    child: Visibility(
                      child: GoogleMap(
                        circles: circles,
                        markers: _markers,
                        myLocationEnabled: true,
                        mapType: MapType.hybrid,
                        onMapCreated: onMapCreated,
                        initialCameraPosition: _kInitialPosition,
                      ),
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: isVisible,
                    ),
                  ),

                  // Expanded(
                  //   child: GoogleMap(
                  //     circles: circles,
                  //     markers: _markers,
                  //     myLocationEnabled: true,
                  //     mapType: MapType.hybrid,
                  //     onMapCreated: onMapCreated,
                  //     initialCameraPosition: _kInitialPosition,
                  //   ),
                  // ),
                ],
              ))),
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
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
                    sendAttendace();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future sendAttendace() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/MarkAttendance'),
        body: {
          "attDate": dateSend.text.toString(),
          "attTime": timeSend.text.toString(),
          "empNo": username,
          "latitude": attendanceLatitude.toString(),
          "longitude": attendanceLongitude.toString(),
          "radius": "16",
          "mobileNo": loginJson['mobileNo'].toString(),
          "mode": mode == 1 ? '2' : '1',
          'address': address.toString(),
          'Company': companyName.toString(),
        },
      );
      if (response.statusCode == 200) {
        setState(
          () {
            _showLoading(false);

            switch (response.body) {
              case "\"Attendance Marked Successfully\"":
                {
                  _scaffoldKey.currentState.showSnackBar(new SnackBar(
                      content: new Text("Attendance Marked Successfully")));
                }

                break;
              default:
                {
                  _scaffoldKey.currentState.showSnackBar(new SnackBar(
                      content: new Text(
                          "Internal Server Error. Please try again.")));
                }
            }
            checkAttendaceLocation();
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

  Future checkAttendace() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/Geofence/GetPunchMode?EmpId=${loginJson['userName']}'),
        // 'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/GetGeofenceValidation?latitide=${attendanceLatitude.toString()}&longitude=${attendanceLongitude.toString()}'),
      );
      if (response.statusCode == 200) {
        checkAttendaceJson = json.decode(response.body);

        setState(
          () {
            _showLoading(false);

            switch (checkAttendaceJson) {
              case 2:
                {
                  // ignoringLocation = true;
                  mode = 1;
                }
                break;
              case 1:
                {
                  // ignoringLocation = false;
                  mode = 0;
                }
                break;
              default:
                {
                  // ignoringLocation = false;
                }
            }
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

  Future checkAttendaceLocation() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.get(
        Uri.parse(
            // 'http://bajajuae.dyndns.org:8443/geofenceapi/api/Geofence/GetPunchMode?EmpId=${loginJson['userName']}'),
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/GetGeofenceValidation?latitide=${attendanceLatitude.toString()}&longitude=${attendanceLongitude.toString()}'),
      );
      if (response.statusCode == 200) {
        checkAttendaceLocationJson = json.decode(response.body);

        setState(
          () {
            _showLoading(false);

            switch (checkAttendaceLocationJson) {
              case 0:
                {
                  ignoringLocation = true;
                }
                break;
              case 1:
                {
                  ignoringLocation = false;
                  checkAttendace();
                  _getStreet();
                }
                break;
              default:
                {
                  ignoringLocation = false;
                }
            }
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
