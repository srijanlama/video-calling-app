import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterwhatsappclone/Screens/chat.dart';
import 'package:flutterwhatsappclone/Screens/contactinfo.dart';
import 'package:flutterwhatsappclone/Screens/groupChat/groupChat.dart';
import 'package:flutterwhatsappclone/Screens/saveContact.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
//import 'chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ArchiveChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ArchiveChatList> {
  String userId;
  final FirebaseDatabase database = new FirebaseDatabase();
  var array = [];
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    database
        .reference()
        .child('user')
        .orderByChild("status")
        .equalTo("Online")
        .onValue
        .listen((event) {
      var snapshot = event.snapshot;
      snapshot.value.forEach((key, values) {
        array.add(values["userId"]);
      });
    });

    array.clear();

    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userID = user.uid;
        userId = user.uid;
      });
    });

    super.initState();
  }

  List chatList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "Archived Chats",
          style: TextStyle(
              fontFamily: "MontserratBold", fontSize: 17, color: appColorBlack),
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40),
                        topLeft: Radius.circular(40)),
                  ),
                  child: friendListToMessage(userId)),
            ),
          ),
        ],
      ),
    );
  }

  Widget friendListToMessage(String userData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("chatList")
              .document(userData)
              .collection(userData)
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              chatList = snapshot.data.documents;
              return Container(
                width: MediaQuery.of(context).size.width,
                child: snapshot.data.documents.length > 0
                    ?
                    // ? _searchResult.length != 0 ||
                    //         controller.text.trim().toLowerCase().isNotEmpty
                    //     ? ListView.builder(
                    //         itemCount: _searchResult.length,
                    //         physics: NeverScrollableScrollPhysics(),
                    //         shrinkWrap: true,
                    //         itemBuilder: (context, int index) {
                    //           return _searchResult[index]['archive'] != null &&
                    //                   _searchResult[index]['archive'] == false
                    //               ? _searchResult[index]['chatType'] != null &&
                    //                       _searchResult[index]['chatType'] ==
                    //                           "group"
                    //                   ? buildGroupItem(_searchResult, index)
                    //                   : buildItem(_searchResult, index)
                    //               : Container();
                    //         },
                    //       )  :
                    ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return chatList[index]['archive'] != null &&
                                  chatList[index]['archive'] == true
                              ? chatList[index]['chatType'] != null &&
                                      chatList[index]['chatType'] == "group"
                                  ? buildGroupItem(chatList, index)
                                  : buildItem(chatList, index)
                              : Container();
                        },
                      )
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/noimage.jpg",
                              width: 300,
                            ),
                            Text("Currently you don't have any messages"),
                          ],
                        ),
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
        ),
      ),
    );
  }

  Widget buildItem(List chatList, int index) {
    return chatList[index]['id'] == null
        ? Container()
        : StreamBuilder(
            stream: FirebaseDatabase.instance
                .reference()
                .child('user')
                .child(chatList[index]['id'])
                .onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.snapshot.value != null) {
                return getContactName(snapshot.data.snapshot.value["mobile"])
                            .contains(new RegExp(controller.text,
                                caseSensitive: false)) ||
                        controller.text.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 10, bottom: 10),
                        child: Material(
                          elevation: 5,
                          color: appColorWhite,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Chat(
                                                    peerID: chatList[index]
                                                        ['id'],
                                                    archive: chatList[index]
                                                                ['archive'] !=
                                                            null
                                                        ? chatList[index]
                                                            ['archive']
                                                        : false,
                                                    pin: chatList[index]['pin'] != null &&
                                                            chatList[index]['pin']
                                                                    .length >
                                                                0
                                                        ? '2549518301000'
                                                        : '',
                                                   
                                                    chatListTime: chatList[index]
                                                        ['timestamp'])));
                                      },
                                      onLongPress: () {
                                        _settingModalBottomSheet(
                                            context,
                                            userID,
                                            chatList[index]['id'],
                                            chatList[index]['archive'] != null
                                                ? chatList[index]['archive']
                                                : false,
                                            chatList[index]['timestamp'],
                                            chatList[index]['pin'] != null
                                                ? chatList[index]['pin']
                                                : '',
                                            chatList[index]['mute'] != null
                                                ? chatList[index]['mute']
                                                : false,
                                            chatList[index]['badge'],
                                            chatList[index]['chatType'] !=
                                                        null &&
                                                    chatList[index]
                                                            ['chatType'] ==
                                                        "group"
                                                ? "group"
                                                : "normal",
                                            snapshot
                                                .data.snapshot.value["name"],
                                            snapshot
                                                .data.snapshot.value["mobile"]);
                                      },
                                      leading: Container(
                                        height: 100,
                                        width: 60,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            InkWell(
                                                onTap: () {
                                                  showDialog(
                                                    context,
                                                    snapshot.data.snapshot
                                                        .value["name"],
                                                    snapshot.data.snapshot
                                                        .value["img"],
                                                    snapshot.data.snapshot
                                                        .value["mobile"],
                                                    chatList[index]['id'],
                                                  );
                                                },
                                                child: snapshot
                                                            .data
                                                            .snapshot
                                                            .value["img"]
                                                            .length >
                                                        0
                                                    ? Container(
                                                        height: 50,
                                                        width: 53,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9),
                                                          child: customImage(
                                                              snapshot
                                                                      .data
                                                                      .snapshot
                                                                      .value[
                                                                  "img"]),
                                                        ))
                                                    : Container(
                                                        height: 50,
                                                        width: 53,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[400],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Image.asset(
                                                            "assets/images/user.png",
                                                            height: 10,
                                                            color: Colors.white,
                                                          ),
                                                        ))),
                                            Positioned.fill(
                                              top: 0,
                                              left: 0,
                                              bottom: 10,
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: snapshot.data.snapshot
                                                            .value["status"] ==
                                                        "Online"
                                                    ? Icon(Icons.circle,
                                                        color: Colors.green,
                                                        size: 17)
                                                    : Container(),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      title: Text(
                                        getContactName(snapshot
                                            .data.snapshot.value["mobile"]),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: appColorBlack,
                                            fontSize: 14,
                                            fontFamily: boldFamily),
                                      ),
                                      subtitle: snapshot.data.snapshot
                                                      .value["status"] ==
                                                  "typing" &&
                                              snapshot.data.snapshot
                                                      .value["inChat"] ==
                                                  userID
                                          ? CustomText(
                                              text: 'typing..',
                                              alignment: Alignment.centerLeft,
                                              fontSize: 13,
                                              color: appColorBlue,
                                            )
                                          : msgTypeWidget(
                                              chatList[index]['type'],
                                              chatList[index]['content'])),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        readTimestamp(int.parse(
                                            chatList[index]['timestamp'])),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: int.parse(chatList[index]
                                                        ['badge']) >
                                                    0
                                                ? appColorBlue
                                                : Colors.grey,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          int.parse(chatList[index]['badge']) >
                                                  0
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: appColorBlue,
                                                  ),
                                                  alignment: Alignment.center,
                                                  height: 20,
                                                  width: 20,
                                                  child: Text(
                                                    chatList[index]['badge'],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 12),
                                                  ),
                                                )
                                              : Container(),
                                          chatList[index]['pin'] != null &&
                                                  chatList[index]['pin']
                                                          .length >
                                                      0
                                              ? Icon(Icons.push_pin,
                                                  color: appColorBlue, size: 16)
                                              : Container(),
                                          chatList[index]['mute'] == true
                                              ? Icon(Icons.volume_off,
                                                  color: appColorBlue, size: 17)
                                              : Container()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container();
              }
              return Container();
            },
          );
  }

  Widget buildGroupItem(List chatList, int index) {
    return chatList[index]['name']
                .contains(new RegExp(controller.text, caseSensitive: false)) ||
            controller.text.isEmpty
        ? Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: Material(
              elevation: 5,
              color: appColorWhite,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: new ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => GroupChat(
                                          currentuser: userID,
                                          currentusername: globalName,
                                          currentuserimage: globalImage,
                                          peerID: chatList[index]['id'],
                                          peerUrl: chatList[index]
                                                          ['profileImage']
                                                      .length >
                                                  0
                                              ? chatList[index]['profileImage']
                                              : "",
                                          peerName: chatList[index]['name'],
                                          archive:
                                              chatList[index]['archive'] != null
                                                  ? chatList[index]['archive']
                                                  : false,
                                          pin: chatList[index]['pin'] != null &&
                                                  chatList[index]['pin']
                                                          .length >
                                                      0
                                              ? '2549518301000'
                                              : '',
                                          mute: chatList[index]['mute'] != null
                                              ? chatList[index]['mute']
                                              : false,
                                        )));
                          },
                          onLongPress: () {
                            //getIds(chatList[index]['id']);

                            _settingModalBottomSheet(
                                context,
                                userID,
                                chatList[index]['id'],
                                chatList[index]['archive'] != null
                                    ? chatList[index]['archive']
                                    : false,
                                chatList[index]['timestamp'],
                                chatList[index]['pin'] != null
                                    ? chatList[index]['pin']
                                    : '',
                                chatList[index]['mute'] != null
                                    ? chatList[index]['mute']
                                    : false,
                                chatList[index]['badge'],
                                "group",
                                "",
                                "");
                          },
                          leading: new Stack(
                            children: <Widget>[
                              InkWell(
                                  onTap: () {
                                    showDialog(
                                      context,
                                      chatList[index]['name'],
                                      chatList[index]['profileImage'],
                                      "",
                                      chatList[index]['id'],
                                    );
                                  },
                                  child: chatList[index]['profileImage'] !=
                                              null &&
                                          chatList[index]['profileImage']
                                                  .length >
                                              0
                                      ? Container(
                                          height: 50,
                                          width: 55,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            child: customImage(chatList[index]
                                                ['profileImage']),
                                          ))
                                      : Container(
                                          height: 50,
                                          width: 55,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Image.asset(
                                              "assets/images/groupuser.png",
                                              height: 10,
                                              color: Colors.white,
                                            ),
                                          ))),
                            ],
                          ),
                          title: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text(
                                chatList[index]['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: appColorBlack,
                                    fontSize: 14,
                                    fontFamily: boldFamily),
                              ),
                            ],
                          ),
                          subtitle: msgTypeWidget(chatList[index]['type'],
                              chatList[index]['content'])),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: new Text(
                              readTimestamp(
                                  int.parse(chatList[index]['timestamp'])),
                              style: new TextStyle(
                                  color: int.parse(chatList[index]['badge']) > 0
                                      ? appColorBlue
                                      : Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: 5,
                          ),
                          Row(
                            children: [
                              int.parse(chatList[index]['badge']) > 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appColorBlue,
                                      ),
                                      alignment: Alignment.center,
                                      height: 20,
                                      width: 20,
                                      child: Text(
                                        chatList[index]['badge'],
                                        style: TextStyle(
                                            color: appColorWhite,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12),
                                      ),
                                    )
                                  : Container(),
                              chatList[index]['pin'] != null &&
                                      chatList[index]['pin'].length > 0
                                  ? Icon(Icons.push_pin,
                                      color: appColorBlue, size: 16)
                                  : Container(),
                              chatList[index]['mute'] == true
                                  ? Icon(Icons.volume_off,
                                      color: appColorBlue, size: 17)
                                  : Container()
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  Widget msgTypeWidget(int type, String content) {
    return new Container(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          type == 1
              ? Row(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                      size: 17,
                    ),
                    Text(
                      "  Photo",
                      maxLines: 1,
                      style: new TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                )
              : type == 4
                  ? Row(
                      children: [
                        Icon(
                          Icons.video_call,
                          color: Colors.grey,
                          size: 17,
                        ),
                        Text(
                          "  Video",
                          maxLines: 1,
                          style: new TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    )
                  : type == 5
                      ? Row(
                          children: [
                            Icon(
                              Icons.note,
                              color: Colors.grey,
                              size: 17,
                            ),
                            Text(
                              "  File",
                              maxLines: 1,
                              style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        )
                      : type == 6
                          ? Row(
                              children: [
                                Icon(
                                  Icons.audiotrack,
                                  color: Colors.grey,
                                  size: 17,
                                ),
                                Text(
                                  "  Audio",
                                  maxLines: 1,
                                  style: new TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            )
                          : Text(
                              content,
                              maxLines: 1,
                              style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal),
                            ),
        ],
      ),
    );
  }

  void _settingModalBottomSheet(context, userId, peerId, arch, timestamp, pin,
      mute, badge, chatType, peerName, peerMobile) {
    print(peerId);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                timestamp == '2549518301000'
                    ? ListTile(
                        title: Center(child: new Text('Unpin')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'pin': '', 'timestamp': pin});
                        })
                    : ListTile(
                        title: Center(child: new Text('Pin')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({
                            'pin': timestamp,
                            'timestamp': '2549518301000'
                          });
                        }),
                badge == "0"
                    ? ListTile(
                        title: Center(child: new Text('Mark as Unread')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'badge': '1'});
                        })
                    : ListTile(
                        title: Center(child: new Text('Mark as read')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'badge': '0'});
                        },
                      ),
                mute == true
                    ? ListTile(
                        title: Center(child: new Text('Unmute')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'mute': false});
                        },
                      )
                    : ListTile(
                        title: Center(child: new Text('Mute')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'mute': true});
                        },
                      ),
                arch == true
                    ? ListTile(
                        title: Center(child: new Text('Unarchive')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'archive': false});
                        },
                      )
                    : ListTile(
                        title: Center(child: new Text('Archive')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'archive': true});
                        },
                      ),
                savedContactUserId.contains(peerId) || chatType == "group"
                    ? Container()
                    : ListTile(
                        title: Center(child: new Text('Save Contact')),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SaveContact(
                                    name: peerName,
                                    phone: peerMobile,
                                    peerId: peerId)),
                          );
                        },
                      ),
                chatType == "group"
                    ? ListTile(
                        title: Center(
                          child: new Text(
                            'Exit Group',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);

                          final FirebaseDatabase database =
                              new FirebaseDatabase();

                          database
                              .reference()
                              .child('group')
                              .child(peerId)
                              .once()
                              .then((peerData) {
                            var ids = [];
                            ids.addAll(peerData.value['userId']);
                            ids.remove(userId);
                            DatabaseReference _userRef =
                                database.reference().child('group');

                            _userRef.child(peerId).update({
                              "userId": ids,
                            }).then((_) {
                              Firestore.instance
                                  .collection("chatList")
                                  .document(userId)
                                  .collection(userId)
                                  .document(peerId)
                                  .delete();
                            });
                          });
                        },
                      )
                    : ListTile(
                        title: Center(
                          child: new Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .delete();
                        },
                      ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: new RawMaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 2.0,
                      fillColor: Colors.grey[300],
                      child: Icon(
                        Icons.close,
                        size: 20.0,
                      ),
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void showDialog(BuildContext context, name, image, phone, id) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Barrier",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: SizeConfig.safeBlockVertical * 100,
            width: SizeConfig.screenWidth,
            child: Column(
              children: <Widget>[
                Container(
                    decoration: new BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          topRight: const Radius.circular(30.0),
                        )),
                    height: SizeConfig.safeBlockVertical * 30,
                    width: SizeConfig.screenWidth,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0)),
                      child: image.length > 0
                          ? Image.network(
                              image,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 50,
                            ),
                    )),
                Material(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0)),
                    ),
                    height: SizeConfig.blockSizeVertical * 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 8),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.blockSizeVertical * 2.5,
                                fontFamily: 'Montserrat'),
                          ),
                        ),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Text(
                                  phone,
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2,
                                      color: Colors.grey,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            ),
                            phone == ""
                                ? Container()
                                : RawMaterialButton(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();

                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => Chat(
                                                    peerID: id,
                                                  )));
                                    },
                                    elevation: 1,
                                    fillColor: Colors.white,
                                    child: Image.asset(
                                      "assets/images/chat.png",
                                      height: 27,
                                      color: appColorBlue,
                                    ),
                                    shape: CircleBorder(),
                                  ),
                            phone == ""
                                ? Container()
                                : RawMaterialButton(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ContactInfo(id: id)),
                                      );
                                    },
                                    elevation: 1,
                                    fillColor: Colors.white,
                                    child: Icon(
                                      Icons.info,
                                      size: 25.0,
                                      color: appColorBlue,
                                    ),
                                    shape: CircleBorder(),
                                  )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            margin: EdgeInsets.only(bottom: 45, left: 18, right: 18, top: 200),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    chatList.forEach((userDetail) {
      // for (int i = 0; i < chatList.length; i++) {
      if (userDetail['name'].toLowerCase().contains(text.toLowerCase())
          // ||chatList[i]['name'].toLowerCase().contains(text.toLowerCase())
          ) _searchResult.add(userDetail);
      // }
    });

    setState(() {});
  }
}

List _searchResult = [];
