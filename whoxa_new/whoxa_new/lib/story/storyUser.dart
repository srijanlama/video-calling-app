import 'package:firebase_database/firebase_database.dart';

class StroyUser {
  String key;
  String userId;
  String userName;
  String userImage;
  String time;
  String image;
  String mobile;

  StroyUser(this.userId, this.userName, this.userImage, this.time, this.image,
      this.mobile);

  StroyUser.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        userId = snapshot.value["userId"],
        userName = snapshot.value["userName"],
        userImage = snapshot.value["userImage"],
        time = snapshot.value["time"],
        image = snapshot.value["image"],
        mobile = snapshot.value["mobile"];

  toJson() {
    return {
      "userId": userId,
      "userName": userName,
      "userImage": userImage,
      "time": time,
      "image": image,
      "mobile": mobile,
    };
  }
}
