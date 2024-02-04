//now the thing is if user accepts or rejects req the data is removed from collection field but if user justs exits the app without accepting
//or rejecting so we will consider the status as Confused , so the request sender's app will remove the data from firebase if confused is for more than 2 mins
//first of all make it a stateful widget
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_dutch/global/global.dart';

class PickupScreen extends StatefulWidget {
  @override
  _PickupScreenState createState() => _PickupScreenState();
  late Map<String, dynamic>? data;
  PickupScreen({required this.data});
}

class _PickupScreenState extends State<PickupScreen>
    with WidgetsBindingObserver {
  // ignore: non_constant_identifier_names

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      FirebaseFirestore.instance
          .collection("Ride Requests")
          .doc(currentfirebaseuser!.displayName)
          .set({"Status": ""});
    } else {
      // offline
      FirebaseFirestore.instance
          .collection("Ride Requests")
          .doc(currentfirebaseuser!.displayName)
          .set({
        "Status": "Confused",
        "Confused_at": DateTime.now().toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Invited you to a group",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            // CachedImage(
            //   call.callerPic,
            //   isRound: true,
            //   radius: 180,
            // ),
            SizedBox(height: 15),
            Text(
              widget.data!['Req Sender name'].toString(), //data
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection("Ride Requests")
                        .doc(currentfirebaseuser!.displayName)
                        .set({"Status": "Rejected"});
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                    icon: Icon(Icons.call),
                    color: Colors.green,
                    onPressed: () async {
                      FirebaseFirestore.instance
                          .collection("Ride Requests")
                          .doc(currentfirebaseuser!.displayName)
                          .set({"Status": "Accepted"});
                      Navigator.pop(context);
                      //make the status accepted
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
