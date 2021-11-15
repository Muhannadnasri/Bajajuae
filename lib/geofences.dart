import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'drawer.dart';
import 'editGeofences.dart';
import 'globle.dart';

const CameraPosition _kInitialPosition =
    CameraPosition(target: LatLng(-33.852, 151.211), zoom: 11.0);

class Geofences extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Geofences> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List geofencesJson = [];
  Map deleteGeofencesJson = {};
  GoogleMapController mapController;
  Set<Circle> circles = {};
  LatLng _lastTap;
  Position _currentPosition;
  String latitude = '';
  String longitude = '';
  double radius = 0;
  String geofenceName = '';
  Set<Marker> _markers = {};

  _handleTap(LatLng point, String title, index) {
    setState(() {
      _markers = {};
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: title,
        ),
      ));

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: point,
            zoom: 17.0,
          ),
        ),
      );
      circles = Set.from([
        Circle(
            circleId: CircleId("myCircle"),
            radius: geofencesJson[index]['radius'],
            center: LatLng(point.latitude, point.longitude),
            fillColor: Colors.blue[100],
            strokeColor: Colors.green,
            onTap: () {
              print('circle pressed');
            })
      ]);
    });
  }

  _initCurrentLocation() {
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    ).then((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    }).catchError((e) {
      //
    });

    setState(() {
      _currentPosition = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
    geofences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // drawer: SafeArea(
        //     child: AppDrawer(
        //   selected: 'Geofences',
        // )),
        appBar: AppBar(
          title: Text('Geofences'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: ListView.builder(
                  itemCount: geofencesJson.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Card(
                      child: Container(
                        child: ListTile(
                          onTap: () {
                            _handleTap(
                                LatLng(geofencesJson[index]['latitude'],
                                    geofencesJson[index]['longitude']),
                                geofencesJson[index]['geoFenceName'].toString(),
                                index);
                          },
                          trailing: Column(
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditGeofences(
                                          id: geofencesJson[index]['id'],
                                          geoFenceName: geofencesJson[index]
                                                  ['geoFenceName']
                                              .toString(),
                                          latitude: geofencesJson[index]
                                                  ['latitude']
                                              .toString(),
                                          longitude: geofencesJson[index]
                                                  ['longitude']
                                              .toString(),
                                          radius: geofencesJson[index]['radius']
                                              .toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(child: Icon(Icons.edit))),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showAprrove(geofencesJson[index]['id']
                                          .toString());
                                    });
                                  },
                                  child: Container(child: Icon(Icons.delete)))
                            ],
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text('Name:'),
                                  ),
                                  Container(
                                    child: Text(geofencesJson[index]
                                            ['geoFenceName']
                                        .toString()),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text('Latitude:'),
                                      ),
                                      Container(
                                        child: Text(geofencesJson[index]
                                                ['latitude']
                                            .toString()),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text('Longitude:'),
                                      ),
                                      Container(
                                        child: Text(geofencesJson[index]
                                                ['longitude']
                                            .toString()),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text('Radius:'),
                                  ),
                                  Container(
                                    child: Text(geofencesJson[index]['radius']
                                        .toString()),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Expanded(
              flex: 3,
              child: Container(
                child: GoogleMap(
                  circles: circles,
                  markers: _markers,
                  myLocationEnabled: true,
                  onMapCreated: onMapCreated,
                  initialCameraPosition: _kInitialPosition,
                ),
              ),
            ),
          ],
        ));
  }

  void _showAprrove(id) {
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
                    child: new Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(child: new Text("Are you sure you want delete it ?"))
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteGeofences(id);
                  },
                  child: new Text('Yes'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text('No'),
                ),
              ],
            ),
          );
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
                    geofences();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future geofences() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/GetAllGeofence'),
      );
      if (response.statusCode == 200) {
        setState(
          () {
            geofencesJson = json.decode(response.body);
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

  Future deleteGeofences(id) async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.delete(
          Uri.parse(
              'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/DeleteGeofence/${id.toString()}'),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        setState(
          () {},
        );
        geofences();
        _showLoading(false);

        loggedin = true;
      } else if (response.statusCode != 200) {
        _showLoading(false);
      }
    } catch (x) {
      _showError();
      print(x);
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });
  }
}
