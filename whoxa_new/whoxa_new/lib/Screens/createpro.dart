import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterwhatsappclone/Screens/home.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/share_preference/preferencesKey.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class CreatePro extends StatefulWidget {
  @override
  _CreateProState createState() => _CreateProState();
}

class _CreateProState extends State<CreatePro> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  TextEditingController nameController = TextEditingController();
  String userId;
  File _image;
  bool isLoading = false;
  String _token = '';
  bool isButtonEnabled = false;

  @override
  void initState() {
    _getToken();
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;
      });
    });

    super.initState();
  }

  isEmpty() {
    if (nameController.text.trim() != "") {
      isButtonEnabled = true;
    } else {
      isButtonEnabled = false;
    }
  }

  _getToken() {
    FirebaseMessaging().getToken().then((token) {
      setState(() {
        _token = token;
      });
    });
  }

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
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Container(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: appColorBlue,
              title: Text(
                "Profile",
                style: TextStyle(
                    color: appColorWhite, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Stack(
              children: [
                LayoutBuilder(builder: (context, constraint) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraint.maxHeight),
                        child: IntrinsicHeight(
                          child: Stack(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                      height:
                                          SizeConfig.blockSizeVertical * 10),
                                  _image == null
                                      ? RawMaterialButton(
                                          onPressed: () {
                                            getImage();
                                          },
                                          elevation: 2.0,
                                          fillColor: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.image,
                                                size: 100.0,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.all(15.0),
                                          shape: CircleBorder(),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            getImage();
                                          },
                                          child: CircleAvatar(
                                            backgroundImage: FileImage(_image),
                                            radius: 60,
                                          ),
                                        ),
                                  SizedBox(
                                      height: SizeConfig.blockSizeVertical * 3),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: TextField(
                                      maxLength: 25,
                                      onChanged: (val) {
                                        isEmpty();
                                      },
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        labelText: "Name",
                                        suffixIcon: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.insert_emoticon,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 30,
                                        top: 0,
                                        left: 30,
                                        bottom: 10),
                                    child: SizedBox(
                                      height: SizeConfig.blockSizeVertical * 7,
                                      width: SizeConfig.screenWidth,
                                      child: CustomButtom(
                                          title: 'NEXT',
                                          fontSize: 16,
                                          fontFamily: "MontserratBold",
                                          fontWeight: FontWeight.bold,
                                          textColor: appColorWhite,
                                          color: appColorBlue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          onPressed: () {
                                            creatPro();
                                          }),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  );
                }),
                isLoading == true ? Center(child: loader()) : Container(),
              ],
            )),
      ),
    );
  }

  creatPro() async {
    if (_image != null) {
      setState(() {
        isLoading = true;
      });

      // final StorageReference postImageRef =
      //     FirebaseStorage.instance.ref().child("User Image");

      // var timeKey = new DateTime.now();

      // final StorageUploadTask uploadTask =
      //     postImageRef.child(timeKey.toString() + ".jpg").putFile(_image);

      // // ignore: non_constant_identifier_names
      // var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

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
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) async {
          _database.reference().child("user").child(userId).update({
            "img": downloadUrl.length > 0 ? downloadUrl : "",
            "name": nameController.text.toString(),
            "token": _token,
            "status": "Online",
            "bio": "",
            "location": "",
            "mobile": mobNo,
            "countryCode": cCode,
            "privacy": false,
            "userId": userId,
            "inChat": '',
            "lastseen": 'everyone',
            "profileseen": 'everyone',
            "userBio": ''
          }).then((value) async {
            Firestore.instance.collection('users').document(userId).setData({
              'uid': userId,
              'name': nameController.text.toString(),
              'email': "",
              'username': nameController.text.toString(),
              'status': "",
              'state': 1,
              'profile_photo': downloadUrl.length > 0 ? downloadUrl : "",
            }, merge: true);
          });

          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString(
              SharedPreferencesKey.LOGGED_IN_USERRDATA, userId);
          userID = userId;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );

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
    } else if (nameController.text.length > 0) {
      _database.reference().child("user").child(userId).update({
        "img": "",
        "name": nameController.text.toString(),
        "token": _token,
        "status": "Online",
        "bio": "",
        "location": "",
        "mobile": mobNo,
        "countryCode": cCode,
        "privacy": false,
        "userId": userId,
        "inChat": '',
        "lastseen": 'everyone',
        "profileseen": 'everyone',
        "userBio": ''
      }).then((value) {
        Firestore.instance.collection('users').document(userId).setData({
          'uid': userId,
          'name': nameController.text.toString(),
          'email': "",
          'username': nameController.text.toString(),
          'status': "",
          'state': 1,
          'profile_photo': "",
        }, merge: true);
      }).then((value) async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString(SharedPreferencesKey.LOGGED_IN_USERRDATA, userId);
        userID = userId;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    } else {
      Toast.show("Please enter your name", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
}
