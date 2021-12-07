import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class EditProfile extends StatefulWidget {
  Function refresh;
  EditProfile({this.refresh});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String userId;
  bool isLoading = true;
  final TextEditingController nameController = TextEditingController();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  File _image;
  Future getImage() async {
    final picker = ImagePicker();
    final imageFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);

    if (imageFile != null) {
      setState(() {
        if (imageFile != null) {
          _image = File(imageFile.path);
        } else {
          print('No image selected.');
        }
      });
    }
  }

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;
        getUserData();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appColorWhite,
          title: Text(
            "Edit Profile",
            style: TextStyle(
                fontFamily: "MontserratBold",
                fontSize: 17,
                color: appColorBlack),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
                widget.refresh();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: appColorBlue,
              )),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      updateInfo();
                    }
                  },
                  icon: Text(
                    "Done",
                    style: TextStyle(
                        color: appColorBlue, fontFamily: "MontserratBold"),
                  )),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            isLoading == true ? Center(child: loader()) : _userInfo(),
          ],
        ));
  }

  Widget _userInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: <Widget>[
          Container(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: _image != null
                                ? FileImage(_image)
                                : globalImage.length > 0
                                    ? NetworkImage(globalImage)
                                    : NetworkImage(noImage),
                            radius: 40,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 15),
                    Expanded(
                      child: CustomText(
                        text:
                            "Enter your name and add an optional profile picture",
                        alignment: Alignment.centerLeft,
                        fontSize: 13,
                        color: appColorBlack,
                      ),
                    )
                  ],
                ),
                Container(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Row(
                    children: [
                      Text(
                        "Edit",
                        style: TextStyle(
                            color: appColorBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 15),
          Container(
            height: 0.5,
            color: Colors.grey[400],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: CustomtextField3(
                textAlign: TextAlign.start,
                controller: nameController,
                maxLines: 1,
                textInputAction: TextInputAction.next,
                hintText: 'Enter Name'),
          ),
          Container(
            height: 0.5,
            color: Colors.grey[400],
          ),
          Container(height: 40),
          Container(
            height: 60,
            color: Colors.grey[100],
            child: Column(
              children: [
                Container(
                  height: 0.5,
                  color: Colors.grey[400],
                ),
                Expanded(child: Container()),
                Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 5),
                  child: CustomText(
                    text: "PHONE NUMBER",
                    alignment: Alignment.centerLeft,
                    fontSize: 13,
                    color: appColorBlack,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: Colors.grey[400],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
            child: CustomText(
              text: cCode + " " + mobNo,
              alignment: Alignment.centerLeft,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: appColorBlack,
            ),
          ),
          Container(
            height: 0.5,
            color: Colors.grey[400],
          ),
          // Container(
          //   height: 60,
          //   color: Colors.grey[100],
          //   child: Column(
          //     children: [
          //       Expanded(child: Container()),
          //       Padding(
          //         padding: const EdgeInsets.only(left: 15, bottom: 5),
          //         child: CustomText(
          //           text: "ABOUT",
          //           alignment: Alignment.centerLeft,
          //           fontSize: 13,
          //           color: appColorBlack,
          //         ),
          //       ),
          //       Container(
          //         height: 0.5,
          //         color: Colors.grey[400],
          //       ),
          //     ],
          //   ),
          // ),
          // Container(
          //   height: 0.5,
          //   color: Colors.grey[400],
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 15),
          //   child: CustomtextField3(
          //       textAlign: TextAlign.start,
          //       controller: bioController,
          //       maxLines: 1,
          //       textInputAction: TextInputAction.next,
          //       hintText: 'Enter Bio'),
          // ),
          // Container(
          //   height: 0.5,
          //   color: Colors.grey[400],
          // ),
        ],
      ),
    );
  }

  updateInfo() async {
    if (_image != null) {
      setState(() {
        isLoading = true;
      });

      // final StorageReference postImageRef =
      //     FirebaseStorage.instance.ref().child("User Image");

      // var timeKey = new DateTime.now();

      // final StorageUploadTask uploadTask =
      //     postImageRef.child(timeKey.toString() + ".jpg").putFile(_image);

      // var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        _image.absolute.path,
        targetPath,
        quality: 20,
      ).then((value) async {
        print("Compressed");
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        StorageReference reference =
            FirebaseStorage.instance.ref().child("ProfilePic").child(fileName);

        StorageUploadTask uploadTask = reference.putFile(value);
        StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          _database.reference().child("user").child(userId).update({
            "img": downloadUrl.toString(),
            "name": nameController.text,
          }).then((value) {
            preferences.setString('name', nameController.text.toString());
            preferences.setString('image', downloadUrl.toString());
          });

          Toast.show("Profile Updated Sucesssfully", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          setState(() {
            isLoading = false;
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          // Fluttertoast.showToast(msg: 'This file is not an image');
        });
      });
    } else {
      _database.reference().child("user").child(userId).update({
        "name": nameController.text,
      }).then((value) {
        preferences.setString('name', nameController.text.toString());
      });
      Toast.show("Profile Updated Sucesssfully", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
    getUserData();
  }

  getUserData() async {
    final FirebaseDatabase database = new FirebaseDatabase();
    database.reference().child('user').child(userId).once().then((peerData) {
      setState(() {
        nameController.text = peerData.value['name'];
        globalName = peerData.value['name'];
        globalImage = peerData.value['img'];
        cCode = peerData.value['countryCode'];
        mobNo = peerData.value['mobile'];
        _userInfo();
        isLoading = false;
      });
    });
  }
}
