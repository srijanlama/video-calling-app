import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:video_player/video_player.dart';

class SendVideoStory extends StatefulWidget {
  final File videoFile;

  SendVideoStory({this.videoFile});

  @override
  ChatBgState createState() => ChatBgState(videoFile: videoFile);
}

class ChatBgState extends State<SendVideoStory> {
  File videoFile;
  ChatBgState({this.videoFile});
  String userId = '';
  var videoSize = '';
  // ignore: unused_field
  double _progress = 0;
  double percentage = 0;
  bool videoloader = false;
  String videoStatus = '';
  final TextEditingController textEditingController = TextEditingController();
  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _pickVideo();
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);

      userId = user.uid;
      //getData();
    });

    super.initState();
  }

  _pickVideo() async {
    // File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    //  widget.video = video;
    _videoPlayerController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Preview",
          style: TextStyle(
              fontFamily: "MontserratBold", fontSize: 17, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    videoFile != null
                        ? _videoPlayerController.value.initialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoPlayerController.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController),
                              )
                            : Center(
                                child: Text(
                                  "Select video",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              )
                        : Container(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(height: 80, child: buildInput()),
            ),
            Center(
              child: videoloader == true ? loader() : Container(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 10, top: 10),
      child: Container(
        width: deviceHeight,
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(width: 15),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 20.0,
                ),
                height: 47.0,
                width: deviceWidth * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.grey[300],
                ),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type something about story..',
                    hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                sendVideo(context, globalName, globalImage);
              },
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              iconSize: 32.0,
            ),
            Container(width: 15),
          ],
        ),
      ),
    );
  }

  sendVideo(BuildContext context, String name, String image) async {
    //File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (widget.videoFile != null) {
      setState(() {
        _videoPlayerController.pause();
        videoloader = true;
      });

      var timeKey = new DateTime.now();

      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("Story Video");
      final StorageUploadTask uploadTask = postImageRef
          .child(timeKey.toString() + ".mp4")
          .putFile(widget.videoFile);
      // ignore: non_constant_identifier_names
      var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      Firestore.instance.collection('storyUser').document(userId).setData({
        "userId": userId,
        "userName": name,
        "userImage": image,
        "image": ImageUrl,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "mobile": mobNo,
        "story": FieldValue.arrayUnion([
          {
            "image": ImageUrl,
            "time": DateTime.now().millisecondsSinceEpoch.toString(),
            "type": "video",
            "text": textEditingController.text.isEmpty
                ? ""
                : textEditingController.text
          }
        ])
      }, merge: true).then((value) {
        setState(() {
          videoloader = false;
        });
        Navigator.pop(context);
      });
    }
  }
}
