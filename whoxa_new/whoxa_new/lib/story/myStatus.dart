import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/story/myStoryView.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:timeago/timeago.dart';
import 'package:flutterwhatsappclone/models/user.dart' as model;
import 'package:firebase_database/firebase_database.dart' as firebase;
//import 'package:flutterwhatsappclone/Screens/chat.dart';

class MyStatus extends StatefulWidget {
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<MyStatus> with SingleTickerProviderStateMixin {
  Animation gap;
  Animation base;
  Animation reverse;
  AnimationController controller;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String userId;
  List postList;
  bool isLoading = false;
  bool callfunction = true;
  firebase.FirebaseDatabase database = new firebase.FirebaseDatabase();

  var forwardM = '';
  int forwardType;
  var forwardMsgId = [];
  var forwardMsgContent = [];
  var forwardMsgContact = [];
  var forwardMsgPeerName = [];
  var forwardMsgPeerImage = [];
  var forwardMsgType = [];

  List<model.User> userlist;
  firebase.Query query;
  StreamSubscription<firebase.Event> _onOrderAddedSubscription;
  StreamSubscription<firebase.Event> _onOrderChangedSubscription;

  @override
  void initState() {
   
     // ignore: deprecated_member_use
    userlist = new List();
    query = database.reference().child("user").orderByChild("userId");
    _onOrderAddedSubscription = query.onChildAdded.listen(onEntryAdded1);
    _onOrderChangedSubscription = query.onChildChanged.listen(onEntryChanged1);

    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      userId = user.uid;
    });
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    base = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    reverse = Tween<double>(begin: 0.0, end: -1.0).animate(base);
    gap = Tween<double>(begin: 3.0, end: 0.0).animate(base)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    _onOrderAddedSubscription.cancel();
    _onOrderChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged1(firebase.Event event) {
    var oldEntry = userlist.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      userlist[userlist.indexOf(oldEntry)] =
          model.User.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded1(firebase.Event event) {
    setState(() {
      userlist.add(model.User.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Container(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                "My Status",
                style: TextStyle(
                    fontFamily: "MontserratBold",
                    fontSize: 17,
                    color: Colors.black),
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
            body: LayoutBuilder(builder: (context, constraint) {
              return Stack(
                children: [
                  SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        isLoading == true
                            ? Center(child: loader())
                            : instaStories(),
                        Text("Your status will disappear after 24 hours."),
                      ],
                    ),
                  )),
                ],
              );
            })),
      ),
    );
  }

  Widget instaStories() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("storyUser")
          .where(FieldPath.documentId, isEqualTo: userId)
          // .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data.documents.length > 0
              ? ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: snapshot.data.documents[0]["story"].length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    postList = snapshot.data.documents[0]["story"];
                    return postWidget(postList, index);
                  },
                )
              : Center(
                  child: Text(""),
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
    );
  }

  Widget postWidget(postList, index) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: ListTile(
                  onTap: () {
                    List listImage = [];
                    listImage.add(postList[index]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyStoryPageView(
                                context,
                                images: listImage,
                                time: postList[index]["time"],
                              )),
                    );
                  },
                  leading: new Stack(
                    children: <Widget>[
                      RotationTransition(
                        turns: base,
                        child: DashedCircle(
                          gapSize: gap.value,
                          dashes: 20,
                          color: Colors.green,
                          child: RotationTransition(
                            turns: reverse,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CircleAvatar(
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Colors.grey,
                                backgroundImage: new NetworkImage(
                                  postList[index]["type"] == "image"
                                      ? postList[index]["image"]
                                      : videoImage,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Container(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: new Text(
                      format(
                        DateTime.fromMillisecondsSinceEpoch(int.parse(
                          postList[index]["time"],
                        )),
                      ),
                      style: new TextStyle(color: Colors.black, fontSize: 14.0),
                    ),
                  ),
                  // title: countWidget(postList[index]["time"]),
                  // subtitle: new Container(
                  //   padding: const EdgeInsets.only(top: 5.0),
                  //   child: new Text(
                  //     format(
                  //       DateTime.fromMillisecondsSinceEpoch(int.parse(
                  //         postList[index]["time"],
                  //       )),
                  //     ),
                  //     style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                  //   ),
                  // ),
                ),
              ),
            ),
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                // PopupMenuItem(
                //   value: 1,
                //   child: InkWell(
                //       onTap: () {
                //         if (postList[index]["type"] == "image") {
                //           forwardType = 1;
                //         } else {
                //           forwardType = 4;
                //         }
                //         forwardM = postList[index]["image"];

                //         forwardMsg();
                //       },
                //       child: Padding(
                //         padding: const EdgeInsets.only(left: 5),
                //         child: Row(
                //           children: [
                //             Transform(
                //               alignment: Alignment.center,
                //               transform: Matrix4.rotationY(math.pi),
                //               child: Icon(
                //                 Icons.reply,
                //                 color: Colors.black,
                //                 size: 25,
                //               ),
                //             ),
                //             Container(width: 10),
                //             Text("Forward"),
                //           ],
                //         ),
                //       )),
                // ),
                PopupMenuItem(
                  value: 2,
                  child: InkWell(
                      onTap: () {
                        deleteStory(postList, index, userId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.black,
                              size: 25,
                            ),
                            Container(width: 10),
                            Text("Delete"),
                          ],
                        ),
                      )),
                ),
              ],
            )
          ],
        ),
        new Divider(
          thickness: 1,
        ),
      ],
    );
  }

  Widget countWidget(String time) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("storyViews")
          .where(FieldPath.documentId, isEqualTo: time)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data.documents.length > 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(
                      snapshot.data.documents[0]["views"].length.toString() +
                          " Views",
                      style: new TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Container(
                  child: Text(
                    "0 Views",
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  ),
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
    );
  }

  deleteStory(orderId, int index, uid) async {
    setState(() {
      isLoading = true;
    });
    await Firestore.instance.collection("storyUser").document(uid).updateData({
      "story": FieldValue.arrayRemove([orderId[index]])
    }).then((value) async {
      var document1 = Firestore.instance.collection("storyUser").document(uid);
      document1.get().then((value) async {
        if (value["story"].toString() == "[]") {
          await Firestore.instance
              .collection("storyUser")
              .document(uid)
              .delete();
        }
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });
      });
    });
  }

  forwardMsg() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState1) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    height: 1200,
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
                                      style: TextStyle(color: Colors.green),
                                    )),
                                Text(
                                  "Forward",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.black),
                                ),
                                forwardMsgId.length > 0
                                    ? InkWell(
                                        onTap: () {
                                          forwardMsgContent = [];
                                          forwardMsgType = [];
                                          forwardMsgContact = [];
                                          Navigator.pop(context);

                                          for (var i = 0;
                                              i <= forwardMsgId.length;
                                              i++) {
                                            forwardMsgContent.add(forwardM);
                                            forwardMsgType.add(forwardType);
                                            forwardMsgContact.add("");
                                          }

                                          for (var i = 0;
                                              i < forwardMsgId.length;
                                              i++) {
                                            onForward(
                                                    forwardMsgId[i],
                                                    forwardMsgPeerName[i],
                                                    forwardMsgPeerImage[i],
                                                    forwardMsgContent[i],
                                                    forwardMsgType[i],
                                                    forwardMsgContact[i])
                                                .then((value) {
                                              // if (forwardMsgId.length == 1) {
                                              //   Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             Chat(
                                              //               peerID:
                                              //                   forwardMsgId[0],
                                              //               peerUrl:
                                              //                   forwardMsgPeerImage[
                                              //                       0],
                                              //               peerName:
                                              //                   forwardMsgPeerName[
                                              //                       0],
                                              //               peerToken: "",
                                              //               currentusername:
                                              //                   globalName,
                                              //               currentuserimage:
                                              //                   globalImage,
                                              //               currentuser: userId,
                                              //             )),
                                              //   );
                                              // }
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Text(
                                            "Send",
                                            textAlign: TextAlign.start,
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Text("       "),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: userlist != null && userlist.length > 0
                              ? ListView.builder(
                                  itemCount: userlist.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // print(userlist[index].mobile);
                                    return 
                                    mobileContacts.contains(
                                                userlist[index].mobile) &&
                                            userId != userlist[index].userId
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
                                                          (userlist[index].img !=
                                                                      null &&
                                                                  userlist[index]
                                                                          .img
                                                                          .length >
                                                                      0)
                                                              ? CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .grey,
                                                                  backgroundImage:
                                                                      new NetworkImage(
                                                                          userlist[index]
                                                                              .img),
                                                                )
                                                              : CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          300],
                                                                  child: Text(
                                                                    "",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green,
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )),
                                                        ],
                                                      ),
                                                      title: new Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          new Text(
                                                            userlist[index]
                                                                    .name ??
                                                                "",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle: new Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5.0),
                                                        child: new Row(
                                                          children: [
                                                            Text(userlist[index]
                                                                    .mobile ??
                                                                "")
                                                            // ItemsTile(c.phones),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              forwardMsgId.contains(
                                                      userlist[index].userId)
                                                  ? InkWell(
                                                      onTap: () {
                                                        setState1(() {
                                                          forwardMsgId.remove(
                                                              userlist[index]
                                                                  .userId);
                                                        });
                                                      },
                                                      child: Icon(Icons
                                                          .radio_button_on_outlined),
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        setState1(() {
                                                          forwardMsgId.add(
                                                              userlist[index]
                                                                  .userId);

                                                          forwardMsgPeerName
                                                              .add(userlist[
                                                                      index]
                                                                  .name);
                                                          forwardMsgPeerImage
                                                              .add(userlist[
                                                                      index]
                                                                  .img);
                                                        });
                                                      },
                                                      child: Icon(Icons
                                                          .radio_button_off_outlined),
                                                    ),
                                              Container(
                                                width: 20,
                                              )
                                            ],
                                          )
                                        : Container();
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          });
        });
  }

  Future<void> onForward(
    peerID2,
    peerName2,
    peerUrl2,
    String content,
    int type,
    String contact,
  ) async {
    String groupChatId;
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
              if (doc.data["badge"] != null) {
                badgeCount = int.parse(doc.data["badge"]);
                await Firestore.instance
                    .collection("chatList")
                    .document(peerID2)
                    .collection(peerID2)
                    .document(userId)
                    .setData({
                  'id': userId,
                  // ignore: unnecessary_brace_in_string_interps
                  'name': "${globalName}",
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
              // ignore: unnecessary_brace_in_string_interps
              'name': "${globalName}",
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

      // String notificationPayload =
      //     "{\"to\":\"${peerToken}\",\"priority\":\"high\",\"data\":{\"type\":\"100\",\"user_id\":\"${widget.currentuser}\",\"user_name\":\"${widget.currentusername}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"msg\":\"${content}\",\"time\":\"${DateTime.now().millisecondsSinceEpoch}\"},\"notification\":{\"title\":\"${widget.currentusername}\",\"body\":\"$content\",\"user_id\":\"${widget.currentuser}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"sound\":\"default\"},\"priority\":\"high\"}";
      // createNotification(notificationPayload);
      // listScrollController.animateTo(0.0,
      //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    } else {}
  }
}
