import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/setBackImage.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';

class ChatBg extends StatefulWidget {
  @override
  ChatBgState createState() {
    return new ChatBgState();
  }
}

File imageFile;

class ChatBgState extends State<ChatBg> {
  bool status = false;
  FirebaseDatabase database = new FirebaseDatabase();
  String userId = '';

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);

      userId = user.uid;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "Chat Background",
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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: SizeConfig.blockSizeVertical * 6.4,
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  getImageFromGallery();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(width: 15),
                                    new Text(
                                      'Photos',
                                      style: new TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: appColorGrey,
                                size: 20,
                              ),
                            ),
                            Container(width: 10)
                          ],
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: Colors.grey[400],
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 6.4,
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  openMenu(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(width: 15),
                                    new Text(
                                      'Reset Wallpaper',
                                      style: new TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: appColorGrey,
                                size: 20,
                              ),
                            ),
                            Container(width: 10)
                          ],
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  openMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Reset Wallpaper",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: () {
              resetWall();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "MontserratBold"),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  getImageFromGallery() async {
    File _image;
    final picker = ImagePicker();
    final imageFile = await picker.getImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {});

      setState(() {
        if (imageFile != null) {
          _image = File(imageFile.path);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SetBackImage(imageFile: _image)),
          );
        } else {
          print('No image selected.');
        }
      });
    }
  }

  resetWall() async {
    DatabaseReference _userRef = database.reference().child('user');
    _userRef.child(userId).update({
      "bio": "",
    }).then((_) {});
  }
}
