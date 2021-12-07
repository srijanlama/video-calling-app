import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class SetBackImage extends StatefulWidget {
  File imageFile;
  SetBackImage({this.imageFile});
  @override
  ChatBgState createState() {
    return new ChatBgState();
  }
}

class ChatBgState extends State<SetBackImage> {
  FirebaseDatabase database = new FirebaseDatabase();
  String userId = '';
  bool isLoading = false;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);

      userId = user.uid;
      //getData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "Preview",
          style: TextStyle(
              fontFamily: "MontserratBold", fontSize: 17, color: appColorBlack),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: appColorBlue,
            )),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: widget.imageFile != null
                      ? SizedBox(
                          child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.cover,
                        ))
                      : Center(
                          child: Text(
                            "Select photo",
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Poppins-Medium",
                            ),
                          ),
                        ),
                ),
                Container(
                  height: 45,
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      )),
                      Container(
                          height: double.infinity,
                          width: 0.8,
                          color: Colors.black),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          setBack();
                        },
                        child: Text("Set",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ))
                    ],
                  ),
                ),
              ],
            ),
            Center(child: isLoading == true ? loader() : Container())
          ],
        ),
      ),
    );
  }

  setBack() async {
    setState(() {
      isLoading = true;
    });

    final dir = await getTemporaryDirectory();
    final targetPath = dir.absolute.path +
        "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

    await FlutterImageCompress.compressAndGetFile(
      widget.imageFile.absolute.path,
      targetPath,
      quality: 40,
    ).then((value) async {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference reference =
          FirebaseStorage.instance.ref().child("Back Image").child(fileName);

      StorageUploadTask uploadTask = reference.putFile(value);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        DatabaseReference _userRef = database.reference().child('user');
        _userRef.child(userId).update({
          "bio": downloadUrl,
        }).then((_) {
          setState(() {
            isLoading = false;
            Navigator.pop(context);
          });
        });
      }, onError: (err) {
        setState(() {
          isLoading = false;
        });
        // Fluttertoast.showToast(msg: 'This file is not an image');
      });
    });
  }

  // getData() async {
  //   final FirebaseDatabase database = new FirebaseDatabase();

  //   database
  //       .reference()
  //       .child('user')
  //       .child(userId)
  //       .orderByChild("token")
  //       .once()
  //       .then((peerData) {
  //     // peerToken = peerData.value['token'];
  //   });
  // }
}
