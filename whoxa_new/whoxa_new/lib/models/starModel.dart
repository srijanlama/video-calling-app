import 'package:firebase_database/firebase_database.dart';

class StarModel {
  String key;
  String currentUserId;
  String name;
  String userId;
  String peerId;
  String img;
  String msg;
  String time;
  String type;

  StarModel(this.currentUserId, this.name, this.userId, this.peerId, this.img,
      this.msg, this.time, this.type);

  StarModel.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        currentUserId = snapshot.value["currentUserId"],
        name = snapshot.value["name"],
        userId = snapshot.value["userId"],
        peerId = snapshot.value["peerId"],
        img = snapshot.value["img"],
        msg = snapshot.value["msg"],
        time = snapshot.value["time"],
        type = snapshot.value["type"];

  toJson() {
    return {
      "currentUserId": currentUserId,
      "name": name,
      "userId": userId,
      "peerId": peerId,
      "img": img,
      "msg": msg,
      "time": time,
      "type": type,
    };
  }
}
