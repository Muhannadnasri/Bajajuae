import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class AddGeofence extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<AddGeofence> {
  GoogleMapController mapController;
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  final _addFormGeofence = GlobalKey<FormState>();

  LatLng _lastTap;
  Position _currentPosition;
  String latitude = '';
  String longitude = '';
  double radius = 0;
  String geofenceName = '';
  Set<Marker> _markers = {};
  Set<Circle> circles = {};

  _handleTap(LatLng point) {
    setState(() {
      _markers = {};
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: 'I am a here',
        ),
      ));
    });

    _latitude.text = point.latitude.toString();
    _longitude.text = point.longitude.toString();
  }

  _radius() {
    circles = Set.from([
      Circle(
          circleId: CircleId("myCircle"),
          radius: radius,
          center: LatLng(
              double.parse(_latitude.text), double.parse(_longitude.text)),
          fillColor: Colors.blue[100],
          strokeColor: Colors.green,
          onTap: () {
            print('circle pressed');
          })
    ]);
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

    // getCurrentPosition(

    setState(() {
      _currentPosition = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Geofence'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Card(
                child: Container(
                  child: Form(
                    key: _addFormGeofence,
                    child: ListView(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.contacts),
                            hintText: 'Please enter geofence name',
                            labelText: 'Geofence Name',
                          ),
                          onSaved: (String value) {
                            geofenceName = value;
                          },
                          validator: (x) => x.length < 3 || x.length > 100
                              ? "Please enter geofence name"
                              : null,
                        ),
                        TextFormField(
                          controller: _latitude,
                          onChanged: (lastTap) {},
                          decoration: const InputDecoration(
                            icon: Icon(Icons.add_location),
                            hintText: 'Please enter latitude',
                            labelText: 'Latitude',
                          ),
                          onSaved: (String value) {
                            latitude = value;
                          },
                          validator: (x) => x.length < 3 || x.length > 100
                              ? "Please enter latitude"
                              : null,
                        ),
                        TextFormField(
                          controller: _longitude,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.edit_location),
                            hintText: 'Please enter longitude',
                            labelText: 'Longitude',
                          ),
                          validator: (x) => x.length < 3 || x.length > 100
                              ? "Please enter longitude"
                              : null,
                          onSaved: (String value) {
                            longitude = value;
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.line_style),
                            hintText: 'Please enter radius metres',
                            labelText: 'Radius(metres)',
                          ),
                          onSaved: (String value) {
                            radius = double.parse(value);
                          },
                          validator: (x) => x.length < 1 || x.length > 100
                              ? "Please enter radius metres"
                              : null,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    if (_addFormGeofence.currentState
                                        .validate()) {
                                      _addFormGeofence.currentState.save();
                                    } else {
                                      return;
                                    }

                                    _radius();
                                  });
                                },
                                color: Color(0xffffe900),
                                // textColor: Colors.white,
                                child: Text('Check on Map'),
                              ),
                            ),
                            Container(
                              child: RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    if (_addFormGeofence.currentState
                                        .validate()) {
                                      _addFormGeofence.currentState.save();
                                    } else {
                                      return;
                                    }

                                    addGeofence();
                                  });
                                },
                                color: Color(0xffffe900),
                                // textColor: Colors.white,
                                child: Text('Add Geofence'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: GoogleMap(
                  markers: _markers,
                  myLocationEnabled: true,
                  onMapCreated: onMapCreated,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition.latitude,
                          _currentPosition.longitude),
                      zoom: 11.0),
                  onTap: _handleTap,
                  circles: circles,
                ),
              ),
            ),
          ],
        ));
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
                    addGeofence();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future addGeofence() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/geofence/RegisterGeofence'),
        body: {
          'GeoFenceName': geofenceName,
          'Latitude': latitude,
          'Longitude': longitude,
          'Radius': radius.toString(),
          'CreatedDate': DateTime.now().toString()
        },
      );
      if (response.statusCode == 200) {
        setState(
          () {
            _showLoading(false);

            Navigator.of(context).pushNamedAndRemoveUntil(
                '/geofences', (Route<dynamic> route) => false);
          },
        );
      } else {
        _showError();
      }
    } catch (x) {
      _showError();
    }
  }
}
