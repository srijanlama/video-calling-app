import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterwhatsappclone/constatnt/Constant.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Firestore firestore = Firestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);
  static final Firestore _firestore = Firestore.instance;

  //user class
  User user = User();

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  Future<User> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();

    return User.fromMap(documentSnapshot.data);
  }
}
