import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_dutch/authentication/login_screen.dart';
import 'package:go_dutch/tabPages/home_tab.dart';
import 'package:go_dutch/global/global.dart';
import 'package:go_dutch/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../widgets/info_design_ui.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? ImageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (ImageUrl != null)
                  ? Image.network(ImageUrl!)
                  : Icon(
                      Icons.account_circle,
                      size: 100,
                    ),
            ),
            IconButton(
              icon: Icon(Icons.camera_alt),
              color: Colors.blueGrey,
              onPressed: () {
                UploadImagetoFirebase();
              },
            ),
            const SizedBox(
              height: 5,
              width: 200,
              child: Divider(
                color: Colors.white,
                height: 2,
                thickness: 2,
              ),
            ),

            //name
            Text(
              userModelCurrentInfo.name!,
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
              width: 200,
              child: Divider(
                color: Colors.white,
                height: 2,
                thickness: 2,
              ),
            ),

            const SizedBox(
              height: 20.0,
            ),

            //phone
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo.phone!,
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo.email!,
              iconData: Icons.email,
            ),

            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo.vehicle_color! +
                  " " +
                  userModelCurrentInfo.vehicle_model! +
                  " " +
                  userModelCurrentInfo.vehicle_number!,
              iconData: Icons.car_repair,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: () {
                //  firebaseAuth.signOut();
                // SystemNavigator.pop();
                logOut(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orangeAccent,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  getProfileImage() {
    if (firebaseAuth.currentUser?.photoURL != null) {
      ImageUrl = firebaseAuth.currentUser!.photoURL;
      return Image.network(
        ImageUrl!,
        height: 100,
        width: 100,
      );
    } else {
      return Icon(
        Icons.account_circle,
        size: 100,
      );
    }
  }

  UploadImagetoFirebase() async {
    //check for permisson
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile? image;

    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      //select image
      image = await _picker.getImage(
        source: ImageSource.gallery,
        maxHeight: 150,
        maxWidth: 200,
      );

      try {
        var file = File(image!.path);
        if (image != null) {
          //upload tofirebase
          var snapshot = await _storage
              .ref()
              .child('Images')
              .putFile(file)
              .whenComplete(() => null);
          var downloadUrl = await snapshot.ref.getDownloadURL();
          setState(() {
            ImageUrl = downloadUrl;
          });
        } else {
          Fluttertoast.showToast(msg: "No Path Received");
        }
      } catch (error) {
        Fluttertoast.showToast(msg: "No File Selected");
      }
    } else {
      Fluttertoast.showToast(msg: "Grant Permissions and try again");
    }
  }
}

UserisofflineByFaraz() async {
  Geofire.removeLocation(currentfirebaseuser!.uid);
  DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("Users")
      .child(currentfirebaseuser!.uid)
      .child("Status");
  ref.set("Offline");
}

//faraz's logoutcode

UserisOfflineNow() {
  ////////// User location not shared with online users\\\\\\\\\\
  Geofire.removeLocation(currentfirebaseuser!.uid);
  DatabaseReference? ref = FirebaseDatabase.instance
      .ref()
      .child("Users")
      .child(currentfirebaseuser!.uid)
      .child("Status");
  ref.onDisconnect();
  ref.remove();
  ref = null;
  Future.delayed(const Duration(milliseconds: 2000), () {
    SystemChannels.platform.invokeMethod("SystemNavigator.pop");
  });
}

Future logOut(BuildContext context) async {
  //UserisOfflineNow();
  UserisofflineByFaraz();
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    await _auth.signOut().then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  } catch (e) {
    print("error");
  }
}
