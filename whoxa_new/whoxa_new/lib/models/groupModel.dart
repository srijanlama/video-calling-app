import 'package:firebase_database/firebase_database.dart';

class GroupModel {
  String key;
  var userId;
  List createrId;
  String castName;
  String castDesc;
  String castImage;

  GroupModel(this.userId, this.createrId, this.castName, this.castDesc,
      this.castImage);

  GroupModel.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        userId = snapshot.value["userId"],
        createrId = snapshot.value["createrId"],
        castName = snapshot.value["castName"],
        castDesc = snapshot.value["castDesc"],
        castImage = snapshot.value["castImage"];

  toJson() {
    return {
      "userId": userId,
      "createrId": createrId,
      "castName": castName,
      "castDesc": castDesc,
      "castImage": castImage
    };
  }
}
