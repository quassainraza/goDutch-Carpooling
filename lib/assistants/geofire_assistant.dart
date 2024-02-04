import 'package:go_dutch/models/active_nearby_users.dart';

class GeofireAssistant{
   static List<ActiveNearbyUsers> activenearbyuserslist= [];


   static void removeuserfromthelist( String userid){
     int indexNumber = activenearbyuserslist.indexWhere((element) => element.userid== userid);
     activenearbyuserslist.removeAt(indexNumber);
   }
   static void updatenearbyActiveuserslocation(ActiveNearbyUsers userawhoMove){
     int indexNumber = activenearbyuserslist.indexWhere((element) => element.userid== userawhoMove.userid);
     activenearbyuserslist[indexNumber].loclat=userawhoMove.loclat;
     activenearbyuserslist[indexNumber].loclong=userawhoMove.loclong;
   }
}