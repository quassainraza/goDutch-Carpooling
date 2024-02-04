import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_dutch/models/user_model.dart';

final FirebaseAuth firebaseAuth  = FirebaseAuth.instance;
User? currentfirebaseuser;
UserModel userModelCurrentInfo = UserModel();
StreamSubscription<Position>? streamSubscription;
String titleStarsRating = "Good";