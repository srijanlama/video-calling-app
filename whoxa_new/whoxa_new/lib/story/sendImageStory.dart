import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class SendStory extends StatefulWidget {
  File imageFile;
  SendStory({this.imageFile});
  @override
  ChatBgState createState() {
    return new ChatBgState();
  }
}

class ChatBgState extends State<SendStory> {
  String userId = '';
  bool isLoading = false;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    //_cropImage();
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);

      userId = user.uid;
      //getData();
    });

    super.initState();
  }

  // ignore: missing_return


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
        actions: [
          // IconButton(
          //     padding: const EdgeInsets.all(0),
          //     onPressed: () {
          //       _cropImage();
          //     },
          //     icon: Icon(
          //       Icons.crop,
          //       color: Colors.black,
          //     )),
          // Padding(
          //   padding: const EdgeInsets.only(right: 10),
          //   child: IconButton(
          //       padding: const EdgeInsets.all(0),
          //       onPressed: () {
          //         getimageditor();
          //       },
          //       icon: Icon(
          //         Icons.edit,
          //         color: Colors.black,
          //       )),
          // )
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: widget.imageFile != null
                      ? SizedBox(
                          child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.contain,
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
                buildInput()
              ],
            ),
            Center(child: isLoading == true ? loader() : Container())
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
        decoration: BoxDecoration(color: Colors.black),
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
                getImage(context, globalName, globalImage, mobNo);
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

  getImage(
      BuildContext context, String name, String image, String mobile) async {
    //File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (widget.imageFile != null) {
      setState(() {
        isLoading = true;
      });

      // var timeKey = new DateTime.now();

      // final StorageReference postImageRef =
      //     FirebaseStorage.instance.ref().child("Post Image");
      // final StorageUploadTask uploadTask = postImageRef
      //     .child(timeKey.toString() + ".jpg")
      //     .putFile(widget.imageFile);
      // // ignore: non_constant_identifier_names
      // var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        widget.imageFile.absolute.path,
        targetPath,
        quality: 20,
      ).then((value) async {
        print("Compressed");
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        StorageReference reference =
            FirebaseStorage.instance.ref().child("StoryImage").child(fileName);

        StorageUploadTask uploadTask = reference.putFile(value);
        StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          Firestore.instance.collection('storyUser').document(userId).setData({
            "userId": userId,
            "userName": name,
            "userImage": image,
            "image": downloadUrl,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "mobile": mobile,
            "story": FieldValue.arrayUnion([
              {
                "image": downloadUrl,
                "time": DateTime.now().millisecondsSinceEpoch.toString(),
                "type": "image",
                "text": textEditingController.text.isEmpty
                    ? ""
                    : textEditingController.text
              }
            ])
          }, merge: true).then((value) {
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
  }

  // ignore: unused_element
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: widget.imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.grey,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      widget.imageFile = croppedFile;
      setState(() {
        // state = AppState.cropped;
      });
    }
  }
}
