import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';

class BlockContacts extends StatefulWidget {
  @override
  BlockContactsState createState() {
    return new BlockContactsState();
  }
}

class BlockContactsState extends State<BlockContacts> {
  String userId = '';
  final FirebaseDatabase database = new FirebaseDatabase();
  bool isLoading = true;
  var blockedIds = [];
  var blockedName = [];

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        userId = user.uid;

        getBlockedIds();
      });
    });
    super.initState();
  }

  getBlockedIds() async {
    database.reference().child('block').child(userId).once().then((peerData) {
      setState(() {
        blockedIds.addAll(peerData.value['id']);
        print(blockedIds);
      });
    }).then((value) {
      for (var i = 0; i <= blockedIds.length; i++) {
        database
            .reference()
            .child('user')
            .child(blockedIds[i])
            .once()
            .then((peerData) {
          setState(() {
            blockedName.add(peerData.value['name']);
            print(blockedName);
          });
        });
      }
    });

    setState(() {
      _body();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appColorWhite,
          title: Text(
            "Blocked",
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
        ),
        body: isLoading == true
            ? Center(
                child: loader(),
              )
            : _body());
  }

  Widget _body() {
    return Container(
      child: Column(
        children: <Widget>[
          ListView.builder(
            itemCount: blockedIds.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        openMenu(context, blockedIds[i]);
                      },
                      leading: new Stack(
                        children: <Widget>[
                          InkWell(
                            onLongPress: () {},
                            child: CircleAvatar(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Colors.grey,
                              backgroundImage: new NetworkImage(
                                noImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            blockedName[i],
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 0.5, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  'Blocked contacts will no longer be able to call you or send you messages',
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                      color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  openMenu(BuildContext context, String id) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Unblock",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: () {
              unBlockCall(id);
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontFamily: "MontserratBold"),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
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

  unBlockCall(id) {
    setState(() {
      isLoading = true;
      blockedIds.remove(id);
    });
    DatabaseReference _userRef = database.reference().child('block');
    _userRef.child(userId).update({
      "id": blockedIds,
    }).then((_) {
      setState(() {
        blockedIds = [];
        getBlockedIds();
      });
    });
  }
}
