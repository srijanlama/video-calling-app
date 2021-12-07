import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:toast/toast.dart';

class LastSeen extends StatefulWidget {
  @override
  LastSeenState createState() {
    return new LastSeenState();
  }
}

class LastSeenState extends State<LastSeen> {
  String userId = '';
  String lastSeen = '';
  final FirebaseDatabase database = new FirebaseDatabase();
  bool isLoading = true;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;

        getLastSeen();
      });
    });
    super.initState();
  }

  getLastSeen() async {
    database.reference().child('user').child(userId).once().then((peerData) {
     setState(() {
        lastSeen = peerData.value['lastseen'];
     });
      print(lastSeen);
    });

    setState(() {
      _body();
      isLoading = false;
    });
  }

  updateLastSeen() {
    DatabaseReference _userRef = database.reference().child('user');
    _userRef.child(userId).update({
      "lastseen": lastSeen,
    }).then((_) {
      setState(() {
        _body();
        Toast.show("Last Seen Updated", context,
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
            'Last Seen',
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
                    updateLastSeen();
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
                  lastSeen = 'everyone';
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
                        lastSeen == "everyone"
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
                  lastSeen = 'mycontacts';
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
                        lastSeen == "mycontacts"
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
                  lastSeen = 'nobody';
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
                        lastSeen == "nobody"
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
