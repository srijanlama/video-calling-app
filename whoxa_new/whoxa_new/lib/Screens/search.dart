import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:connectivity/connectivity.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutterwhatsappclone/Screens/archiveChatList.dart';
// import 'package:flutterwhatsappclone/Screens/broadCast/broadcast1.dart';
import 'package:flutterwhatsappclone/Screens/contactinfo.dart';
import 'package:flutterwhatsappclone/Screens/groupChat/groupChat.dart';
// import 'package:flutterwhatsappclone/Screens/newchat.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:timeago/timeago.dart';
import 'chat.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Search extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<Search> {
  String currentusername;
  String currentuserimage;
  String currentuserMob;
  String userId = '';
  final FirebaseDatabase database = new FirebaseDatabase();
  TextEditingController controller = new TextEditingController();
  var groupUsersId = [];
  String groupChatId = '';
  String searchValue = '';
  List chatList;
  List messageList;

  //APP BAR SCROLL

  final dateFormat = new DateFormat('dd/MM/yyyy');

  @override
  void initState() {
   

    FirebaseAuth.instance.currentUser().then((user) {
      //  print(user.uid);
      setState(() {
        userID = user.uid;
        userId = user.uid;

        getUser();
        // getAllMsg();
      });
    });

    super.initState();
  }

  // getAllMsg() {
  //   print(savedContactUserId.length);
  //   for (var i = 0; i <= savedContactUserId.length; i++) {
  //     String pId = '';
  //     if (userId.hashCode <= savedContactUserId[i].hashCode) {
  //       pId = '$userId-${savedContactUserId[i]}';
  //     } else {
  //       pId = '${savedContactUserId[i]}-$userId';
  //     }
  //     Firestore.instance
  //         .collection('messages')
  //         .document(pId)
  //         .collection(pId)
  //         .orderBy('timestamp', descending: true)
  //         .getDocuments()
  //         .then((querySnapshot) {
  //       print(querySnapshot.documents);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Padding(
              padding: const EdgeInsets.only(top: 10, right: 0, left: 0),
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors.green,
                    borderRadius: new BorderRadius.all(
                      Radius.circular(15.0),
                    )),
                height: 40,
                child: Center(
                  child: TextField(
                    controller: controller,
                    onChanged: (value) {
                      searchValue = value;
                      onSearchTextChanged(value);
                      //onMessageTextChanged(value);
                    },
                    style: TextStyle(color: Colors.grey),
                    decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[200]),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[200]),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[200]),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                      ),
                      filled: true,
                      hintStyle:
                          new TextStyle(color: Colors.grey[600], fontSize: 14),
                      hintText: "Search",
                      contentPadding: EdgeInsets.only(top: 10.0),
                      fillColor: Colors.grey[200],
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 25.0,
                      ),
                    ),
                  ),
                ),
              )),
          centerTitle: false,
          elevation: 1,
          backgroundColor: appColorWhite,
          automaticallyImplyLeading: false,
          leading: null,
          actions: <Widget>[
            Container(
              width: 50,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: CustomText(
                  alignment: Alignment.center,
                  text: "Cancel",
                  color: appColorBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Container(width: 15),
          ],
        ),
        body: StreamBuilder(
          stream: Firestore.instance
              .collection("chatList")
              .document(userId)
              .collection(userId)
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              chatList = snapshot.data.documents;
              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      primary: true,
                      shrinkWrap: false,
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              friendListToMessage(snapshot.data.documents),
                              ListView.builder(
                                itemCount: savedContactUserId.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, int index) {
                                  return userMessages(
                                      savedContactUserId[index]);
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        ));
  }

  Widget friendListToMessage(chatList) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(40), topLeft: Radius.circular(40)),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: chatList.length > 0
                ? _searchResult.length != 0 ||
                        controller.text.trim().toLowerCase().isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResult.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return _searchResult[index]['archive'] != null &&
                                  _searchResult[index]['archive'] == false
                              ? _searchResult[index]['chatType'] != null &&
                                      _searchResult[index]['chatType'] ==
                                          "group"
                                  ? buildGroupItem(_searchResult, index)
                                  : buildItem(_searchResult, index)
                              : Container();
                        },
                      )
                    : ListView.builder(
                        itemCount: chatList.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return chatList[index]['archive'] != null &&
                                  chatList[index]['archive'] == false
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
          )),
    );
  }

  Widget userMessages(peerID) {
    groupChatId = '';
    if (userId.hashCode <= peerID.hashCode) {
      groupChatId = '$userId-$peerID';
    } else {
      groupChatId = '$peerID-$userId';
    }
    return StreamBuilder(
      stream: Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .asBroadcastStream(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1) {
        if (snapshot1.hasData) {
          return messageListWidget(snapshot1.data.documents);
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

  Widget messageListWidget(message) {
    return controller.text.isEmpty
        ? Container()
        : ListView.builder(
            itemCount: message.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, int index) {
              return messageWidget(message, index);
            },
          );
    // _messageResult.length > 0 ||
    //         controller.text.trim().toLowerCase().isNotEmpty
    //     ?
    //     ListView.builder(
    //         itemCount: _messageResult.length,
    //         physics: NeverScrollableScrollPhysics(),
    //         shrinkWrap: true,
    //         itemBuilder: (context, int index) {
    //           return messageWidget(_messageResult, index);
    //         },
    //       )
    //     : ListView.builder(
    //         padding: const EdgeInsets.all(0),
    //         itemCount: message.length,
    //         physics: NeverScrollableScrollPhysics(),
    //         shrinkWrap: true,
    //         itemBuilder: (context, int index) {
    //           return messageWidget(message, index);
    //         },
    //       );
  }

  Widget messageWidget(message, index) {
    return
        // message[index]["idFrom"] != userId
        message[index]["fromName"]
                    .contains(RegExp(controller.text, caseSensitive: false)) ||
                message[index]["toName"]
                    .contains(RegExp(controller.text, caseSensitive: false)) ||
                message[index]["content"]
                    .contains(RegExp(controller.text, caseSensitive: false))
            ? InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => Chat(
                              searchText: searchValue,
                              searchTime:
                                  message[index]["timestamp"].toString(),
                              peerID: message[index]["idFrom"] != userId
                                  ? message[index]["idFrom"]
                                  : message[index]["idTo"],
                              archive: false,
                              pin: '',
                              
                              chatListTime: "")));
                },
                child: Column(
                  children: [
                    new Divider(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 5),
                      child: Row(
                        children: [
                          savedContactUserId.contains(
                                      message[index]["idFrom"] != userId
                                          ? message[index]["idFrom"]
                                          : message[index]["idTo"]) &&
                                  allcontacts != null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    for (var i = 0; i < allcontacts.length; i++)
                                      Text(
                                        allcontacts[i]
                                                .phones
                                                .map((e) => e.value)
                                                .toString()
                                                .replaceAll(
                                                    new RegExp(r"\s+\b|\b\s"),
                                                    "")
                                                .contains(message[index]
                                                            ["idFrom"] !=
                                                        userId
                                                    ? message[index]["fromMob"]
                                                    : message[index]["toMob"])
                                            ? allcontacts[i].displayName
                                            : "",
                                        style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: appColorGrey,
                                          fontSize: 14,
                                        ),
                                      )
                                  ],
                                )
                              : Text(
                                  message[index]["idFrom"] != userId
                                      ? message[index]["fromMob"]
                                      : message[index]["toMob"],
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                          Expanded(child: Container()),
                          CustomText(
                              text: dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(int.parse(
                                  message[index]['timestamp'],
                                )),
                              ),
                              color: appColorGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              alignment: Alignment.centerLeft),
                          Container(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: appColorGrey,
                          ),
                          Container(
                            width: 5,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: message[index]["idFrom"] == userId
                                            ? "You: "
                                            : "",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: message[index]['content'],
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.normal))
                                  ])),
                            ),
                          ],
                        )),
                    Container(
                      height: 5,
                    ),
                  ],
                ),
              )
            : Container();

    //  StreamBuilder(
    //   stream: message[index]["idFrom"] == null
    //       ? Container()
    //       : FirebaseDatabase.instance
    //           .reference()
    //           .child('user')
    //           .child(message[index]["idFrom"] != userId
    //                  ? message[index]["idFrom"]
    //                  : message[index]["idTo"])
    //           .onValue,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return
    //       snapshot.data.snapshot.value["name"].contains(
    //                   new RegExp(controller.text, caseSensitive: false)) ||
    //               message[index]["content"].contains(
    //                   new RegExp(controller.text, caseSensitive: false))
    //           ?
    //            InkWell(
    //               onTap: () {
    //                 Navigator.push(
    //                     context,
    //                     CupertinoPageRoute(
    //                         builder: (context) => Chat(
    //                             searchText: searchValue,
    //                             searchTime: message[index]["timestamp"].toString(),
    //                             peerID: snapshot.data.snapshot.value["userId"],
    //                             archive: false,
    //                             pin: '',
    //                             mute: false,
    //                             chatListTime: "")));
    //               },
    //               child: Column(
    //                 children: [
    //                   new Divider(
    //                     height: 10.0,
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.only(
    //                         left: 15, right: 15, top: 10, bottom: 5),
    //                     child: Row(
    //                       children: [
    //                         savedContactUserId.contains(snapshot
    //                                     .data.snapshot.value["userId"]) &&
    //                                 allcontacts != null
    //                             ? Row(
    //                                 mainAxisAlignment: MainAxisAlignment.start,
    //                                 children: <Widget>[
    //                                   for (var i = 0;i < allcontacts.length;i++)
    //                                     Text(allcontacts[i] .phones
    //                                               .map((e) => e.value)
    //                                               .toString()
    //                                               .replaceAll( new RegExp(r"\s+\b|\b\s"), "")
    //                                               .contains(snapshot.data.snapshot.value["mobile"])
    //                                           ? allcontacts[i].displayName
    //                                           : "",
    //                                       style: new TextStyle(
    //                                         fontWeight: FontWeight.bold,
    //                                         color: appColorGrey,
    //                                         fontSize: 14,
    //                                       ),
    //                                     )
    //                                 ],
    //                               )
    //                             : Text(
    //                                 snapshot.data.snapshot.value["mobile"],
    //                                 style: new TextStyle(
    //                                     fontWeight: FontWeight.bold),
    //                               ),

    //                         Expanded(child: Container()),
    //                         CustomText(
    //                             text: dateFormat.format(
    //                               DateTime.fromMillisecondsSinceEpoch(int.parse(
    //                                 message[index]['timestamp'],
    //                               )),
    //                             ),
    //                             color: appColorGrey,
    //                             fontSize: 13,
    //                             fontWeight: FontWeight.normal,
    //                             alignment: Alignment.centerLeft),
    //                         Container(
    //                           width: 10,
    //                         ),
    //                         Icon(
    //                           Icons.arrow_forward_ios,
    //                           size: 15,
    //                           color: appColorGrey,
    //                         ),
    //                         Container(
    //                           width: 5,
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   Padding(
    //                       padding: const EdgeInsets.only(left: 20),
    //                       child: Row(
    //                         children: [
    //                           Expanded(
    //                             child: RichText(
    //                                 textAlign: TextAlign.left,
    //                                 text: TextSpan(children: [
    //                                   TextSpan(
    //                                       text:
    //                                           message[index]["idFrom"] == userId
    //                                               ? "You: "
    //                                               : "",
    //                                       style: TextStyle(
    //                                           fontSize: 14,
    //                                           color: Colors.grey,
    //                                           fontWeight: FontWeight.bold)),
    //                                   TextSpan(
    //                                       text: message[index]['content'],
    //                                       style: TextStyle(
    //                                           fontSize: 13,
    //                                           color: Colors.grey,
    //                                           fontWeight: FontWeight.normal))
    //                                 ])),
    //                           ),
    //                         ],
    //                       )),
    //                   Container(
    //                     height: 5,
    //                   ),
    //                 ],
    //               ),
    //             )
    //           : Container();
    //     }
    //     return Container(
    //       height: MediaQuery.of(context).size.height,
    //       width: MediaQuery.of(context).size.width,
    //       alignment: Alignment.center,
    //       child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           mainAxisSize: MainAxisSize.max,
    //           children: <Widget>[
    //             CupertinoActivityIndicator(),
    //           ]),
    //     );
    //   },
    // );
  }

  Widget buildItem(List chatList, int index) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child('user')
          .child(chatList[index]['id'])
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              new Divider(
                height: 10.0,
              ),
              Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: Row(
                  children: [
                    Expanded(
                      child: new ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => Chat(
                                        peerID: chatList[index]['id'],
                                        archive:
                                            chatList[index]['archive'] != null
                                                ? chatList[index]['archive']
                                                : false,
                                        pin: chatList[index]['pin'] != null &&
                                                chatList[index]['pin'].length >
                                                    0
                                            ? '2549518301000'
                                            : '',
                                       
                                        chatListTime: chatList[index]
                                            ['timestamp'])));
                          },
                          onLongPress: () {
                            getIds(chatList[index]['id']);

                            _settingModalBottomSheet(
                                context,
                                userId,
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
                                chatList[index]['chatType'] != null &&
                                        chatList[index]['chatType'] == "group"
                                    ? "group"
                                    : "normal");
                          },
                          leading: new Stack(
                            children: <Widget>[
                              InkWell(
                                  onTap: () {
                                    showDialog(
                                      context,
                                      snapshot.data.snapshot.value["name"],
                                      snapshot.data.snapshot.value["img"],
                                      snapshot.data.snapshot.value["mobile"],
                                      chatList[index]['id'],
                                    );
                                  },
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      child: snapshot.data.snapshot.value["img"]
                                                      .length >
                                                  0 &&
                                              snapshot.data.snapshot
                                                      .value["profileseen"] !=
                                                  "nobody"
                                          ? Container(
                                              height: 50,
                                              width: 50,
                                              child: CircleAvatar(
                                                //radius: 60,
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                backgroundColor: Colors.grey,
                                                backgroundImage:
                                                    new NetworkImage(snapshot
                                                        .data
                                                        .snapshot
                                                        .value["img"]),
                                              ),
                                            )
                                          : Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[400],
                                                  shape: BoxShape.circle),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Image.asset(
                                                  "assets/images/user.png",
                                                  height: 10,
                                                  color: Colors.white,
                                                ),
                                              )))),
                            ],
                          ),
                          title: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              savedContactUserId.contains(snapshot
                                          .data.snapshot.value["userId"]) &&
                                      allcontacts != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        for (var i = 0;
                                            i < allcontacts.length;
                                            i++)
                                          Text(
                                            allcontacts[i]
                                                    .phones
                                                    .map((e) => e.value)
                                                    .toString()
                                                    .replaceAll(
                                                        new RegExp(
                                                            r"\s+\b|\b\s"),
                                                        "")
                                                    .contains(snapshot
                                                        .data
                                                        .snapshot
                                                        .value["mobile"])
                                                ? allcontacts[i].displayName
                                                : "",
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                      ],
                                    )
                                  : Text(
                                      snapshot.data.snapshot.value["mobile"],
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                              // new Text(
                              //   snapshot.data.snapshot.value["name"],
                              //   style:
                              //       new TextStyle(fontWeight: FontWeight.bold),
                              // ),
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
                              format(
                                  DateTime.fromMillisecondsSinceEpoch(int.parse(
                                    chatList[index]['timestamp'],
                                  )),
                                  locale: 'en_short'),
                              style: new TextStyle(
                                  color: int.parse(chatList[index]['badge']) > 0
                                      ? Colors.blue
                                      : Colors.grey,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500),
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
                                        color: Colors.blue,
                                      ),
                                      alignment: Alignment.center,
                                      height: 20,
                                      width: 20,
                                      child: Text(
                                        chatList[index]['badge'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12),
                                      ),
                                    )
                                  : Container(child: Text("")),
                              chatList[index]['pin'] != null &&
                                      chatList[index]['pin'].length > 0
                                  ? Icon(Icons.push_pin,
                                      color: Colors.grey, size: 16)
                                  : Container(),
                              chatList[index]['mute'] == true
                                  ? Icon(Icons.volume_off,
                                      color: Colors.grey, size: 17)
                                  : Container()
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: 'More',
                    color: Colors.grey[400],
                    foregroundColor: Colors.black,
                    icon: Icons.more_horiz,
                    onTap: () {
                      _settingModalBottomSheet(
                          context,
                          userId,
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
                          "normal");
                    },
                  ),
                ],
              )
            ],
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

  Widget buildGroupItem(List chatList, int index) {
    return Column(
      children: <Widget>[
        new Divider(
          height: 10.0,
        ),
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Row(
            children: [
              Expanded(
                child: new ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => GroupChat(
                                    currentuser: userId,
                                    currentusername: currentusername,
                                    currentuserimage: currentuserimage,
                                    peerID: chatList[index]['id'],
                                    peerUrl:
                                        chatList[index]['profileImage'].length >
                                                0
                                            ? chatList[index]['profileImage']
                                            : "",
                                    peerName: chatList[index]['name'],
                                    archive: chatList[index]['archive'] != null
                                        ? chatList[index]['archive']
                                        : false,
                                    pin: chatList[index]['pin'] != null &&
                                            chatList[index]['pin'].length > 0
                                        ? '2549518301000'
                                        : '',
                                    mute: chatList[index]['mute'] != null
                                        ? chatList[index]['mute']
                                        : false,
                                  )));
                    },
                    onLongPress: () {
                      getIds(chatList[index]['id']);

                      _settingModalBottomSheet(
                          context,
                          userId,
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
                          "group");
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
                            child: Container(
                                height: 50,
                                width: 50,
                                child: chatList[index]['profileImage'] !=
                                            null &&
                                        chatList[index]['profileImage'].length >
                                            0
                                    ? Container(
                                        height: 50,
                                        width: 50,
                                        child: CircleAvatar(
                                          //radius: 60,
                                          foregroundColor:
                                              Theme.of(context).primaryColor,
                                          backgroundColor: Colors.grey,
                                          backgroundImage: new NetworkImage(
                                              chatList[index]['profileImage']),
                                        ),
                                      )
                                    : Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Image.asset(
                                            "assets/images/groupuser.png",
                                            height: 10,
                                            color: Colors.white,
                                          ),
                                        )))),
                      ],
                    ),
                    title: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(
                          chatList[index]['name'],
                          style: new TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: msgTypeWidget(
                        chatList[index]['type'], chatList[index]['content'])),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: new Text(
                        format(
                            DateTime.fromMillisecondsSinceEpoch(int.parse(
                              chatList[index]['timestamp'],
                            )),
                            locale: 'en_short'),
                        style: new TextStyle(
                            color: int.parse(chatList[index]['badge']) > 0
                                ? Colors.blue
                                : Colors.grey,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
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
                                  color: Colors.blue,
                                ),
                                alignment: Alignment.center,
                                height: 20,
                                width: 20,
                                child: Text(
                                  chatList[index]['badge'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12),
                                ),
                              )
                            : Container(child: Text("")),
                        chatList[index]['pin'] != null &&
                                chatList[index]['pin'].length > 0
                            ? Icon(Icons.push_pin, color: Colors.grey, size: 16)
                            : Container(),
                        chatList[index]['mute'] == true
                            ? Icon(Icons.volume_off,
                                color: Colors.grey, size: 17)
                            : Container()
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'More',
              color: Colors.grey[400],
              foregroundColor: Colors.black,
              icon: Icons.more_horiz,
              onTap: () {
                _settingModalBottomSheet(
                    context,
                    userId,
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
                    chatList[index]['chatType'] != null &&
                            chatList[index]['chatType'] == "group"
                        ? "group"
                        : "normal");
              },
            ),
          ],
        )
      ],
    );
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
                      maxLines: 2,
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
                          maxLines: 2,
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
                              maxLines: 2,
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
                                  maxLines: 2,
                                  style: new TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            )
                          : Text(
                              content,
                              maxLines: 2,
                              style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal),
                            ),
        ],
      ),
    );
  }

  void _settingModalBottomSheet(
      context, userId, peerId, arch, timestamp, pin, mute, badge, chatType) {
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
                              fit: BoxFit.cover,
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

  getUser() async {
    database.reference().child('user').child(userId).once().then((peerData) {
      setState(() {
        userID = userId;
        globalName = peerData.value['name'];
        globalImage = peerData.value['img'];
        currentusername = peerData.value['name'];
        currentuserimage = peerData.value['img'];
        mobNo = peerData.value['mobile'];
        currentuserMob =
            peerData.value['countryCode'] + peerData.value['mobile'];
        fullMob = currentuserMob;
        //   print("Mob: " + fullMob);
      });
    });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();

    chatList.forEach((userDetail) {
      if (userDetail['name'] != null) if (userDetail['name']
          .toLowerCase()
          .contains(text.toLowerCase())) _searchResult.add(userDetail);
    });
    setState(() {});
    //
  }

  onMessageTextChanged(String text) async {
    _messageResult.clear();

    messageList.forEach((userDetail) {
      if (userDetail['content'] != null) print(userDetail['content']);

      if (userDetail['content'].toLowerCase().contains(text.toLowerCase()))
        _messageResult.add(userDetail);
      setState(() {});
    });
    //
  }

  getIds(id) async {
    final FirebaseDatabase database = new FirebaseDatabase();

    database
        .reference()
        .child('group')
        .child(id)
        .orderByChild("userId")
        .once()
        .then((peerData) {
      groupUsersId = peerData.value['userId'];
      //  print("groupUsersId>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    });
  }
}

List _searchResult = [];
List _messageResult = [];
