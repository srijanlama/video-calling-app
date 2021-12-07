import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:toast/toast.dart';

class ProfilePicture extends StatefulWidget {
  @override
  ProfilePictureState createState() {
    return new ProfilePictureState();
  }
}

class ProfilePictureState extends State<ProfilePicture> {
  String userId = '';
  String profileseen = '';
  final FirebaseDatabase database = new FirebaseDatabase();
  bool isLoading = true;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;

        getprofileseen();
      });
    });
    super.initState();
  }

  getprofileseen() async {
    database.reference().child('user').child(userId).once().then((peerData) {
      setState(() {
        profileseen = peerData.value['profileseen'];
      });
      print(profileseen);
    });

    setState(() {
      _body();
      isLoading = false;
    });
  }

  updateprofileseen() {
    DatabaseReference _userRef = database.reference().child('user');
    _userRef.child(userId).update({
      "profileseen": profileseen,
    }).then((_) {
      setState(() {
        _body();
        Toast.show("Updated", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appColorWhite,
          title: Text(
            'Profile Picture',
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
                    updateprofileseen();
                  },
                  icon: Text(
                    "Done",
                    style: TextStyle(
                        color: appColorBlue, fontFamily: "MontserratBold"),
                  )),
            ),
          ],
        ),
        body: isLoading == true
            ? Center(
                child: loader(),
              )
            : _body());
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  profileseen = 'everyone';
                });
              },
              child: Container(
                height: SizeConfig.blockSizeVertical * 6,
                child: Center(
                  child: ListTile(
                    title: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: new Text(
                            'Everyone',
                            style: new TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 3.7,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        profileseen == "everyone"
                            ? Icon(
                                Icons.check,
                                color: appColorBlue,
                                size: 20,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 0.5, color: Colors.grey),
            InkWell(
              onTap: () {
                setState(() {
                  profileseen = 'mycontacts';
                });
              },
              child: Container(
                height: SizeConfig.blockSizeVertical * 6,
                child: Center(
                  child: ListTile(
                    title: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: new Text(
                            'My Contacts',
                            style: new TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 3.7,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        profileseen == "mycontacts"
                            ? Icon(
                                Icons.check,
                                color: appColorBlue,
                                size: 20,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 0.5, color: Colors.grey),
            InkWell(
              onTap: () {
                setState(() {
                  profileseen = 'nobody';
                });
              },
              child: Container(
                height: SizeConfig.blockSizeVertical * 6,
                child: Center(
                  child: ListTile(
                    title: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: new Text(
                            'Nobody',
                            style: new TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 3.7,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        profileseen == "nobody"
                            ? Icon(
                                Icons.check,
                                color: appColorBlue,
                                size: 20,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 0.5, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
