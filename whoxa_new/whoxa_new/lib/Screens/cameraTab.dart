import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:image_picker/image_picker.dart';

class CameraTab extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<CameraTab> {
  File _image;

  final descriptionController = TextEditingController();

  bool isLoading = false;

  var data = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Scaffold(
          backgroundColor: Colors.grey[300],
          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 25, right: 0),
                child: _image == null
                    ? GestureDetector(
                        onTap: () {
                          getImage();
                        },
                        child: Container(
                            color: Colors.grey[200],
                            height: double.infinity,
                            width: double.infinity,
                            child: Center(child: Icon(Icons.add))),
                      )
                    : Container(
                        //color: Colors.grey[200],
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.file(
                          _image,
                          fit: BoxFit.contain,
                        )),
              ),
              isLoading == true ? Center(child: loader()) : Container(),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25)),
                      color: Colors.grey[500]),
                  child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: IconButton(
                                  onPressed: () async {},
                                  icon: Text(
                                    "",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  )),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: () {
                    getImage();
                  },
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Icon(
                        Icons.photo,
                        size: 35,
                        color: Colors.black,
                      )),
                ),
              )
            ],
          )),
    );
  }

  getImage() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(height: 10.0),
              Text(
                "Pick Image",
                textAlign: TextAlign.center,
              ),
              Container(height: 10.0),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);

                  final picker = ImagePicker();
                  final imageFile = await picker.getImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );

                  if (imageFile != null) {
                    setState(() {
                      if (imageFile != null) {
                        _image = File(imageFile.path);
                      } else {
                        print('No image selected.');
                      }
                    });
                  }
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                    ),
                    Container(width: 10.0),
                    Text(
                      'Camera',
                    )
                  ],
                ),
              ),
              Container(height: 15.0),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);

                  final picker = ImagePicker();
                  final imageFile = await picker.getImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );

                  if (imageFile != null) {
                    setState(() {
                      if (imageFile != null) {
                        _image = File(imageFile.path);
                      } else {
                        print('No image selected.');
                      }
                    });
                  }
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.storage,
                      color: Colors.black,
                    ),
                    Container(width: 10.0),
                    Text(
                      'Gallery',
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
