import 'package:firebase_auth/firebase_auth.dart';



class  AuthService {

    // try {
    //   await currentUser.sendEmailVerification();
    //   return currentUser.user.uid;
    // } catch (e) {
    //   print("An error occured while trying to send email verification");
    //   print(e.message);
    // }

    // // Update the username
    // var userUpdateInfo = UserUpdateInfo();
    // userUpdateInfo.displayName = name;
    // await currentUser.updateProfile(userUpdateInfo);
    // await currentUser.reload();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  Stream<String> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map(
        (FirebaseUser user) => user?.uid,
      );

  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return currentUser.user.uid;
  }

  // Email & Password Sign In
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password)).user.uid;
  }




  // Sign Out
  signOut() {
    return _firebaseAuth.signOut();
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

}

class NameValidator {
  static String validate(String value) {
    if(value.isEmpty) {
      return "Name can't be empty";
    }
    if(value.length < 2) {
      return "Name must be at least 2 characters long";
    }
    if(value.length > 50) {
      return "Name must be less than 50 characters long";
    }
    return null;
  }
}

class EmailValidator {
  static String validate(String value) {
    if(value.isEmpty) {
      return "Email can't be empty";
    }
    return null;
  }
}

class PasswordValidator {
  static String validate(String value) {
    if(value.isEmpty) {
      return "Password can't be empty";
    }
    return null;
  }
}