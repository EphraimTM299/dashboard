import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store_responsive_dashboard/models/Orders.dart';

import 'package:store_responsive_dashboard/models/User.dart';

class MyDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createUser(MyUser? user) async {
    String retVal = "error";

    try {
      await _firestore.collection("users").doc(user?.uid).set({
        "uid": user?.uid,
        "userName": user?.firstName,
        "userEmail": user?.email,
        "userPhone": user?.phoneNumber,
        "laundromatName": user?.laundromatName,
        "accountCreated": Timestamp.now()
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  // Future<String> createLaundromat(MyUser? user) async {
  //   String retVal = "error";

  //   try {
  //     await _firestore.collection("laundromat").doc(user?.uid).set({
  //       "uid": user?.uid,
  //       "Name": user?.firstName,
  //       "Email": user?.email,
  //       "Phone": user?.phoneNumber,
  //       "Location": user?.address,
  //       "name": user?.laundromatName,
  //       "AccountCreated": Timestamp.now(),
  //       "status": "Inactive",
  //       "rating": 0.0,
  //       "distance": 0.0,
  //       "turnAround": "24"
  //     });
  //     retVal = "success";
  //   } catch (e) {
  //     print(e);
  //   }

  //   return retVal;
  // }
}
