import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class EditGroup extends StatefulWidget {
  String groupName;
  String groupImage;
  String groupDescription;
  var groupIds;
  String groupKey;

  EditGroup(
      {this.groupName,
      this.groupImage,
      this.groupDescription,
      this.groupIds,
      this.groupKey});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditGroup> {
  String userId;
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  File _image;
  Future getImage() async {
    // ignore: unused_local_variable
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
    nameController.text = widget.groupName;
    descController.text = widget.groupDescription;
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;
        //getUserData();
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
            "Group Info",
            style: TextStyle(
                fontFamily: "MontserratBold",
                fontSize: 17,
                color: appColorBlack),
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
                            backgroundImage: _image != null
                                ? FileImage(_image)
                                : widget.groupImage.length > 0
                                    ? NetworkImage("${widget.groupImage}")
                                    : NetworkImage(
                                        "${"https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png"}"),
                            radius: 40,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 15),
                    Expanded(
                      child: CustomText(
                        text:
                            "Enter group name and add an optional group picture",
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
                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                  child: CustomText(
                    text: "Add group description",
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
            padding: const EdgeInsets.only(left: 15),
            child: CustomtextField3(
                textAlign: TextAlign.start,
                controller: descController,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                hintText: 'Enter Description'),
          ),
          Container(
            height: 0.5,
            color: Colors.grey[400],
          ),
          Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text(
                'The group description is visible to participants of this group and people invited to this group.',
                style: TextStyle(fontSize: 13),
              )),
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

      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("User Image");

      var timeKey = new DateTime.now();

      final StorageUploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(_image);

      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      _database.reference().child("group").child(widget.groupKey).update({
        "castImage": imageUrl.toString(),
        "castName": nameController.text,
        "castDesc": descController.text,
      }).then((value) {
        updateChatList(imageUrl.toString());
      });

      Toast.show("Updated Sucesssfully", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      setState(() {
        isLoading = false;
      });
    } else {
      _database.reference().child("group").child(widget.groupKey).update({
        "castName": nameController.text,
        "castDesc": descController.text,
      }).then((value) {
        updateChatList(widget.groupImage);
      });
      Toast.show("Updated Sucesssfully", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
    // getUserData();
  }

  updateChatList(image) async {
    for (var i = 0; i < widget.groupIds.length; i++) {
      await Firestore.instance
          .collection("chatList")
          .document(widget.groupIds[i])
          .collection(widget.groupIds[i])
          .document(widget.groupKey)
          .updateData({'name': nameController.text, 'profileImage': image});
    }
  }

  // getUserData() async {
  //   final FirebaseDatabase database = new FirebaseDatabase();

  //   database.reference().child('user').child(userId).once().then((peerData) {
  //     setState(() {
  //       nameController.text = peerData.value['name'];
  //       globalName = peerData.value['name'];
  //       globalImage = peerData.value['img'];
  //       cCode = peerData.value['countryCode'];
  //       getMob = peerData.value['mobile'];
  //       _userInfo();
  //       isLoading = false;
  //     });
  //   });
  // }
}
