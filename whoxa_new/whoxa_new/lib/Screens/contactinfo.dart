import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterwhatsappclone/Screens/chat.dart';
import 'package:flutterwhatsappclone/Screens/mediaScreen.dart';
import 'package:flutterwhatsappclone/Screens/staredMsg.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call_utilities.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/user.dart';
import 'package:flutterwhatsappclone/Screens/viewImages.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ContactInfo extends StatefulWidget {
  String id;
  var imageMedia;
  var videoMedia;
  var docsMedia;
  var imageMediaTime;
  var blocksId;
  bool chat;
  ContactInfo(
      {this.id,
      this.imageMedia,
      this.videoMedia,
      this.docsMedia,
      this.imageMediaTime,
      this.blocksId,
      this.chat});

  @override
  ContactInfoState createState() {
    return new ContactInfoState();
  }
}

class ContactInfoState extends State<ContactInfo> {
  String name = '';
  String image = '';
  String lastOnline;
  String mobile = '';
  FirebaseDatabase database = new FirebaseDatabase();
  String userId = '';
  List blocksId = [];
  //Share Contact
  var newPersonId = [];
  var newPersonName = [];
  var newPersonImage = [];

  User sender = User();
  User receiver = User();
  String token = '';

  @override
  void initState() {
    blocksId = [];
    if (widget.blocksId != null) {
      blocksId.addAll(widget.blocksId);
    }

    print("PeerId:" + widget.id);
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);

      userId = user.uid;
      getUserData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appColorWhite,
          title: Text(
            "Contact Info",
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
          actions: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.only(right: 15),
            //   child: IconButton(
            //     padding: const EdgeInsets.all(0),
            //     icon: CustomText(
            //       text: "Edit",
            //       alignment: Alignment.centerLeft,
            //       fontSize: 14,
            //       fontWeight: FontWeight.bold,
            //       color: appColorBlue,
            //     ),
            //     onPressed: () {},
            //   ),
            // ),
          ],
        ),
        body: body());
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          image.length > 0
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ViewImages(images: [image], number: 0)),
                    );
                  },
                  child: Image.network(
                    image,
                    height: 400,
                    width: SizeConfig.screenWidth,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(),

          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(
              color: appColorWhite,
              child: Column(
                children: <Widget>[
                  Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(new ClipboardData(text: mobile));
                        Toast.show("mobile copied", context,
                            duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
                      },
                      child: Container(
                        height: SizeConfig.blockSizeVertical * 8,
                        child: Center(
                          child: ListTile(
                            title: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        getContactName(mobile),
                                        style: new TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    4,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "MontserratBold",
                                            color: Colors.black),
                                      ),
                                      new Text(
                                        mobile,
                                        style: new TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    3,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      ClipOval(
                                        child: Material(
                                          color: Colors.grey[100],
                                          child: InkWell(
                                            child: SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                    "assets/images/chat.png",
                                                    color: appColorBlue,
                                                  ),
                                                )),
                                            onTap: () {
                                              if (widget.chat == true) {
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) =>
                                                            Chat(
                                                              peerID: widget.id,
                                                              archive: false,
                                                              pin: '',
                                                          
                                                            )));
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      ClipOval(
                                        child: Material(
                                          color:
                                              Colors.grey[100], // button color
                                          child: InkWell(
                                            child: SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                    "assets/images/video_fill.png",
                                                    color: appColorBlue,
                                                  ),
                                                )),
                                            onTap: () {
                                              sendCallNotification(token,
                                                  "$appName Video Calling....");
                                              CallUtils.dial(
                                                  from: sender,
                                                  to: receiver,
                                                  context: context,
                                                  status: "videocall");
                                            },
                                          ),
                                        ),
                                      ),
                                      ClipOval(
                                        child: Material(
                                          color:
                                              Colors.grey[100], // button color
                                          child: InkWell(
                                            child: SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Image.asset(
                                                    "assets/images/grey_call.png",
                                                    color: appColorBlue,
                                                  ),
                                                )),
                                            onTap: () {
                                              sendCallNotification(token,
                                                  "$appName Voice Calling....");
                                              CallUtils.dial(
                                                  from: sender,
                                                  to: receiver,
                                                  context: context,
                                                  status: "voicecall");
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  // Container(
                  //   height: SizeConfig.blockSizeVertical * 6,
                  //   child: Row(
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.only(left: 15),
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: <Widget>[
                  //             lastOnline != "" && lastOnline == "Online"
                  //                 ? Text(
                  //                     'Online',
                  //                     style: TextStyle(color: Colors.green),
                  //                   )
                  //                 : lastOnline != null
                  //                     ? Text(
                  //                         "Last Seen: " +
                  //                             format(
                  //                               DateTime
                  //                                   .fromMillisecondsSinceEpoch(
                  //                                       int.parse(
                  //                                 lastOnline,
                  //                               )),
                  //                             ),
                  //                         style: TextStyle(fontSize: 14),
                  //                       )
                  //                     : Container(),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Divider(
                  //   thickness: 1,
                  // ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MediaScreen(
                                imageMedia: widget.imageMedia,
                                videoMedia: widget.videoMedia,
                                docsMedia: widget.docsMedia,
                                imageMediaTime: widget.imageMediaTime)),
                      );
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
                                  'Media, Links and Doc ',
                                  style: new TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 3.7,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StarMsg()),
                      );
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
                                  'Starred Messages',
                                  style: new TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 3.7,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Divider(
                  //   thickness: 1,
                  // ),
                  // InkWell(
                  //   onTap: () {},
                  //   child: Container(
                  //     height: SizeConfig.blockSizeVertical * 6,
                  //     child: Center(
                  //       child: ListTile(
                  //         title: new Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: <Widget>[
                  //             Expanded(
                  //               child: new Text(
                  //                 'Groups in common',
                  //                 style: new TextStyle(
                  //                     fontSize:
                  //                         SizeConfig.blockSizeHorizontal * 3.7,
                  //                     fontWeight: FontWeight.bold,
                  //                     color: Colors.black),
                  //               ),
                  //             ),
                  //             Icon(
                  //               Icons.arrow_forward_ios,
                  //               color: Colors.grey,
                  //               size: 20,
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Divider(
                    thickness: 1,
                  ),
                  InkWell(
                    onTap: () {
                      shareContact();
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
                                  'Share Contact',
                                  style: new TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 3.5,
                                      fontWeight: FontWeight.bold,
                                      color: appColorBlue),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // savedContactUserId.contains(widget.id)
                  //     ? Container()
                  //     : Divider(
                  //         thickness: 1,
                  //       ),
                  // savedContactUserId.contains(widget.id)
                  //     ? Container()
                  //     : InkWell(
                  //         onTap: () {

                  //         },
                  //         child: Container(
                  //           height: SizeConfig.blockSizeVertical * 6,
                  //           child: Center(
                  //             child: ListTile(
                  //               title: new Row(
                  //                 mainAxisAlignment:
                  //                     MainAxisAlignment.spaceBetween,
                  //                 children: <Widget>[
                  //                   Expanded(
                  //                     child: new Text(
                  //                       'Create New Contact',
                  //                       style: new TextStyle(
                  //                           fontSize:
                  //                               SizeConfig.blockSizeHorizontal *
                  //                                   3.5,
                  //                           fontWeight: FontWeight.bold,
                  //                           color: appColorBlue),
                  //                     ),
                  //                   ),
                  //                   Icon(
                  //                     Icons.arrow_forward_ios,
                  //                     color: Colors.grey,
                  //                     size: 20,
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  Divider(
                    thickness: 1,
                  ),
                  blocksId.contains(widget.id)
                      ? InkWell(
                          onTap: () {
                            unBlockCall();
                          },
                          child: Container(
                            height: SizeConfig.blockSizeVertical * 6,
                            child: Center(
                              child: ListTile(
                                title: new Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: new Text(
                                        'Unblock Contact',
                                        style: new TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    3.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            openMenu(context);
                          },
                          child: Container(
                            height: SizeConfig.blockSizeVertical * 6,
                            child: Center(
                              child: ListTile(
                                title: new Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: new Text(
                                        'Block Contact',
                                        style: new TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    3.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  Divider(
                    thickness: 1,
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(
          //   height: 50,
          // ),
        ],
      ),
    );
  }

  openMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Block",
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              blockCall();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
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

  shareContact() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState1) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  height: SizeConfig.screenHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: appColorBlue),
                                  )),
                              Text(
                                "Share Contact",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black),
                              ),
                              newPersonId.length > 0
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        for (var i = 0;
                                            i < newPersonId.length;
                                            i++) {
                                          shareFunction(
                                            newPersonId[i],
                                            newPersonName[i],
                                            newPersonImage[i],
                                            name,
                                            7,
                                            mobile,
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Text(
                                          "Share",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: appColorBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        "Share",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder(
                          future: FirebaseDatabase.instance
                              .reference()
                              .child("user")
                              .once(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var lists = [];
                              Map<dynamic, dynamic> values =
                                  snapshot.data.value;
                              values.forEach((key, values) {
                                lists.add(values);
                              });
                              return ListView.builder(
                                itemCount: lists.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return
                                      // getContactName(lists[index]["mobile"])
                                      //             .contains(new RegExp(
                                      //                 controller.text,
                                      //                 caseSensitive: false)) ||
                                      //         controller.text.isEmpty
                                      //     ?
                                      shareItemWidget(lists, index, setState1);
                                  // : Container();
                                },
                              );
                            }
                            return Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    CupertinoActivityIndicator(),
                                  ]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          });
        });
  }

  Widget shareItemWidget(lists, index, setState1) {
    return mobileContacts.contains(lists[index]["mobile"]) &&
            userId != lists[index]["userId"]
        ? Row(
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    new Divider(
                      height: 1,
                    ),
                    new ListTile(
                      onTap: () {},
                      leading: new Stack(
                        children: <Widget>[
                          (lists[index]["img"] != null &&
                                  lists[index]["img"].length > 0)
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      new NetworkImage(lists[index]["img"]),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                        ],
                      ),
                      title: Text(
                        getContactName(lists[index]["mobile"]),
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      subtitle: new Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: new Row(
                          children: [Text(lists[index]["mobile"])],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              newPersonId.contains(lists[index]["userId"])
                  ? InkWell(
                      onTap: () {},
                      child: IconButton(
                        onPressed: () {
                          setState1(() {
                            newPersonId.remove(lists[index]["userId"]);
                            newPersonName.remove(lists[index]["name"]);
                            newPersonImage.remove(lists[index]["img"]);
                          });
                        },
                        icon: Icon(
                          Icons.check_circle,
                          color: appColorBlue,
                          size: 28,
                        ),
                      ))
                  : IconButton(
                      onPressed: () {
                        setState1(() {
                          newPersonId.add(lists[index]["userId"]);
                          newPersonName.add(lists[index]["name"]);
                          newPersonImage.add(lists[index]["img"]);
                        });
                      },
                      icon: Icon(
                        Icons.radio_button_off_outlined,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
              Container(
                width: 20,
              )
            ],
          )
        : Container();
  }

  shareFunction(
    peerID2,
    peerName2,
    peerUrl2,
    String content,
    int type,
    String contact,
  ) async {
    String groupChatId = '';
    // 0 = text
    // 1 = image
    // 2 = sticker
    // 4 = video
    // 5 = file
    // 6 = audio
    // 7 = contact
    int badgeCount = 0;
    print(content);
    print(content.trim());
    if (content.trim() != '') {
      if (userId.hashCode <= peerID2.hashCode) {
        groupChatId = userId + "-" + peerID2;
      } else {
        groupChatId = peerID2 + "-" + userId;
      }

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': userId,
            'idTo': peerID2,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'contact': contact,
            'type': type,
            "read": false,
            "delete": []
          },
        );
      }).then((onValue) async {
        await Firestore.instance
            .collection("chatList")
            .document(userId)
            .collection(userId)
            .document(peerID2)
            .setData({
          'id': peerID2,
          'name': peerName2,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'badge': '0',
          'profileImage': peerUrl2,
          'type': type,
          'archive': false,
        }, merge: true).then((onValue) async {
          try {
            await Firestore.instance
                .collection("chatList")
                .document(peerID2)
                .collection(peerID2)
                .document(userId)
                .get()
                .then((doc) async {
              debugPrint(doc.data["badge"]);
              if (doc.data["badge"] != null) {
                badgeCount = int.parse(doc.data["badge"]);
                await Firestore.instance
                    .collection("chatList")
                    .document(peerID2)
                    .collection(peerID2)
                    .document(userId)
                    .setData({
                  'id': userId,
                  'name': globalName,
                  'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                  'content': content,
                  'badge': '${badgeCount + 1}',
                  'profileImage': globalImage,
                  'type': type,
                  'archive': false,
                }, merge: true);
              }
            });
          } catch (e) {
            await Firestore.instance
                .collection("chatList")
                .document(peerID2)
                .collection(peerID2)
                .document(userId)
                .setData({
              'id': userId,
              'name': globalName,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              'content': content,
              'badge': '${badgeCount + 1}',
              'profileImage': globalImage,
              'type': type,
              'archive': false,
            }, merge: true);
            print(e);
          }
        });
      });
    } else {}
  }

  blockCall() {
    blocksId.add(widget.id);
    DatabaseReference _userRef = database.reference().child('block');
    _userRef.child(userId).update({
      "id": blocksId,
    }).then((_) {
      setState(() {
        body();
      });
    });
  }

  unBlockCall() {
    blocksId.remove(widget.id);
    DatabaseReference _userRef = database.reference().child('block');
    _userRef.child(userId).update({
      "id": blocksId,
    }).then((_) {
      setState(() {
        body();
      });
    });
  }

  getUserData() async {
    final FirebaseDatabase database = new FirebaseDatabase();

    database.reference().child('user').child(widget.id).once().then((peerData) {
      name = getContactName(peerData.value['mobile']);
      image = peerData.value['img'];
      mobile = peerData.value['mobile'];
      lastOnline = peerData.value['status'];
      token = peerData.value['token'];
      setState(() {
        sender.uid = userID;
        sender.name = globalName;
        sender.profilePhoto = globalImage;

        receiver.uid = widget.id;
        receiver.name = getContactName(mobile);
        receiver.profilePhoto = image;
        body();
      });
    });
  }

  Future<http.Response> sendCallNotification(
      String peerToken, String content) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "user_pic": globalImage,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "custom.mp3",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": content,
          "title": globalName,
          "sound": "custom.mp3",
        }
      }),
    );
    return response;
  }
}
