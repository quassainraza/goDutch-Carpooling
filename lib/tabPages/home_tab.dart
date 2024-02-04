import 'package:go_dutch/group_chats/create_group/create_group.dart';
import 'package:go_dutch/Screens/ChatRoom.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clippy_flutter/triangle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:go_dutch/Screens/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_dutch/assistants/geofire_assistant.dart';
import 'package:go_dutch/models/active_nearby_users.dart';
import 'package:go_dutch/tabPages/call_screen.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';
import '/geometry.dart';
import '/location.dart';
import '/place.dart';
import '/blocs/app_blocs.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import '/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:requests/requests.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:go_dutch/mainScreens/main_screen.dart';

import 'dart:developer' as dev; // Debugger import

import 'package:lite_rolling_switch/lite_rolling_switch.dart'; // Toggle Switch

var pending_status = null;
var status_of_me = "Driver";
const kGoogleApiKey = "AIzaSyD63Vnqk2jrxqqxQSbNKBLhnHMXRBdeFCo";
Set<Polyline> polylines = Set<Polyline>();
List<LatLng> polylinecordinates = [];
PolylinePoints polylinePoints =
    PolylinePoints(); //Store path points to Draw polyline

Marker testmarker =
    Marker(markerId: MarkerId('fastMarker')); //////////Destination Marker
Place? mylocation;
double? gpslat, gpslong;

bool activenearbyuserkeys = false;

var ActiveUserId = [];

bool UserMode = false;

class GMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => appbloc(),
      child: MaterialApp(
        title: 'Flutter Google Maps Demo',
        home: MapSample(),
        debugShowCheckedModeBanner: false,
      ),
    );
    Widget button(function, IconData icon) {
      return FloatingActionButton(
        onPressed: function,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.blue,
        child: Icon(
          icon,
          size: 36.0,
        ),
      );
    }
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class MapSampleState extends State<MapSample> with WidgetsBindingObserver {
  var msgController = TextEditingController();
  var sourceController = TextEditingController();

  double rad = 500;

  ///Radius of Search for Users
  // @override
  // void dispose() {
  //   msgController.dispose();
  //   sourceController.dispose();
  //   super.dispose();
  // }

  late GoogleMapController newgoogleMapController;
  late final GoogleMapController controller;
  final Completer<GoogleMapController> _controller = Completer();

  CustomInfoWindowController _custominfowindow = CustomInfoWindowController();

  LocationPermission? locationPermission;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  //camera position at start

  blackThemeGoogleMap() /////////##########  Google Black Theme ##### \\\\\\\\\\\\\\\
  {
    newgoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  allowPermissionforlocation() async {
    locationPermission = await Geolocator.requestPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }
  }

  Map<String, dynamic>? userMap;
  UserisonlineNow() async {
    //Checks if the user is online or not From firbase database

    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    userCurrentPosition = pos;

    Geofire.initialize("ActiveUsers");
    Geofire.setLocation(
        currentfirebaseuser!.uid,
        userCurrentPosition!.latitude,
        userCurrentPosition!
            .longitude); //we are updating the position of current user in firebasse

    _kGooglePlexMarker = Marker(
        markerId: MarkerId('GooglePlex'),
        infoWindow: InfoWindow(title: mysource),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        position: LatLng(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude));

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(currentfirebaseuser!.uid)
        .child("Status");
    ref.set("Online");
    ref.onValue.listen((event) {});
  }

  UserisofflineByFaraz() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(currentfirebaseuser!.uid)
        .child("Status");
    ref.set("Offline");
  }

  UpdateUserLocationinRealtime() async {
    ///////////Updates User location regularly\\\\\\\\\\
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentPosition = position;
      if (isUserActive == true) {
        Geofire.setLocation(currentfirebaseuser!.uid,
            userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      }
      _kGooglePlexMarker = Marker(
          markerId: MarkerId('GooglePlex'),
          infoWindow: InfoWindow(title: mysource),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          position: LatLng(
              userCurrentPosition!.latitude, userCurrentPosition!.longitude));
      LatLng latLng =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      //  controller!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  Uint8List? markerImage;
  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  List<Map<String, dynamic>> membersList = [];
  UpdateOnlineUsers() async {
    var ActiveUsers = await getall();

    Uint8List UserIconType;

    // BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(ImageConfiguration(),"images/car1.png",);

// for(var i=0;i<ActiveUsers.length;i++)
//     {
//      double lat=ActiveUsers[i][0];
//      double lng=ActiveUsers[i][1];
//      if((_kGooglePlexMarker.position.longitude!=lng) && (_kGooglePlexMarker.position.latitude!=lat))
//           {
//             if(calculateDistance(lat, lng,_kGooglePlexMarker.position.latitude,_kGooglePlexMarker.position.longitude)<rad)
//               {
//                 DatabaseReference? ActiveUserData = FirebaseDatabase.instance.ref();

//                 final snapshotActiveData = await ActiveUserData.child('Users').child(ActiveUserId[i]).get();

//                 print(ActiveUserId[i]);

//                 dev.debugger();

//                 print(snapshotActiveData.value);

//               }
//           }
//     }

    //  setState(() {
    markers.clear();
    markers.add(_kGooglePlexMarker);
    markers.add(_fastMarker);
    double lat, lng;

    for (var i = 0; i < ActiveUsers.length; i++) {
      lat = ActiveUsers[i][0];
      lng = ActiveUsers[i][1];
      // dev.debugger();
      print("l=1 is" + lat.toString());
      print("l=11 is " + _kGooglePlexMarker.position.latitude.toString());
      print("l=2 is" + lng.toString());
      print("l=21 is " + _kGooglePlexMarker.position.longitude.toString());
      print(calculateDistance(lat, lng, _kGooglePlexMarker.position.latitude,
          _kGooglePlexMarker.position.longitude));
      if ((_kGooglePlexMarker.position.longitude != lng) &&
          (_kGooglePlexMarker.position.latitude != lat)) {
        if (calculateDistance(lat, lng, _kGooglePlexMarker.position.latitude,
                _kGooglePlexMarker.position.longitude) <
            rad) {
          DatabaseReference? ActiveUserData = FirebaseDatabase.instance.ref();
          // if()
          // {

          final snapshotActiveDataMode = await ActiveUserData.child('Users')
              .child(ActiveUserId[i])
              .child('mode')
              .get();
          print(snapshotActiveDataMode.value);

          if (snapshotActiveDataMode.value == "Driver") {
            UserIconType =
                await getBytesFromImage("images/topviewcar.png", 100);
          } else {
            UserIconType = await getBytesFromImage("images/funnyicon.png", 100);
          }

          final snapshotActiveDataName = await ActiveUserData.child('Users')
              .child(ActiveUserId[i])
              .child('name')
              .get();

          final snapshotActiveDataEmail = await ActiveUserData.child('Users')
              .child(ActiveUserId[i])
              .child('email')
              .get();

          print(ActiveUserId[i]);

          // dev.debugger();

          //adding online users markers
          setState(() {
            // dev.debugger();
            markers.add(Marker(

                //add third marker
                markerId: MarkerId(i.toString()),
                position: LatLng(lat, lng), //position of marker
                // infoWindow: InfoWindow(
                //   //popup info
                //   title: 'Marker Title Third ',
                //   snippet: 'My Custom Subtitle',
                // ),
                icon: BitmapDescriptor.fromBytes(UserIconType),
                onTap: () {
                  // dev.debugger();
                  // _custominfowindow.addInfoWindow!(
                  //   Container(
                  //     height: 200,
                  //     width: 200,
                  //     decoration: BoxDecoration(
                  //       color: Color.fromARGB(255, 29, 28, 25),
                  //       border: Border.all(color: Colors.blue),
                  //       borderRadius: BorderRadius.circular(10.0),
                  //     ),
                  //     child: Column(
                  //       // mainAxisAlignment: MainAxisAlignment.start,
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Container(
                  //           width: 200,
                  //           height: 100,
                  //           decoration: BoxDecoration(
                  //             // backgroundBlendMode: Colors.red,
                  //             // fit:BoxFit.fitWidth,
                  //             borderRadius:
                  //                 const BorderRadius.all(Radius.circular(10.0)),
                  //             color: Colors.white,
                  //           ),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  //   // Text("Satapindi"),

                  //   LatLng(lat, lng),
                  // );
                  // dev.debugger();
                  if (snapshotActiveDataName !=
                      currentfirebaseuser!.displayName) {
                    _custominfowindow.addInfoWindow!(
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_circle,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      snapshotActiveDataName.value.toString() +
                                          "\n" +
                                          snapshotActiveDataEmail.value
                                              .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Triangle.isosceles(
                            edge: Edge.BOTTOM,
                            child: Container(
                              color: Colors.blue,
                              width: 20.0,
                              height: 10.0,
                            ),
                          ),
                          ButtonBar(
                            children: [
                              RaisedButton(
                                  child:
                                      Text("ADD TO GROUP"), //new group creation
                                  textColor: Colors.white,
                                  color: Colors.green,
                                  onPressed: () async {
                                    Timer seconds120 = Timer(
                                        const Duration(seconds: 120),
                                        (() => print(
                                            "120 seconds done"))); //so now the timer is just useless
                                    var name =
                                        snapshotActiveDataName.value.toString();
                                    var email = snapshotActiveDataEmail.value
                                        .toString();
                                    var mode =
                                        snapshotActiveDataMode.value.toString();
                                    saveRideRequest(
                                        name, email, mode, status_of_me);
                                    FirebaseFirestore _firestore =
                                        FirebaseFirestore.instance;
                                    final FirebaseAuth _auth =
                                        FirebaseAuth.instance;
                                    //adding myself
                                    await _firestore
                                        .collection('users')
                                        .doc(_auth.currentUser!.uid)
                                        .get()
                                        .then((map) {
                                      setState(() {
                                        if (membersList.length == 0) {
                                          membersList.add({
                                            "name": map['name'],
                                            "email": map['email'],
                                            "uid": map['uid'],
                                            "isAdmin": true,
                                          });
                                        }
                                      });
                                    });

                                    //adding the selected user
                                    await _firestore
                                        .collection('users')
                                        .where("email",
                                            isEqualTo: snapshotActiveDataEmail
                                                .value
                                                .toString())
                                        .get()
                                        .then(
                                      (value) {
                                        setState(() {
                                          userMap = value.docs[0].data();
                                        });
                                      },
                                    ); //usermap bna lia ab check krte hen wo alreaddy list me to nh he so...

                                    bool isAlreadyExist = false;

                                    for (int i = 0;
                                        i < membersList.length;
                                        i++) {
                                      if (membersList[i]['uid'] ==
                                          userMap!['uid']) {
                                        isAlreadyExist = true;
                                      }
                                    }
                                    //  check status of receiver by usermap name
                                    Fluttertoast.showToast(msg: "before await");
                                    var target_status = "null";
                                    //listen
                                    FirebaseFirestore.instance
                                        .collection("Ride Requests")
                                        .doc(snapshotActiveDataName.value
                                            .toString())
                                        .snapshots()
                                        .listen((event) => {
                                              print(
                                                  "Target data: ${event.data()}"),
                                              if (event.data()!['status'] ==
                                                  "Accepted")
                                                {
                                                  seconds120.cancel(),
                                                  Fluttertoast.showToast(
                                                      msg: "YESS!!"),
                                                  print("Target data:OK!"),
                                                  target_status = "Accepted",
                                                  if (!isAlreadyExist)
                                                    {
                                                      setState(() async {
                                                        membersList.add({
                                                          "name":
                                                              userMap!['name'],
                                                          "email":
                                                              userMap!['email'],
                                                          "uid":
                                                              userMap!['uid'],
                                                          "isAdmin": false,
                                                        });

                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "User is added");
                                                        userMap = null;

                                                        // remove the data from collection field
                                                        setState(() async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "Ride Requests")
                                                              .doc(snapshotActiveDataName
                                                                  .value
                                                                  .toString())
                                                              .delete();
                                                        });
                                                      })
                                                    }
                                                  else
                                                    {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "User is alreaady in group"),
                                                      setState(() async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "Ride Requests")
                                                            .doc(
                                                                snapshotActiveDataName
                                                                    .value
                                                                    .toString())
                                                            .delete();
                                                      }),
                                                    }
                                                }
                                              else if (event
                                                      .data()!['status'] ==
                                                  "Rejected")
                                                {
                                                  seconds120.cancel(),
                                                  target_status = "Rejected",
                                                  Fluttertoast.showToast(
                                                      msg: "Rejected!!"),
                                                  setState(() async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            "Ride Requests")
                                                        .doc(
                                                            snapshotActiveDataName
                                                                .value
                                                                .toString())
                                                        .delete();
                                                  })
                                                }
                                              else if (event
                                                      .data()!['status'] ==
                                                  "Confused")
                                                {
                                                  // we will wait for 120 sec
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Setting 120 sec timer"),
                                                  seconds120
                                                      .cancel(), //removed the useless timer
                                                  seconds120 = Timer(
                                                      const Duration(
                                                          seconds: 120),
                                                      () => removeConfused(
                                                          snapshotActiveDataName
                                                              .value
                                                              .toString())),
                                                  if (seconds120.tick < 120)
                                                    {
                                                      Fluttertoast.showToast(
                                                          msg: seconds120.tick
                                                              .toString()),
                                                    }
                                                }

                                              // var rr = await FirebaseFirestore.instance
                                              //     .collection("Ride Requests")
                                              //     .doc("faraz")
                                              //     .get()
                                              //     .then((value) {
                                              //   target_status =
                                              //       value.data()!['Status'].toString();
                                            });

                                    // if (target_status == "Accepted") {
                                    //   if (!isAlreadyExist) {
                                    //     setState(() {
                                    //       membersList.add({
                                    //         "name": userMap!['name'],
                                    //         "email": userMap!['email'],
                                    //         "uid": userMap!['uid'],
                                    //         "isAdmin": false,
                                    //       });

                                    //       Fluttertoast.showToast(
                                    //           msg: "User is added");
                                    //       userMap = null;
                                    //     });
                                    //   } else {
                                    //     Fluttertoast.showToast(
                                    //         msg: "User is alreaady in group");
                                    //   }
                                    // } else if (target_status == "Rejected") {
                                    //   Fluttertoast.showToast(msg: "Rejected!!");
                                    //   //rejected
                                    // }
                                  }),
                              RaisedButton(
                                child: Text("START  GROUP CHAT"),
                                textColor: Colors.white,
                                color: Colors.green,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CreateGroup(
                                      membersList: membersList,
                                    ),
                                  ),
                                ),
                              ),
                              RaisedButton(
                                child: Text("Private chat"),
                                textColor: Colors.white,
                                color: Colors.green,
                                onPressed: () async {
                                  FirebaseFirestore _firestore =
                                      FirebaseFirestore.instance;
                                  final FirebaseAuth _auth =
                                      FirebaseAuth.instance;
                                  await _firestore
                                      .collection('users')
                                      .where("email",
                                          isEqualTo: snapshotActiveDataEmail
                                              .value
                                              .toString())
                                      .get()
                                      .then(
                                    (value) {
                                      setState(() {
                                        userMap = value.docs[0].data();
                                      });

                                      String roomId = chatRoomId(
                                          _auth.currentUser!.displayName!,
                                          userMap!['name']);

                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ChatRoom(
                                            chatRoomId: roomId,
                                            userMap: userMap!,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  userMap =
                                      null; //so that the value is not repeated again
                                },
                              )
                            ],
                          )
                        ],
                      ),
                      LatLng(ActiveUsers[i][0], ActiveUsers[i][1]),
                    );
                  }
                }
                // icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
                ));
          });
          print("Distance Entered");
        } else {
          print("Should not enter");
        }
      }
    }

    // markers.add(Marker( //add second marker
    //   markerId: MarkerId("rxe"),
    //   position: LatLng(33.564043, 73.039859), //position of marker
    //   infoWindow: InfoWindow( //popup info
    //     title: 'Marker Title Second ',
    //     snippet: 'My Custom Subtitle',
    //   ),
    //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    // ));

    // checks radius
    // if(calculateDistance(33.567668, 73.052357,_kGooglePlexMarker.position.latitude,_kGooglePlexMarker.position.longitude)<rad)
    // {

    // }

    // }
    // );
  }

  void removeConfused(String id) {
    setState(() async {
      await FirebaseFirestore.instance
          .collection("Ride Requests")
          .doc(id)
          .delete();
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    ///////////////////////########### calculate Distance to be displayed within radius.#########\\\\\\\\\\\\\\\\\
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // in meters
  }

  Future<Uint8List> getBytesFromImage(String path, int width) async {
    ByteData imageData = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        imageData.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  UserisOfflineNow() {
    ////////// User location not shared with online users\\\\\\\\\\
    Geofire.removeLocation(currentfirebaseuser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(currentfirebaseuser!.uid)
        .child("Status");
    // dev.debugger();

    ref.onDisconnect();

    ref.remove();
    // dev.debugger();
    ref = null;
    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }

  var address;
  static String latitude =
      ""; //to declare any variable just statically declare here
  //and use in downward init function and initilize it there simple
  static String longitude = "";
  static Set<Circle> mycircles = Set.from([
    Circle(circleId: CircleId('1'))
  ]); ////################## Circle to be displayed on map for radius
  static Marker _kGooglePlexMarker = Marker(
      markerId:
          MarkerId('GooglePlex')); ////################## Marker for source
  static Marker _fastMarker = Marker(
      markerId:
          MarkerId('fastMarker')); ////################## Marker for Destination
  //made static because giving initilzer error
  late StreamSubscription locationSubscription;

  ///Event Listner for location
  late StreamSubscription boundsSubscription;

  ///Event Listner for location
  final _locationController = TextEditingController();

  /// Text Field controller
  Position? userCurrentPosition;
  static String mysource = "";
  String statustext = "Now Offline";
  Color statusbuttoncolor = Colors.grey;
  bool isUserActive = false;
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  Timer? timer;

  @override
  void dispose() {
    streamSubscription!.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    msgController.dispose();
    sourceController.dispose();
    timer?.cancel();
    // UserisOfflineNow();
    if (timer!.isActive) {
      print("timer is active");
    }
    debugPrint("Disposed");
    polylines.clear();
    polylinecordinates.clear();
    super.dispose();
  }

  @override
  void initState() {
    UserisofflineByFaraz();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    polylines.clear();
    Map<String, dynamic>? d;
    polylinecordinates.clear();
    allowPermissionforlocation();
    FirebaseFirestore.instance
        .collection("Ride Requests")
        .doc(currentfirebaseuser!.displayName)
        .snapshots()
        .listen(
          (event) => {
            print("current data: ${event.data()}"),
            //we will navigate to Call screen if data is not null
            d = event.data(),
            if (event.data()!['Status'] == "Accepted")
              {
                pending_status = "Accepted",
              }
            else if (event.data()!['Status'] == "Rejected")
              {
                pending_status = "Rejected",
              }
            else if (event.data() != null)
              {
                //before navigating also check that if  this user is already added in the group of sender's memberlist dont navigate to pickup screen and make the status accepted
                //we can't use membersList
                //we have to use member list of the other user
                //so fetching from firebase

                for (int i = 0; i < event.data()!['Member List'].length; i++)
                  {
                    //check if the email of receiver exists in member list

                    if (event.data()!['Member List'][i]['email'] ==
                        event.data()![
                            'Req receiver Email']) // it means i am added in the user's member list
                      {
                        pending_status = "Accepted",
                      }
                  },
                if (pending_status != "Accepted")
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => PickupScreen(data: d))))
                  }
              }
          },
          onError: (error) => print("Listen failed: $error"),
        );
    readCurrentOnlineUserInfo();
    timer =
        Timer.periodic(Duration(seconds: 10), (Timer t) => UpdateOnlineUsers());
    final applicationBloc = Provider.of<appbloc>(context, listen: false);
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _locationController.text = place.name;
        _goToTheDestination(place);
      } else
        _locationController.text = "";
    });
    getLocation();
  } //to run getlocation when code starts

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isUserActive == true) {
        UserisonlineNow(); //this makes me online which simply means when you are on foreground you will be active
      }
    } else {
      UserisofflineByFaraz();
    }
  }

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300.0;
  bool drawerOpen = true;
  late DatabaseReference rideRequestref;
  void saveRideRequest(name, email, receiverMode, senderMode) async {
    var pickup = _kGooglePlexMarker.position;
    var dropoff = _fastMarker.position;
    Map pickuplocation = {
      "latitude": pickup.latitude,
      "longitude": pickup.longitude
    };
    Map dropofflocation = {
      "latitude": dropoff.latitude,
      "longitude": dropoff.longitude
    };
    final doc = FirebaseFirestore.instance
        .collection("Ride Requests")
        .doc(name); //doc on the name of receiver

    await doc.set({
      "Req Sender name": currentfirebaseuser!.displayName,
      "Req Sender Email": currentfirebaseuser!.email,
      "Req sender status": senderMode, //if true then you are passenger else
      "Req receiver Name": name,
      "Req receiver Email": email,
      "Req Receiver mode": receiverMode,
      "pickup": pickuplocation,
      "dropoff": dropofflocation,
      "created_at": DateTime.now().toString(),
      "Member List": membersList,
      "status": "",
    });
  }

  getLocation() async {
    var pos = determinePosition(); //if pos is error then
    pos.catchError(print);
    //if determinePOSITION goes in error we will handle in upper else

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    userCurrentPosition = position;
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    final CameraPosition cameraPosition = CameraPosition(
        target:
            latLngPosition, //going to that cordinates which were given by my function of geolocation
        zoom: 14);
    controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String mapKey = "AIzaSyC9QV9zItVaaYnQWHDzo-6mA5oRCCRqaaM";
    //var param = LatLng(position.latitude, position.longitude);
    var karam1 = position.latitude;
    var karam2 = position.longitude;
    String kar1 = karam1.toString();
    String kar2 = karam2.toString();
    String param;
    param = kar1 + "," + kar2;
    String autoCompleteUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$param&key=$mapKey";
    var res = await http.get(Uri.parse(autoCompleteUrl));
    var json = convert.jsonDecode(res.body);
    mysource = json['results'][0]['formatted_address'];
    // print(json['results'][0]['formatted_address'].runtimeType);
    setState(() {
      latitude = '${position.latitude}';
      longitude =
          '${position.longitude}'; //latitude and longitude variables are getting updated here
      final lat = latitude;
      final long = longitude;
      mycircles = Set.from([
        Circle(
          circleId: CircleId('1'),
          center: LatLng(double.parse(lat), double.parse(long)),
          radius: rad,
          fillColor: Color.fromARGB(255, 33, 141, 132).withOpacity(0.5),
          strokeColor: Colors.blue.shade100.withOpacity(0.1),
        )
      ]);

      gpslat = double.parse(lat);
      gpslong = double.parse(long);

      _kGooglePlexMarker = Marker(
        markerId: MarkerId('GooglePlex'),
        infoWindow: InfoWindow(title: mysource),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        position: LatLng(double.parse(latitude), double.parse(longitude)),
      );

      testmarker = Marker(
        ///////###### setting marker of source and destination
        markerId: MarkerId(""),
        infoWindow: InfoWindow(),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(double.parse(latitude) + 0.05,
            double.parse(longitude)), //hard coded for fast rn
      );

      _fastMarker = Marker(
        markerId: MarkerId('Fast_Marker'),
        // infoWindow: InfoWindow(title: 'My Destination'),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(33.6561535, 73.0135573), //hard coded for fast rn
      );
    });

    initializeGeofireListner();
  }

  readCurrentOnlineUserInfo() async {
    currentfirebaseuser = firebaseAuth.currentUser;
    await FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(currentfirebaseuser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo.id = (snap.snapshot.value as dynamic)["id"];
        userModelCurrentInfo.name = (snap.snapshot.value as dynamic)['name'];
        userModelCurrentInfo.phone = (snap.snapshot.value as dynamic)["phone"];
        userModelCurrentInfo.email = (snap.snapshot.value as dynamic)["email"];

        userModelCurrentInfo.cnic = (snap.snapshot.value as dynamic)["cnic"];
        userModelCurrentInfo.vehicle_model = (snap.snapshot.value
            as dynamic)["vehicle_details"]["vehicle_model"];
        userModelCurrentInfo.vehicle_color = (snap.snapshot.value
            as dynamic)["vehicle_details"]["vehicle_color"];
        userModelCurrentInfo.vehicle_number = (snap.snapshot.value
            as dynamic)["vehicle_details"]["vehicle_number"];
        print("User id--------------------------------------------------: ");
        print(userModelCurrentInfo.id);
        print("\n User name: ");
        print(userModelCurrentInfo.name);
      }
    });
  }

  initializeGeofireListner() {
    Geofire.initialize("ActiveUsers"); ////////####### GetsActive users data
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 0.6)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            ActiveNearbyUsers activeNearbyUser = ActiveNearbyUsers();
            activeNearbyUser.loclat = map['latitude'];
            activeNearbyUser.loclong = map['longitude'];
            activeNearbyUser.userid = map['key'];
            GeofireAssistant.activenearbyuserslist.add(activeNearbyUser);
            if (activenearbyuserkeys == true) {
              displayOnlineNearByUsersOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeofireAssistant.removeuserfromthelist(map['key']);
            break;

          case Geofire.onKeyMoved:
            ActiveNearbyUsers activeNearbyUser = ActiveNearbyUsers();
            activeNearbyUser.loclat = map['latitude'];
            activeNearbyUser.loclong = map['longitude'];
            activeNearbyUser.userid = map['key'];
            GeofireAssistant.updatenearbyActiveuserslocation(activeNearbyUser);
            displayOnlineNearByUsersOnMap();
            break;

          //display online nerbyusers
          case Geofire.onGeoQueryReady:
            displayOnlineNearByUsersOnMap();

            break;
        }
      }

      setState(() {});
    });
  }

  displayOnlineNearByUsersOnMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();
      Set<Marker> usersMarkers = Set<Marker>();
      for (ActiveNearbyUsers eachUser
          in GeofireAssistant.activenearbyuserslist) {
        LatLng eachUseractivepos = LatLng(eachUser.loclat!, eachUser.loclong!);

        Marker marker = Marker(
          markerId: MarkerId(eachUser.userid!),
          position: eachUseractivepos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          rotation: 360,
        );
        usersMarkers.add(marker);
      }
      setState(() {
        markersSet = usersMarkers;
      });
    });
  }

  void setPolylines() async {
    ///////////////////////########### Use latitude and longitude of source and destination to create polyline #########\\\\\\\\\\\\\\\\\
    // print("Source lat is ");
    // print(_kGooglePlexMarker.position.latitude);
    // print("Source lang is :");
    // print(_kGooglePlexMarker.position.longitude);
    // print("Fast lat");
    // print(_fastMarker.position.latitude);
    // print("fast lang is ");
    // print(_fastMarker.position.longitude);

    PolylineResult presult = await polylinePoints.getRouteBetweenCoordinates(
        ////// get the Shortest route between source and destination And adds polypoints to the polypoint
        ///// list this is used to draw polyline.
        kGoogleApiKey,
        PointLatLng(_kGooglePlexMarker.position.latitude,
            _kGooglePlexMarker.position.longitude), //source
        PointLatLng(
            _fastMarker.position.latitude, _fastMarker.position.longitude));

    if (presult.status == 'OK') {
      print(
          "OKOKOKOKOKOKOOKOKOKOKOKOKKOKOKO\nOKOKOKOKOKOKOKOKOKOKOKOKOKOKOKO\nOKOKOKOKOKOKOKOKOKOKOOKOKOKOKOKOKOKOKKKOKOKOK"); //////////////////Debugging!!!!!!!!!!!!
      presult.points.forEach((PointLatLng point) {
        polylinecordinates.add(LatLng(point.latitude, point.longitude));
      });

      double totalDistance = 0;
      for (var i = 0; i < polylinecordinates.length - 1; i++) {
        totalDistance += calculateDistance(
            polylinecordinates[i].latitude,
            polylinecordinates[i].longitude,
            polylinecordinates[i + 1].latitude,
            polylinecordinates[i + 1].longitude);
      }

      print("DISTANCE"); //////////////////Debugging!!!!!!!!!!!!
      print(totalDistance);

      setState(() {
        polylines.add(Polyline(
          width: 5,
          polylineId: PolylineId('PolyLine'),
          color: Color.fromARGB(255, 38, 219, 192),
          points: polylinecordinates,
        ));
      });
    } else {
      print(
          "NOT\nOKOKOKOKOKOKOOKOKOKOKOKOKKOKOKO\nOKOKOKOKOKOKOKOKOKOKOKOKOKOKOKO\nOKOKOKOKOKOKOKOKOKOKOOKOKOKOKOKOKOKOKKKOKOKOK"); //////////////////Debugging!!!!!!!!!!!!
    }
  }

  final Set<Marker> markers = new Set();
  static const LatLng showLocation = const LatLng(27.7089427, 85.3086209);

  Set<Marker> getmarkers() {
    //markers to place on map
    setState(() {
      markers.add(_kGooglePlexMarker);
      markers.add(_fastMarker);
      //add more markers here
    });

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final applicationbloc =
        Provider.of<appbloc>(context); /////////Google Api initiated
    print(Geolocator.distanceBetween(
        _kGooglePlexMarker.position.latitude,
        _kGooglePlexMarker.position.longitude,
        testmarker.position.latitude,
        testmarker.position.longitude));

    return new Scaffold(
        // appBar: AppBar(
        //   title: Text("GoDutch"),
        // ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: ((context) => HomeScreen())));
            //+ hide the bottom navigation bar
          },
          child: Icon(Icons.message),

          // elevation: ,
        ),
        drawerEnableOpenDragGesture: false,
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Header',
                  // style: textTheme.headline6,
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
              ),
              ListTile(
                title: Text('List1'),
              ),
              ListTile(
                title: Text('List2'),
              ),
              ListTile(
                title: Text('List3'),
              ),
              ListTile(
                // leading: Icon(Icons.favorite),
                // title: Text('Item 1'),

                title: LiteRollingSwitch(
                    value: UserMode,
                    textOn: 'User',
                    textOff: 'Driver',
                    colorOn: Colors.blueGrey,
                    colorOff: Colors.green,
                    iconOn: Icons.person,
                    iconOff: Icons.car_rental_outlined,
                    onChanged: (bool pos) {
                      dev.debugger();
                      switchModes();
                    }),

                subtitle: Column(
                  children: <Widget>[
                    Text('Change Mode'),
                    ElevatedButton(
                      onPressed: () {
                        // Respond to button press
                      },
                      child: Text('CONTAINED BUTTON'),
                    )
                  ],
                ),
                // selected: _selectedDestination == 0,
                // onTap: () => selectDestination(0),
              ),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        key: homeScaffoldKey,
        body: Stack(
          children: <Widget>[
            GoogleMap(
              //// Displayed Google Map
              onLongPress: addmarker,
              markers: getmarkers(),

              /// Adds marker on Google Map
              polylines: polylines,
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onTap: (position) {
                //  dev.debugger();
                _custominfowindow.hideInfoWindow!();
              },
              onCameraMove: (position) {
                _custominfowindow.onCameraMove!();
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                newgoogleMapController = controller;
                _custominfowindow.googleMapController = controller;
                //black theme for google maps
                blackThemeGoogleMap();
                setPolylines();
              },
              padding: EdgeInsets.only(
                top: 150.0,
              ),
              myLocationEnabled: true, //for blue dot
              circles: mycircles,
            ),

            // IconButton(onPressed:() => homeScaffoldKey.currentState!.openDrawer(), icon: Icon(Icons.menu,color:Colors.white)),

            CustomInfoWindow(
              controller: _custominfowindow,
              height: 200,
              width: 500, //info window size
              offset: 0,
            ),
            Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: LiteRollingSwitch(
                      value: UserMode,
                      textOn: 'User',
                      textOff: 'Driver',
                      colorOn: Colors.blueGrey,
                      colorOff: Colors.green,
                      iconOn: Icons.person,
                      iconOff: Icons.car_rental_outlined,
                      onChanged: (bool pos) {
                        // dev.debugger();
                        switchModes();
                      }),
                ),
              ],
            ),

            if (statustext != "Now Online")
              Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black38,
              )
            else
              Container(),
            Positioned(
              top: statustext != "Now Online"
                  ? MediaQuery.of(context).size.height * 0.45
                  : 200,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (isUserActive != true) //offline
                      {
                        UserisonlineNow();
                        UpdateUserLocationinRealtime();

                        setState(() {
                          statustext = "Now Online";
                          isUserActive = true;
                        });
                        Fluttertoast.showToast(msg: "You are online now!");
                      } else {
                        UserisOfflineNow();
                        UserisofflineByFaraz();
                        setState(() {
                          statustext = "Now Offline";
                          isUserActive = false;
                          UserisofflineByFaraz();
                        });
                        Fluttertoast.showToast(msg: "You are offline now!");
                      }
                    },
                    //now checking app life cycle to make it offline
                    //using this https://www.google.com/search?q=how+to+check+if+application+is+terminated+in+flutter&rlz=1C1SQJL_enPK1008PK1008&oq=how+to+check+if+application+is+terminated+in+flutter&aqs=chrome..69i57j33i21j33i22i29i30l2.11033j0j7&sourceid=chrome&ie=UTF-8#kpvalbx=_PEQHY7-1FZTdkwWbpqvQCg14

                    style: ElevatedButton.styleFrom(
                        primary: statusbuttoncolor,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        )),
                    child: statustext != "Now Online"
                        ? Text(
                            statustext,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.phonelink_ring,
                            color: Colors.white,
                            size: 26,
                          ),
                  )
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    SizedBox(height: 80),
                    Container(
                      child: TextField(
                        //Destination Test Fields
                        onChanged: (value) {
                          applicationbloc.searchPlaces(value);
                        },
                        controller: msgController,
                        style: TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                            hintText: 'Destination',
                            hintStyle: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 24),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Color.fromARGB(255, 188, 188, 188),
                            suffixIcon: msgController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        msgController.clear();
                                      });
                                    },
                                    icon: Icon(Icons.clear_outlined),
                                  )
                                : null),
                      ),
                    ),
                    Container(
                      //Slider to change the radius
                      child: SliderTheme(
                        data: SliderThemeData(
                          valueIndicatorColor: Color.fromARGB(255, 255, 0, 0),
                          activeTrackColor: Color.fromARGB(255, 38, 219, 192),
                          inactiveTrackColor:
                              Color.fromARGB(255, 255, 255, 255),
                          inactiveTickMarkColor:
                              Color.fromARGB(255, 255, 255, 255),
                          thumbColor: Color.fromARGB(255, 38, 219, 192),
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape(),
                          // thumbShape:
                        ),
                        child: SizedBox(
                          width: 250,
                          child: Slider(
                            divisions: 10,
                            value: rad.toDouble(),
                            min: 0,
                            max: 600,
                            label: rad.round().toString(),
                            onChanged: (double value) => setState(() {
                              rad = value;
                              mycircles = Set.from([
                                Circle(
                                  circleId: CircleId('1'),
                                  center: LatLng(gpslat!, gpslong!),
                                  radius: rad,
                                  fillColor: Color.fromARGB(255, 33, 141, 132)
                                      .withOpacity(0.5),
                                  strokeColor:
                                      Colors.blue.shade100.withOpacity(0.1),
                                )
                              ]);
                            }),
                          ),
                        ),
                      ),
                    ),
                    if (applicationbloc.searchResults.length != 0)
                      Container(
                        height: 0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.6),
                          backgroundBlendMode: BlendMode.darken,
                        ),
                      ),
                    if (applicationbloc.searchResults.length != 0)
                      SingleChildScrollView(
                        child: Container(
                          height: 300,
                          child: ListView.builder(

                              ///shows Search List
                              itemCount: applicationbloc.searchResults
                                  .length, //now search results can be none so
                              itemBuilder: ((context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(
                                      Icons.pin_drop,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    applicationbloc
                                        .searchResults[index].description,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 253, 253, 253)),
                                  ),
                                  onTap: () {
                                    //make textfields null
                                    polylinecordinates = [];
                                    // setPolylines();
                                    msgController.clear();
                                    applicationbloc.setSelectedLocation(
                                        applicationbloc
                                            .searchResults[index].placeId);
                                  },
                                );
                              })),
                        ),
                      ),
                  ],
                ))
          ],
        )

        // Container(
        // height: (MediaQuery.of(context).size.height),
        // // height: 400,
        // child: GoogleMap(                                               //// Displayed Google Map
        //   onLongPress: addmarker,
        //   markers: getmarkers(),   /// Adds marker on Google Map
        //   polylines: polylines,
        //   mapType: MapType.normal,
        //   initialCameraPosition: _kGooglePlex,
        //   onMapCreated: (GoogleMapController controller) {
        //     _controller.complete(controller);
        //     newgoogleMapController = controller;
        //     //black theme for google maps
        //     blackThemeGoogleMap();
        //       setPolylines();
        //   },
        //   myLocationEnabled: true, //for blue dot
        //   circles: mycircles,
        // )

        // ),

        // Padding(
        //   padding: const EdgeInsets.all(8),

        // child:Column(

        //   children: [

        //     Container(
        //       child: TextField(                                                                    //////////////Source TExt Field
        //         onChanged: (value) {
        //           applicationbloc.searchPlaces(value);
        //         },
        //         controller: sourceController,
        //         style: TextStyle(fontSize: 24),

        //         decoration: InputDecoration(

        //             hintText: 'Starting Point',
        //             hintStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        //             border: InputBorder.none,
        //             filled: true,

        //             fillColor: Color.fromARGB(255, 188, 188, 188),

        //              suffixIcon: sourceController.text.isNotEmpty
        //                 ? IconButton(
        //                     onPressed: (){
        //                       setState(() {
        //                         sourceController.clear();
        //                       });
        //                     },
        //                     icon: Icon(Icons.clear_outlined),
        //                     )
        //                 :null
        //             ),
        //       ),
        //     ),

        //     SizedBox(height: 10),

        //       Container(
        //         child: TextField(                                          //Destination Test Fields
        //           onChanged: (value) {
        //             applicationbloc.searchPlaces(value);
        //           },
        //             controller: msgController,
        //             style: TextStyle(fontSize: 24),
        //             decoration: InputDecoration(
        //             hintText: 'Destination',
        //             hintStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        //             border: InputBorder.none,

        //             filled: true,
        //             fillColor: Color.fromARGB(255, 188, 188, 188),
        //             suffixIcon: msgController.text.isNotEmpty
        //                 ? IconButton(
        //                     onPressed: (){
        //                       setState(() {
        //                         msgController.clear();
        //                       });
        //                     },
        //                     icon: Icon(Icons.clear_outlined),
        //                     )
        //                 :null
        //             ),
        //         ),
        //       ),

        // Container(                                                    //Slider to change the radius
        //   child: SliderTheme(
        //     data: SliderThemeData(

        //       valueIndicatorColor: Colors.green,
        //       activeTrackColor:Colors.green,
        //       inactiveTrackColor: Colors.green.shade100,
        //       inactiveTickMarkColor: Colors.red,
        //       thumbColor: Colors.green,
        //       valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        //       // thumbShape:

        //       ),
        //     child: SizedBox(
        //       width: 250,
        //       child: Slider(

        //         divisions: 10,
        //         value: rad.toDouble(),
        //         min: 0,
        //         max:600,

        //         label: rad.round().toString(),
        //         onChanged: (double value)=> setState((){
        //               rad=value;
        //                 mycircles = Set.from([
        //             Circle(
        //               circleId: CircleId('1'),
        //               center: LatLng(gpslat!, gpslong!),
        //               radius: rad,
        //               fillColor: Color.fromARGB(255, 33, 141, 132).withOpacity(0.5),
        //               strokeColor:  Colors.blue.shade100.withOpacity(0.1),
        //             )
        //           ]);
        //         }
        //         ),
        //       ),
        //     ),
        //   ),
        // ),

        // TextButton(
        //   onPressed:() {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const radius()),
        //     );
        //   },
        //   child: Text("Set Radius"))
        //   ],
        // ),
        // ),

        // Stack(
        //   children:<Widget>[

        // Container(
        //     height: (MediaQuery.of(context).size.height-20),
        //     // height: 400,
        //     child: GoogleMap(                                               //// Displayed Google Map
        //       onLongPress: addmarker,
        //       markers: getmarkers(),   /// Adds marker on Google Map
        //       polylines: polylines,
        //       mapType: MapType.normal,
        //       initialCameraPosition: _kGooglePlex,
        //       onMapCreated: (GoogleMapController controller) {
        //         _controller.complete(controller);
        //         newgoogleMapController = controller;
        //         //black theme for google maps
        //         blackThemeGoogleMap();
        //           setPolylines();
        //       },
        //       myLocationEnabled: true, //for blue dot
        //       circles: mycircles,

        //     )
        //     ),

        //     Padding(
        //       padding: const EdgeInsets.all(8),

        // child:Column(

        //   children: [

        // Container(
        //   child: TextField(                                                                    //////////////Source TExt Field
        //     onChanged: (value) {
        //       applicationbloc.searchPlaces(value);
        //     },
        //     controller: sourceController,
        //     style: TextStyle(fontSize: 24),

        //     decoration: InputDecoration(

        //         hintText: 'Starting Point',
        //         hintStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        //         border: InputBorder.none,
        //         filled: true,

        //         fillColor: Color.fromARGB(255, 188, 188, 188),

        //          suffixIcon: sourceController.text.isNotEmpty
        //             ? IconButton(
        //                 onPressed: (){
        //                   setState(() {
        //                     sourceController.clear();
        //                   });
        //                 },
        //                 icon: Icon(Icons.clear_outlined),
        //                 )
        //             :null
        //         ),
        //   ),
        // ),

        // SizedBox(height: 10),

        // Container(
        //     child: TextField(                                          //Destination Test Fields
        //       onChanged: (value) {
        //         applicationbloc.searchPlaces(value);
        //       },
        //         controller: msgController,
        //         style: TextStyle(fontSize: 24),
        //         decoration: InputDecoration(
        //         hintText: 'Destination',
        //         hintStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        //         border: InputBorder.none,

        //         filled: true,
        //         fillColor: Color.fromARGB(255, 188, 188, 188),
        //         suffixIcon: msgController.text.isNotEmpty
        //             ? IconButton(
        //                 onPressed: (){
        //                   setState(() {
        //                     msgController.clear();
        //                   });
        //                 },
        //                 icon: Icon(Icons.clear_outlined),
        //                 )
        //             :null
        //         ),
        //     ),
        //   ),

        // if (applicationbloc.searchResults.length != 0)
        //   Container(
        //     height: 300,
        //     width: double.infinity,
        //     decoration: BoxDecoration(
        //       color: Colors.black.withOpacity(.6),
        //       backgroundBlendMode: BlendMode.darken,
        //     ),
        //   ),
        // if (applicationbloc.searchResults.length != 0)
        //   Container(
        //     height: 100,
        //     child: ListView.builder(                                         ///shows Search List
        //         itemCount: applicationbloc.searchResults
        //             .length, //now search results can be none so
        //         itemBuilder: ((context, index) {
        //           return ListTile(
        //             leading: CircleAvatar(
        //               child: Icon(
        //                 Icons.pin_drop,
        //                 color: Colors.white,
        //               ),
        //             ),
        //             title: Text(
        //               applicationbloc.searchResults[index].description,
        //               style: TextStyle(
        //                   color: Color.fromARGB(255, 253, 253, 253)),
        //             ),
        //             onTap: () {
        //               //make textfields null
        //               polylinecordinates = [];
        //               // setPolylines();
        //               msgController.clear();
        //               applicationbloc.setSelectedLocation(
        //                   applicationbloc.searchResults[index].placeId);
        //             },
        //           );
        //         })),
        //   ),
        // if(statustext!="Now Online")
        //   Container(
        //     height: MediaQuery.of(context).size.height,
        //     width: double.infinity,
        //     color: Colors.black38,

        //   )
        // else
        //   Container(),
        // Positioned(
        //   top: statustext != "Now Online" ? MediaQuery.of(context).size.height * 0.45 : 25,
        //   left: 0,
        //   right: 0,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       ElevatedButton(
        //         onPressed:(){

        //           if(isUserActive != true)//offline
        //              {
        //
        //             UpdateUserLocationinRealtime();

        //             setState(() {
        //               statustext = "Now Online";
        //               isUserActive= true;
        //             });
        //             Fluttertoast.showToast(msg: "You are online now!");
        //           }
        //           else{
        //             UserisOfflineNow();
        //             setState(() {
        //               statustext = "Now Offline";
        //               isUserActive= false;
        //             });
        //             Fluttertoast.showToast(msg: "You are offline now!");

        //           }
        //         },

        //         style: ElevatedButton.styleFrom(
        //             primary: statusbuttoncolor,
        //             padding:const EdgeInsets.symmetric(horizontal: 18),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(26),
        //             )
        //         ),
        //         child: statustext != "Now Online" ?
        //         Text(
        //           statustext,
        //           style: const TextStyle(
        //             fontSize: 16.0,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.white,

        //           ),
        //         ):
        //         const Icon(
        //           Icons.phonelink_ring,
        //           color: Colors.white,
        //           size: 26,
        //         ),

        //       )
        //     ],
        //   ),
        // )

        //   ],
        // ),

        // ]

        // ),

        );
    /*floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('My Location'),
        icon: Icon(Icons.location_searching),
      )*/
  }

  void addmarker(LatLng pos) {
    //////////////////////////////##################### Sets marker for the destination.###############################/////////////////////////
    setState(() {
      _fastMarker = Marker(
          markerId: MarkerId('Fast_Marker'),
          // infoWindow: InfoWindow(title: 'My Destination'),
          icon: BitmapDescriptor.defaultMarker,
          position: pos, //hard coded for fast rn
          onTap: () {
            dev.debugger();
            // dev.debugger();
            _custominfowindow.addInfoWindow!(
              Container(
                height: 300,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 100,
                      decoration: BoxDecoration(
                        // backgroundBlendMode: Colors.red,
                        // fit:BoxFit.fitWidth,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ),
              // Text("Satapindi"),

              pos,
            );
          });
    });
    polylinecordinates = [];
    setPolylines();
  }

  Future<void> _goToTheLake() async {
    ////////////////////////////////############# Get Current GPS location of the User###############\\\\\\\\\\\\\\\\\\\\\
    getLocation();
  }

  Future<void> _goToTheDestination(Place place) async {
    ////////////////////////////////############# Animate Camera toward destination ###############\\\\\\\\\\\\\\\\\\\\\
    final GoogleMapController controller = await _controller.future;
    final CameraPosition destination = CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 14.0);
    controller.animateCamera(CameraUpdate.newCameraPosition(destination));

    _fastMarker = Marker(
        markerId: MarkerId(place.name),
        // infoWindow: InfoWindow(title: place.name),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(place.geometry.location.lat,
            place.geometry.location.lng), //hard coded for fast rn
        onTap: () {
          dev.debugger();
          // dev.debugger();
          _custominfowindow.addInfoWindow!(
            Container(
              height: 900,
              width: 600,
              decoration: BoxDecoration(
                color: Colors.yellow,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      // backgroundBlendMode: Colors.red,
                      // fit:BoxFit.fitWidth,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            ),
            // Text("Satapindi"),

            LatLng(place.geometry.location.lat, place.geometry.location.lng),
          );
        });

    mylocation = place;

    Marker(markerId: MarkerId('fastMarker'));
    // so hum screen ko legae +
    //humne udhar marker bh rkhdia
    polylinecordinates = [];
    setPolylines();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// WE HAVE DONE GET MY LOCATION TILL HERE

//

// i will be following this : https://www.youtube.com/watch?v=QP4FCi9MgHU

class radius extends StatefulWidget {
  ////////////////////////////////############# Next UI Page not User YET###############\\\\\\\\\\\\\\\\\\\\\
  const radius({Key? key}) : super(key: key);

  @override
  State<radius> createState() => _radiusState();
}

class _radiusState extends State<radius> {
  double value1 = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hello"),
      ),
      drawer: Drawer(),
      body: Column(
        children: [
          Container(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
          ),
          Container(
            child: SliderTheme(
              data: SliderThemeData(
                valueIndicatorColor: Colors.green, ////////////Slider Details
                activeTrackColor: Colors.green,
                inactiveTrackColor: Colors.green.shade100,
                inactiveTickMarkColor: Colors.red,
                thumbColor: Colors.green,
                valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                // thumbShape:
              ),
              child: Slider(
                value: value1,
                min: 0,
                max: 100,
                divisions: 10,
                label: value1.round().toString(),
                onChanged: (value) => setState(() => this.value1 = value),
              ),
            ),
          ),
          Container(
            child: Text(value1.toString()),
          ),
        ],
      ),
      // body: Center(

      //   child: ElevatedButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Text('Go back!'),
      //   ),

      // ),
    );
  }
}

Future<List> getall() async {
  print(
      "Faraz sata.........................................................\n . \n . \n \n . \n");
  //Loop List to get the longitude and latitude of all the online Users.
  //Make Global Variable to store Online users.
  //Call Database regularly to get the updated data live user location.

// DatabaseReference starCountRef =
//         FirebaseDatabase.instance.ref('posts/$postId/starCount');
// starCountRef.onValue.listen((DatabaseEvent event) {
//     final data = event.snapshot.value;
//     updateStarCount(data);
// });

  DatabaseReference db = FirebaseDatabase.instance.ref();

  dynamic zalalat;
  dynamic users;

  var snapshotUsers = await db.child("Users").get();

  var listOfUsersId = [];

  if (snapshotUsers.exists) {
    print(
        "Quassain sata.........................................................\n . \n . \n \n . \n");

    Map<dynamic, dynamic> users = snapshotUsers.value as Map<dynamic, dynamic>;
    for (String key in users.keys) {
      print(key);
      // print(lis1[key]);
      listOfUsersId.add(key);
    }
  }

  var ActiveUsers = [];

  for (var i = 0; i < listOfUsersId.length; i++) {
    final snapshotActive =
        await db.child('ActiveUsers').child(listOfUsersId[i]).child("l").get();
    if (snapshotActive.exists) {
      print(
          "Saad sata.........................................................\n . \n . \n \n . \n");
      zalalat = snapshotActive.value;
      if (zalalat != null) {
        ActiveUsers.add(zalalat);
        ActiveUserId.add(listOfUsersId[i]);
      }

      // print(zalalat);
    } else {
      print('No data available.');
    }
  }

  print(ActiveUsers);

  return ActiveUsers;
}

//########################## Use RestAPI to get Database data ####################################

// Future<String> getJsonFromFirebaseRestAPI() async {
//   print("Jason\nJason\nJason\nJason\nJason\nJason\nJason\nJason\nJason\nJason\nJason\nJason\n");
//   String url = "https://godutch-53750-default-rtdb.firebaseio.com/ActiveUsers.json";
//   http.Response response = await http.get(Uri.parse(url));

//   // dynamic json = convert.jsonDecode(response.body);

//   dynamic json = convert.jsonDecode(response.body);
//   print("json\njson\njson\njson\njson\njson\njson\njson\njson\njson\njson\njson\n");
//   print(json);
//   print("json\njson\njson\njson\njson\njson\njson\njson\njson\njson\njson\njson\n");
//   // List<String> stringList = (convert.jsonDecode(response.body) as List<dynamic>).cast<String>();

//   // print(x);
//   return response.body;
// }

switchModes() {
  DatabaseReference mode = FirebaseDatabase.instance
      .ref()
      .child("Users")
      .child(currentfirebaseuser!.uid)
      .child("mode");
  // dev.debugger();
  print("mode");
  // print(pos);
  if (UserMode == true) {
    UserMode = false;
    mode.set("Driver");
    status_of_me = "Driver";
    // mode.onValue.listen((event) {});
  } else {
    UserMode = true;
    mode.set("Passenger");
    status_of_me = "Passenger";
  }
}
