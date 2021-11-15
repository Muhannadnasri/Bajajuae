import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'drawer.dart';
import 'globle.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Profile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Uint8List bytes;
  Map addFaceJson = {};
  File imageAdd;
  String photo = '';
  String _base64;

  // Uint8List bytes;

  Future<void> _checkFaces() async {
    try {
      imageAdd = await ImagePicker.pickImage(
        // preferredCameraDevice: CameraDevice.front,
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
    } on Exception catch (_) {
      throw Exception("Error on server");
    }

    setState(() {
      if (imageAdd != null) {
        // showFace();

        addFace();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // setState(() {
    showFace();
    // loadFace();

    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      drawer: SafeArea(
          child: AppDrawer(
        selected: 'Profile',
      )),
      body: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              color: Color(0xffffe900),
              height: 250,
            ),
          ),
          Positioned(
            top: 50,
            left: 150,
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xffFDCF09),
              child: imageAdd != null
                  ? GestureDetector(
                      onTap: _checkFaces,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: imageAdd == null
                            ? Image.network(
                                'https://www.thermaxglobal.com/wp-content/uploads/2020/05/image-not-found.jpg')
                            : Image.file(imageAdd),

                        // Image.file(
                        //   imageAdd,
                        //   width: 100,
                        //   height: 100,
                        //   fit: BoxFit.fitHeight,
                        // ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _checkFaces,
                      child: base64All == null
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50)),
                              width: 100,
                              height: 100,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: base64All == null
                                  ? Image.asset('assets/logo.png')
                                  : Image.memory(bytesAll),

                              // Image.file(
                              //   imageAdd,
                              //   width: 100,
                              //   height: 100,
                              //   fit: BoxFit.fitHeight,
                              // ),
                            ),
                    ),
            ),
            // CircleAvatar(
            //   radius: 70.0,
            //   backgroundImage: NetworkImage(
            //       "https://cdn.imgbin.com/22/5/16/imgbin-computer-icons-user-profile-profile-ico-man-s-profile-illustration-M4UwtQzjtzd9LFP69LEzngUuR.jpg"),
            //   backgroundColor: Colors.transparent,
            // ),
          ),
          Positioned(
            top: 210,
            right: 10,
            left: 10,
            child: Container(
              height: 100,
              child: Card(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(loginJson['name']),
                  ),
                  Container(
                    child: Text(loginJson['department']),
                  ),
                ],
              )),
            ),
          ),
          Positioned(
            top: 350,
            right: 10,
            left: 10,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.phone),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      child: Text(loginJson['mobileNo']),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.email),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      child: Text(loginJson['emaiL_ADDRESS']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
                    // editUsers();
                  },
                  child: new Text('Please try again'),
                ),
              ],
            ),
          );
        });
  }

  Future loadFace() async {
    String base64Image = base64Encode(imageAdd.readAsBytesSync());

    photo = base64Image.toString();
  }

  Future addFace() async {
    _showLoading(true);

    try {
      var url = Uri.parse(
          'http://bajajuae.dyndns.org:8443/geofenceapi/api/Geofence/UpdatePhoto');
      String base64Image = base64Encode(imageAdd.readAsBytesSync());

      final headers = {"Content-type": "application/json"};
      final json =
          '{"userId": ${loginJson['userName']}, "PhotoId": ${loginJson['userName']}, "Photo": "$base64Image"}';
      final response = await post(url, headers: headers, body: json);
      if (response.statusCode == 200) {
        setState(() {
          base64All = base64Image;
          bytesAll = Base64Codec().decode(base64All);
        });

        Fluttertoast.showToast(
            msg: "Face successfully added",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        _showLoading(false);
      } else {
        Fluttertoast.showToast(
            msg: "Something wrong try again.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        _showLoading(false);
      }
    } catch (x) {
      print(x);
      _showError();
    }
  }

  Future showFace() async {
    Future.delayed(Duration.zero, () {
      _showLoading(true);
    });
    try {
      final response = await http.post(
        Uri.parse(
            'http://bajajuae.dyndns.org:8443/geofenceapi/api/Geofence/getphoto'),
        body: {
          'userId': loginJson['userName'],
        },
      );
      if (response.statusCode == 200) {
        // String base64Image = base64Encode(imageAdd.readAsBytesSync());

        // imageAdd = json.decode(response.body)['photo'];

        _base64 = json.decode(response.body)['photo'];

        if (_base64 == null) {
          _base64 =
              "iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAOVBMVEXz9Pa5vsq2u8jN0dnV2N/o6u7w8fTi5OnFydO+ws3f4ee6v8vY2+H29/jy9Pbu7/LJztbCx9HR1ty/NMEIAAACq0lEQVR42u3cYXaqMBBA4cyEgEAi4P4X+34oLSra9IA9E979FtDj7SAJUOocAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAqrQ3Y311iH5fsaktBTYn3d/Y2JljlM/orAR2IsdOHNqPFbY2TqKdXj/Orl/C24/sLHwV0ygiIv2466n0+kNlNFHYiohotfNyWKmIyKm2U9jsffqyU+gopLDMwiGE+sCFjRdV1SkOxyw8X2Rer6cNe2e7hfVJv3ddGg9YeNHlxrIPhyvs9GHvXB+sMJ2eLoDSsQrDwwhF/cFm+HiQikxvP+Prk63RwhSfCtt3i6J/fbK1Wlj9qvCiIjEd9yg9e32zZFotHPLPNOd55VyfotnVYsq9XVZ7fbvxsbviZx6kZ7+Y9toU7e7a/P1x+mI5qP3doRyLuraYlokxY4LrUzRcOPj56knaxmVMcP1XYfkKODW+VVWZqiHlTXBtisbvYgwhhKF22RNcmWLBd6JWJ/g8xXIL64u+eg5zl1huodfXj5riAQrPF333NG0xxVILvb5/YBhLKxzC8+XSD4mpqMLQt2F59hj158e+saDCFFrRacj9Dj5MsYTC0IuIfk9xzAoU7QopTKG93dq/7d3yJiiiVSqjMPTzJ25Dcu6cOUERjUUUzhP8mmLuBIsp/Jrg9Soq+OzAMgqXE7wm/uKvhIoovJ/gLxVQ+DTBwxVummABhRsnWEDhxgmaL9w8QfOFmydovTDlb11KLawopJBCCimk8E8Kbd+nGcJ2Q9F39fNRSKH5wtSZeyvI7/sm8O053MnCCOc/C/7Iu2vexIuyn3z/sLEQ6Orp4O+QOtf0HwrsGyOFrhP9QJ+qmUDnwtju/jp+PwZT/1chdNW+YuMAAAAAAAAAAAAAAAAAAAAAAAAAAACA/9s/LTI30XlcBHoAAAAASUVORK5CYII=";
        }
        // photo = base64Image.toString();

        bytes = Base64Codec().decode(_base64);

        _showLoading(false);
      } else {
        _showLoading(false);
        Fluttertoast.showToast(
            msg: "Something wrong try again.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (x) {
      print(x);
      _showError();
    }
  }
}
