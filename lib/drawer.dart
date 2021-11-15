import 'package:BajajTimeTracking/profile.dart';
import 'package:BajajTimeTracking/report.dart';
import 'package:BajajTimeTracking/users.dart';
import 'package:flutter/material.dart';

import 'addGeofence.dart';
import 'attendance.dart';
import 'geofences.dart';
import 'globle.dart';

class AppDrawer extends StatefulWidget {
  final String selected;

  const AppDrawer({Key key, this.selected}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: new Color(0xFF0062ac),
            ),
            accountName: Text(loginJson['name']),
            accountEmail: Text(loginJson['department']),
            currentAccountPicture: ClipRRect(
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
          // DrawerHeader(
          //   child: Padding(
          //       padding: const EdgeInsets.all(15.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children: <Widget>[
          //           Center(
          //             child: ClipRRect(
          //               borderRadius: BorderRadius.circular(50),
          //               child: Image.network(
          //                 'https://www.thermaxglobal.com/wp-content/uploads/2020/05/image-not-found.jpg',
          //                 width: 50,
          //                 height: 50,
          //                 fit: BoxFit.fitHeight,
          //               ),
          //             ),
          //           ),
          //           Container(
          //             child: Text(
          //               loginJson['name'],
          //             ),
          //           ),
          //           Container(
          //             child: Text(
          //               loginJson['department'],
          //             ),
          //           )
          //         ],
          //       )),
          //   decoration: BoxDecoration(
          //     color: Color(0xffffe900),
          //   ),
          // ),
          IgnorePointer(
            ignoring: loginJson['userName'] == "-1",
            child: ListTile(
              enabled: widget.selected != 'Attendance',
              leading: Icon(
                Icons.home,
                color: widget.selected == 'Attendance'
                    ? Color(0xff2f3194)
                    : Colors.grey,
              ),
              title: Text(
                "Attendance",
                style: TextStyle(
                    color: loginJson['userName'] == "-1"
                        ? Colors.red
                        : Colors.black),
              ),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => AttendanceMark()),
                      (Route<dynamic> route) => false);

                  // Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AttendanceMark(),
                  //   ),
                  // );
                });
              },
            ),
          ),
          IgnorePointer(
            ignoring: false,
            child: ListTile(
              enabled: widget.selected != 'Report',
              leading: Icon(
                Icons.apps,
                color: widget.selected == 'Report'
                    ? Color(0xff2f3194)
                    : Colors.grey,
              ),
              title: Text(
                "Reports",
              ),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Report()),
                      (Route<dynamic> route) => false);

                  // Navigator.pop(context);
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //     '/report', (Route<dynamic> route) => false);
                });

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => Report(),
                //   ),
                // );
              },
            ),
          ),
          ListTile(
            enabled: widget.selected != 'Profile',
            leading: Icon(
              Icons.people,
              color: widget.selected == 'Profile'
                  ? Color(0xff2f3194)
                  : Colors.grey,
            ),
            title: Text("My Profile"),
            onTap: () {
              setState(() {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Profile()),
                    (Route<dynamic> route) => false);
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //     '/profile', (Route<dynamic> route) => false);
              });

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => Profile(),
              //   ),
              // );
            },
          ),
          IgnorePointer(
            ignoring: loginJson['role_ID'] == 3,
            child: ListTile(
              enabled: widget.selected != 'AddGeofence',
              leading: Icon(
                Icons.location_on,
                color: widget.selected == 'AddGeofence'
                    ? Color(0xff2f3194)
                    : Colors.grey,
              ),
              title: Text(
                "Add Geofence",
                style: TextStyle(
                    color:
                        loginJson['role_ID'] == 3 ? Colors.red : Colors.black),
              ),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => AddGeofence()),
                      (Route<dynamic> route) => false);

                  // Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AddGeofence(),
                  //   ),
                  // );
                });
              },
            ),
          ),
          IgnorePointer(
            ignoring: loginJson['role_ID'] == 3,
            child: ListTile(
              enabled: widget.selected != 'Geofences',
              leading: Icon(
                Icons.feedback,
                color: widget.selected == 'Geofences'
                    ? Color(0xff2f3194)
                    : Colors.grey,
              ),
              title: Text(
                "Geofence List",
                style: TextStyle(
                    color:
                        loginJson['role_ID'] == 3 ? Colors.red : Colors.black),
              ),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Geofences()),
                      (Route<dynamic> route) => false);
                  // Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => Geofences(),
                  // ),
                  // );
                });
              },
            ),
          ),
          IgnorePointer(
            ignoring: loginJson['role_ID'] == 3,
            child: ListTile(
              enabled: widget.selected != 'Users',
              leading: Icon(
                Icons.monetization_on,
                color: widget.selected == 'Users'
                    ? Color(0xff2f3194)
                    : Colors.grey,
              ),
              title: Text(
                "Users List",
                style: TextStyle(
                    color:
                        loginJson['role_ID'] == 3 ? Colors.red : Colors.black),
              ),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Users()),
                      (Route<dynamic> route) => false);

                  // Navigator.pop(context);
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //     '/users', (Route<dynamic> route) => false);
                });

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => Users(),
                //   ),
                // );
              },
            ),
          ),
          Divider(
            thickness: 2,
            indent: 0,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.power_settings_new,
              color: Colors.grey,
            ),
            title: Text(
              "Logout",
            ),
            onTap: () {
              setState(() {
                logOut(context);
              });
            },
          ),
        ],
      ),
    );
  }
}
