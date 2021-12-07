import 'package:firebase_database/firebase_database.dart';

class BlockModel {
  String key;
  List id;

  BlockModel(
    this.id,
  );

  BlockModel.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        id = snapshot.value["id"];

  toJson() {
    return {
      "id": id,
    };
  }
}
