import 'package:firebase_database/firebase_database.dart';

class CallModal {
  String key;
  String name;
  String image;
  String callType;
  String callStatus;
  String callerId;
  String recId;
  String mainId;
  String time;
  String channelId;

  CallModal(this.name, this.image, this.callType, this.callStatus,
      this.callerId, this.recId, this.mainId, this.time, this.channelId);

  CallModal.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        image = snapshot.value["image"],
        callType = snapshot.value["callType"],
        callStatus = snapshot.value["callStatus"],
        callerId = snapshot.value["callerId"],
        recId = snapshot.value["recId"],
        mainId = snapshot.value["mainId"],
        time = snapshot.value["time"],
        channelId = snapshot.value["channelId"];

  toJson() {
    return {
      "name": name,
      "image": image,
      "callType": callType,
      "callStatus": callStatus,
      "callerId": callerId,
      "recId": recId,
      "mainId": mainId,
      "time": time,
      "channelId": channelId,
    };
  }
}
