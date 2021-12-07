import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';

class PenStatusScreen extends StatefulWidget {
  @override
  PenStatusScreenState createState() {
    return new PenStatusScreenState();
  }
}

class PenStatusScreenState extends State<PenStatusScreen> {
  File _imageFile;
  bool textCursor = true;
  ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController textController = TextEditingController();
  List<Color> _colors = <Color>[
    Color(0XFFad8672),
    Color(0XFFc69dcc),
    Color(0XFF8b698e),
    Color(0XFFff898c),
    Color(0XFF54c166),
    Color(0XFFff7b6b),
    Color(0XFF27c4db),
    Color(0XFF56caff),
    Color(0XFF72666b),
    Color(0XFF7d8fa3),
    Color(0XFF6d267d),
    Color(0XFF7acca5),
    Color(0XFF233540),
    Color(0XFF8294c9),
    Color(0XFFa52b70),
    Color(0XFF8fa940),
    Color(0XFFc1a13f),
    Color(0XFF782037),
    Color(0XFFefb330),
    Colors.blue,
    Colors.red,
    Colors.black,
    Colors.green
  ];

  int _currentColorIndex = 0;
  int _currentStyleIndex = 0;

  void _incrementColorIndex() {
    setState(() {
      if (_currentColorIndex < _colors.length - 1) {
        _currentColorIndex++;
      } else {
        _currentColorIndex = 0;
      }
    });
  }

  List<TextStyle> _style = <TextStyle>[
    GoogleFonts.lato(color: Colors.white, fontSize: 22),
    GoogleFonts.pacifico(color: Colors.white, fontSize: 22),
    GoogleFonts.mcLaren(color: Colors.white, fontSize: 22),
    GoogleFonts.slabo13px(color: Colors.white, fontSize: 22),
    GoogleFonts.comfortaa(color: Colors.white, fontSize: 22),
    GoogleFonts.dancingScript(color: Colors.white, fontSize: 22),
    GoogleFonts.exo2(color: Colors.white, fontSize: 22),
    GoogleFonts.ebGaramond(color: Colors.white, fontSize: 22),
    GoogleFonts.caveat(color: Colors.white, fontSize: 22),
    GoogleFonts.domine(color: Colors.white, fontSize: 22),
    GoogleFonts.josefinSans(color: Colors.white, fontSize: 22),
    GoogleFonts.markaziText(color: Colors.white, fontSize: 22),
  ];
  void _incrementStyleIndex() {
    setState(() {
      if (_currentStyleIndex < _style.length - 1) {
        _currentStyleIndex++;
      } else {
        _currentStyleIndex = 0;
      }
    });
  }

  String userId;
  bool isLoading = false;

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
      backgroundColor: _colors[_currentColorIndex],
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 0, top: 20),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 30,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(child: Text("")),
                    InkWell(
                      onTap: () {
                        _incrementStyleIndex();
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8, right: 15, left: 8, bottom: 0),
                          child: Text(
                            "T",
                            style: _style[_currentStyleIndex],
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        _incrementColorIndex();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8, right: 15, left: 8, bottom: 0),
                        child: Image.asset(
                          "assets/images/paint.png",
                          height: 30,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              centerWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RawMaterialButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        textCursor = false;
                      });
                      _imageFile = null;
                      screenshotController.capture().then((File image) async {
                        print("Capture Done");
                        setState(() {
                          _imageFile = image;
                          if (_imageFile != null) {
                            getImage(
                                context, globalName, globalImage, _imageFile);
                          }
                        });
                        // final result = await ImageGallerySaver.saveImage(
                        //     image.readAsBytesSync());
                        // print("File Saved to Gallery");
                      }).catchError((onError) {
                        print(onError);
                      });
                    },
                    elevation: 2.0,
                    fillColor: Colors.blue,
                    child: RotationTransition(
                      turns: new AlwaysStoppedAnimation(90 / 360),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.navigation,
                          size: 23.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    shape: CircleBorder(),
                  ),
                ],
              ),
            ],
          ),
          isLoading == true
              ? Center(
                  child: loader(),
                )
              : Container()
        ],
      ),
    );
  }

  centerWidget() {
    return Expanded(
      child: Screenshot(
        controller: screenshotController,
        child: Container(
          color: _colors[_currentColorIndex],
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    autofocus: true,
                    enableInteractiveSelection: false,
                    textAlign: TextAlign.center,
                    controller: textController,
                    cursorColor: textCursor == true
                        ? Colors.white
                        : _colors[_currentColorIndex],
                    maxLines: null,
                    textInputAction: TextInputAction.next,
                    style: _style[_currentStyleIndex],
                    // style: TextStyle(color: Colors.white, fontSize: 22),
                    decoration: InputDecoration(
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      errorStyle: TextStyle(color: Colors.white),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: _style[_currentStyleIndex],
                      hintText: "Type a status",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ))),
        ),
      ),
    );
  }

  getImage(BuildContext context, String name, String image, imageFile) async {
    //File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });

      var timeKey = new DateTime.now();

      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("Post Image");
      final StorageUploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(imageFile);
      // ignore: non_constant_identifier_names
      var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      Firestore.instance.collection('storyUser').document(userId).setData({
        "userId": userId,
        "userName": name,
        "userImage": image,
        "image": ImageUrl,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "story": FieldValue.arrayUnion([
          {
            "image": ImageUrl,
            "time": DateTime.now().millisecondsSinceEpoch.toString(),
            "type": "image",
            "text": ""
          }
        ])
      }, merge: true).then((value) {
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });
      });
    }
  }
}
