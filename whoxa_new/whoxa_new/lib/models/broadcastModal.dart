import 'package:firebase_database/firebase_database.dart';

class BroadCastModel {
  String key;
  var name;
  var userId;
  var img;
  var token;
  String createrId;
  String castName;
  


  BroadCastModel(
    this.name,
    this.userId,
    this.img,
    this.token,
    this.createrId,
    this.castName,);

  BroadCastModel.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        name = snapshot.value["name"],
        userId = snapshot.value["userId"],
        img = snapshot.value["img"],
        token = snapshot.value["token"],
        createrId = snapshot.value["createrId"],
        castName = snapshot.value["castName"];

        
       



  toJson() {
    return {
      "name": name,
      "userId": userId,
      "img": img,
      "token": token,
      "createrId": createrId,
      "castName": castName,
    };
  }
}