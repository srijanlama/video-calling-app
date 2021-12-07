import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/chat.dart';
import 'package:flutterwhatsappclone/Screens/contactinfo.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call_utilities.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/callModal.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/user.dart' as videoCall;
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class CallHistory extends StatefulWidget {
  TextEditingController controller;
  CallHistory({this.controller});

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<CallHistory> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  Query query;
  String userId;
  StreamSubscription<Event> _onOrderAddedSubscription;
  StreamSubscription<Event> _onOrderChangedSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  videoCall.User sender = videoCall.User();
  videoCall.User receiver = videoCall.User();
  bool editButton = false;
  //TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();

    sender.uid = userID;
    sender.name = globalName;
    sender.profilePhoto = globalImage;

    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;
      });
      // ignore: deprecated_member_use
      callList = new List();
      query = database
          .reference()
          .child("call_history")
          .orderByChild("mainId")
          .equalTo(userId);
      _onOrderAddedSubscription = query.onChildAdded.listen(onEntryAdded1);
      _onOrderChangedSubscription =
          query.onChildChanged.listen(onEntryChanged1);
    });
  }

  @override
  void dispose() {
    _onOrderAddedSubscription.cancel();
    _onOrderChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged1(Event event) {
    var oldEntry = callList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      callList[callList.indexOf(oldEntry)] =
          CallModal.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded1(Event event) {
    setState(() {
      callList.add(CallModal.fromSnapshot(event.snapshot));
      callList.sort((a, b) => b.time.compareTo(a.time));
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                // editButton == true
                //     ? Align(
                //         alignment: Alignment.topLeft,
                //         child: InkWell(
                //           onTap: () {
                //             setState(() {
                //               editButton = false;
                //             });
                //           },
                //           child: Padding(
                //             padding: const EdgeInsets.only(top: 0, left: 0),
                //             child: Text(
                //               "Done",
                //               style: TextStyle(
                //                   color: appColorBlue,
                //                   fontSize: SizeConfig.blockSizeHorizontal * 4,
                //                   fontWeight: FontWeight.bold),
                //             ),
                //           ),
                //         ),
                //       )
                //     : Align(
                //         alignment: Alignment.topLeft,
                //         child: InkWell(
                //           onTap: () {
                //             setState(() {
                //               editButton = true;
                //             });
                //           },
                //           child: Padding(
                //             padding: const EdgeInsets.only(top: 0, left: 0),
                //             child: Text(
                //               "Edit",
                //               style: TextStyle(
                //                   color: appColorBlue,
                //                   fontSize: SizeConfig.blockSizeHorizontal * 4,
                //                   fontWeight: FontWeight.bold),
                //             ),
                //           ),
                //         ),
                //       ),
                allCalls()
              ],
            ),
          ),
          // Column(
          //   children: [
          //     Expanded(
          //       child: Padding(
          //         padding: const EdgeInsets.only(top: 0),
          //         child: DefaultTabController(
          //           length: 2,
          //           initialIndex: 0,
          //           child: Column(
          //             children: <Widget>[
          //               Padding(
          //                 padding: const EdgeInsets.only(
          //                     top: 60, left: 15, right: 15),
          //                 child: Row(
          //                   children: <Widget>[
          //                     editButton == true
          //                         ? Align(
          //                             alignment: Alignment.topLeft,
          //                             child: InkWell(
          //                               onTap: () {
          //                                 setState(() {
          //                                   editButton = false;
          //                                 });
          //                               },
          //                               child: Padding(
          //                                 padding: const EdgeInsets.only(
          //                                     top: 0, left: 0),
          //                                 child: Text(
          //                                   "Done",
          //                                   style: TextStyle(
          //                                       color: appColorBlue,
          //                                       fontSize: SizeConfig
          //                                               .blockSizeHorizontal *
          //                                           4,
          //                                       fontWeight: FontWeight.bold),
          //                                 ),
          //                               ),
          //                             ),
          //                           )
          //                         : Align(
          //                             alignment: Alignment.topLeft,
          //                             child: InkWell(
          //                               onTap: () {
          //                                 setState(() {
          //                                   editButton = true;
          //                                 });
          //                               },
          //                               child: Padding(
          //                                 padding: const EdgeInsets.only(
          //                                     top: 0, left: 0),
          //                                 child: Text(
          //                                   "Edit",
          //                                   style: TextStyle(
          //                                       color: appColorBlue,
          //                                       fontSize: SizeConfig
          //                                               .blockSizeHorizontal *
          //                                           4,
          //                                       fontWeight: FontWeight.bold),
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                     Expanded(
          //                       child: Align(
          //                         alignment: Alignment.center,
          //                         child: Padding(
          //                           padding: const EdgeInsets.only(top: 0),
          //                           child: Container(
          //                             width:
          //                                 SizeConfig.blockSizeHorizontal * 46.4,
          //                             height: SizeConfig.blockSizeVertical * 4,
          //                             decoration: new BoxDecoration(
          //                                 borderRadius:
          //                                     BorderRadius.circular(10),
          //                                 color: Colors.grey[100]),
          //                             child: Center(
          //                               child: TabBar(
          //                                 labelColor: Colors.black,

          //                                 // isScrollable: true,
          //                                 labelStyle: TextStyle(
          //                                     fontSize: 13.0,
          //                                     fontFamily: "MontserratBold"),

          //                                 indicator: BoxDecoration(
          //                                     borderRadius:
          //                                         BorderRadius.circular(10),
          //                                     color: Colors.grey[300]),

          //                                 tabs: <Widget>[
          //                                   Tab(
          //                                     text: 'All',
          //                                   ),
          //                                   Tab(
          //                                     text: 'Missed',
          //                                   ),
          //                                 ],
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                     editButton == true
          //                         ? Align(
          //                             alignment: Alignment.topRight,
          //                             child: Padding(
          //                                 padding: const EdgeInsets.only(
          //                                     top: 0, right: 0),
          //                                 child: InkWell(
          //                                   onTap: () {
          //                                     clearAllMenu(context);
          //                                   },
          //                                   child: Text(
          //                                     "Clear",
          //                                     style: TextStyle(
          //                                         color: appColorGreen,
          //                                         fontWeight: FontWeight.bold,
          //                                         fontSize: 16),
          //                                   ),
          //                                 )),
          //                           )
          //                         : Align(
          //                             alignment: Alignment.topRight,
          //                             child: Padding(
          //                                 padding: const EdgeInsets.only(
          //                                     top: 0, right: 0),
          //                                 child: IconButton(
          //                                   onPressed: () {
          //                                     Navigator.push(
          //                                       context,
          //                                       MaterialPageRoute(
          //                                           builder: (context) =>
          //                                               NewCall()),
          //                                     );
          //                                   },
          //                                   icon: Icon(
          //                                     Icons.add_call,
          //                                     color: appColorBlue,
          //                                   ),
          //                                 )),
          //                           ),
          //                   ],
          //                 ),
          //               ),
          //               Row(
          //                 children: <Widget>[
          //                   Padding(
          //                     padding: const EdgeInsets.only(left: 20, top: 20),
          //                     child: Text(
          //                       'Calls',
          //                       style: TextStyle(
          //                           fontFamily: "MontserratBold",
          //                           fontSize:
          //                               SizeConfig.blockSizeHorizontal * 7),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //               Divider(
          //                 thickness: 1,
          //               ),
          //               Padding(
          //                   padding: const EdgeInsets.only(
          //                       top: 10, right: 20, left: 20),
          //                   child: Container(
          //                     decoration: new BoxDecoration(
          //                         color: appColorBlue,
          //                         borderRadius: new BorderRadius.all(
          //                           Radius.circular(40.0),
          //                         )),
          //                     height: 40,
          //                     child: Center(
          //                       child: TextField(
          //                         controller: controller,
          //                         onChanged: onSearchTextChanged,
          //                         style: TextStyle(color: Colors.grey),
          //                         decoration: new InputDecoration(
          //                           border: new OutlineInputBorder(
          //                             borderSide: new BorderSide(
          //                                 color: Colors.grey[300]),
          //                             borderRadius: const BorderRadius.all(
          //                               const Radius.circular(40.0),
          //                             ),
          //                           ),
          //                           focusedBorder: OutlineInputBorder(
          //                             borderSide: new BorderSide(
          //                                 color: Colors.grey[300]),
          //                             borderRadius: const BorderRadius.all(
          //                               const Radius.circular(40.0),
          //                             ),
          //                           ),
          //                           enabledBorder: OutlineInputBorder(
          //                             borderSide: new BorderSide(
          //                                 color: Colors.grey[300]),
          //                             borderRadius: const BorderRadius.all(
          //                               const Radius.circular(40.0),
          //                             ),
          //                           ),
          //                           filled: true,
          //                           hintStyle:
          //                               new TextStyle(color: Colors.grey),
          //                           hintText: "Search",
          //                           contentPadding: EdgeInsets.only(top: 10.0),
          //                           fillColor: Colors.grey[200],
          //                           prefixIcon: Icon(
          //                             Icons.search,
          //                             color: appColorBlue,
          //                             size: 30.0,
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   )),
          //               Expanded(
          //                 child: TabBarView(
          //                   children: <Widget>[allCalls(), missedCalls()],
          //                 ),
          //               )
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //     admobWidget()
          //   ],
          // ),
        ),
      ),
    );
  }

  Widget allCalls() {
    return callList != null && callList.length > 0
        ?
        // _searchResult.length != 0 ||
        //         controller.text.trim().toLowerCase().isNotEmpty
        //     ? ListView.builder(
        //         itemCount: _searchResult.length,
        //         itemBuilder: (context, int index) {
        //           return callWidget(_searchResult, index);
        //         },
        //       )
        //     :
        ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: callList.length > 10 ? 10 : callList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return callList[index].name == null
                  ? Container()
                  : callWidget(callList, index);
            },
          )
        : Container();
  }

  Widget callWidget(List<CallModal> callList, index) {
    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child('user')
            .child(callList[index].recId != userID
                ? callList[index].recId
                : callList[index].callerId)
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return getContactName(snapshot.data.snapshot.value["mobile"] != null
                            ? snapshot.data.snapshot.value["mobile"]
                            : "000000000")
                        .contains(new RegExp(widget.controller.text,
                            caseSensitive: false)) ||
                    widget.controller.text.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 10, bottom: 10),
                    child: Material(
                      elevation: 5,
                      color: appColorWhite,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, bottom: 5, left: 10),
                        child: Row(
                          children: [
                            editButton == true
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                      child: IconButton(
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.remove,
                                            color: appColorWhite,
                                          ),
                                          onPressed: () {
                                            deleteOrder(
                                                callList[index].key, index);
                                          }),
                                    ),
                                  )
                                : Container(),
                            Expanded(
                              child: ListTile(
                                leading: snapshot
                                            .data.snapshot.value["img"].length >
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
                                          child: customImage(snapshot
                                              .data.snapshot.value["img"]),
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
                                            "assets/images/user.png",
                                            height: 10,
                                            color: Colors.white,
                                          ),
                                        )),
                                title: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        getContactName(snapshot
                                            .data.snapshot.value["mobile"]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: new TextStyle(
                                            fontSize: 14,
                                            color: appColorBlack,
                                            fontFamily: boldFamily,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: new Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: <Widget>[
                                      callList[index].callType == "voice"
                                          ? Image.asset(
                                              "assets/images/call_blue.png",
                                              color: callList[index]
                                                          .callStatus ==
                                                      "Missed"
                                                  ? Colors.red
                                                  : callList[index]
                                                              .callStatus ==
                                                          "Incoming"
                                                      ? Colors.green
                                                      : callList[index]
                                                                  .callStatus ==
                                                              "Outgoing"
                                                          ? Colors.blue
                                                          : Colors.grey,
                                              height: 15,
                                            )
                                          : Image.asset(
                                              "assets/images/Video_Call.png",
                                              color: callList[index]
                                                          .callStatus ==
                                                      "Missed"
                                                  ? Colors.red
                                                  : callList[index]
                                                              .callStatus ==
                                                          "Incoming"
                                                      ? Colors.green
                                                      : callList[index]
                                                                  .callStatus ==
                                                              "Outgoing"
                                                          ? Colors.blue
                                                          : Colors.grey,
                                              height: 10,
                                            ),
                                      SizedBox(
                                        width:
                                            SizeConfig.blockSizeHorizontal * 1,
                                      ),
                                      new Text(
                                        callList[index].callStatus,
                                        style: new TextStyle(
                                            color: callList[index].callStatus ==
                                                    "Missed"
                                                ? Colors.red
                                                : callList[index].callStatus ==
                                                        "Incoming"
                                                    ? Colors.green
                                                    : callList[index]
                                                                .callStatus ==
                                                            "Outgoing"
                                                        ? Colors.blue
                                                        : Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            endWidget(
                                callList,
                                index,
                                callList[index].recId != userID
                                    ? callList[index].recId
                                    : callList[index].callerId)
                          ],
                        ),
                      ),
                    ),
                  )
                : Container();
          else
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
        });
  }

  endWidget(List<CallModal> callList, int index, String peerId) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Row(
            children: [
              Container(
                width: 30,
                child: IconButton(
                    icon: Icon(
                      CupertinoIcons.phone_fill,
                      color: appColorGrey,
                      size: 20,
                    ),
                    onPressed: () {
                      database
                          .reference()
                          .child('user')
                          .child(peerId)
                          .once()
                          .then((peerData) {
                        receiver.uid = peerId;
                        receiver.name = callList[index].name;
                        receiver.profilePhoto = callList[index].image;
                        sendCallNotification(peerData.value['token'],
                            "$appName Voice Calling....");
                        CallUtils.dial(
                            from: sender,
                            to: receiver,
                            context: context,
                            status: "voicecall");
                      });
                    }),
              ),
              Container(width: 10),
              Container(
                width: 30,
                child: IconButton(
                    icon: Icon(
                      CupertinoIcons.videocam_fill,
                      color: appColorGrey,
                      size: 25,
                    ),
                    onPressed: () {
                      database
                          .reference()
                          .child('user')
                          .child(peerId)
                          .once()
                          .then((peerData) {
                        receiver.uid = peerId;
                        receiver.name = callList[index].name;
                        receiver.profilePhoto = callList[index].image;
                        sendCallNotification(peerData.value['token'],
                            "$appName Video Calling....");
                        CallUtils.dial(
                            from: sender,
                            to: receiver,
                            context: context,
                            status: "videocall");
                      });
                    }),
              ),
              Container(width: 10),
              Container(
                width: 30,
                child: IconButton(
                    icon: Icon(
                      CupertinoIcons.bubble_right_fill,
                      color: appColorGrey,
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => Chat(
                                    peerID: peerId,
                                    archive: false,
                                    pin: '',
                                   
                                  )));
                    }),
              ),
              Container(width: 15),
            ],
          ),
        ),
        Container(
          child: Row(
            children: [
              Text(
                readTimestamp(int.parse(callList[index].time)),
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                width: 30,
                child: IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: appColorGrey,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactInfo(
                                  id: peerId,
                                  imageMedia: [],
                                  videoMedia: [],
                                  docsMedia: [],
                                  imageMediaTime: [],
                                  blocksId: [],
                                  chat: true,
                                )),
                      );
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget missedCalls() {
    return callList != null && callList.length > 0
        ? ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: callList.length,
            itemBuilder: (BuildContext context, int index) {
              return callList[index].name == null
                  ? Container()
                  : callList[index].callStatus != "Missed"
                      ? Container()
                      : Column(
                          children: <Widget>[
                            Row(
                              children: [
                                editButton == true
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle),
                                          child: IconButton(
                                              padding: const EdgeInsets.all(0),
                                              icon: Icon(
                                                Icons.remove,
                                                color: appColorWhite,
                                              ),
                                              onPressed: () {
                                                deleteOrder(
                                                    callList[index].key, index);
                                              }),
                                        ),
                                      )
                                    : Container(),
                                Expanded(
                                  child: ListTile(
                                    onTap: () {
                                      if (editButton == false)
                                        database
                                            .reference()
                                            .child('user')
                                            .child(callList[index].recId)
                                            .once()
                                            .then((peerData) {
                                          receiver.uid = callList[index].recId;
                                          receiver.name = callList[index].name;
                                          receiver.profilePhoto =
                                              callList[index].image;
                                          sendCallNotification(
                                              peerData.value['token'],
                                              "Wootsapp ${callList[index].callType} Calling....");
                                          CallUtils.dial(
                                              from: sender,
                                              to: receiver,
                                              context: context,
                                              status:
                                                  "${callList[index].callType}call");
                                        });
                                    },
                                    leading: Container(
                                      height: 45,
                                      width: 45,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        backgroundImage: new NetworkImage(
                                            callList[index].image.length > 0
                                                ? callList[index].image
                                                : noImage),
                                      ),
                                    ),
                                    title: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Text(
                                          callList[index].name,
                                          style: new TextStyle(
                                              fontSize: 15,
                                              color: appColorBlack,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    subtitle: new Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Row(
                                        children: <Widget>[
                                          callList[index].callType == "voice"
                                              ? Image.asset(
                                                  "assets/images/call_blue.png",
                                                  color: Colors.red,
                                                  height: 17,
                                                )
                                              : Image.asset(
                                                  "assets/images/Video_Call.png",
                                                  color: Colors.red,
                                                  height: 12,
                                                ),
                                          SizedBox(
                                            width:
                                                SizeConfig.blockSizeHorizontal *
                                                    1,
                                          ),
                                          new Text(
                                            callList[index].callStatus,
                                            style: new TextStyle(
                                                color: Colors.red,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    3.2,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  readTimestamp(
                                      int.parse(callList[index].time)),
                                  style: new TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Icons.info_outline,
                                      color: appColorBlue,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ContactInfo(
                                                id: callList[index].recId !=
                                                        userID
                                                    ? callList[index].recId
                                                    : callList[index].callerId,
                                                imageMedia: [],
                                                videoMedia: [],
                                                docsMedia: [],
                                                imageMediaTime: [],
                                                blocksId: [])),
                                      );
                                    }),
                              ],
                            ),
                            Divider(
                              thickness: 1,
                            ),
                          ],
                        );
            },
          )
        : Container();
  }

  Future<http.Response> sendCallNotification(
      String peerToken, String content) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            "key=AAAA-4XGo4Y:APA91bHGPYL1PJp024uUhnsd4oS9KEJYNk3LArCpz4LxL5uJRUyN55x9wYNCgKtLcMAsI-EIRf2iUPCLqn6pLav1VHUWM6x9NTF1aNitY6Vb12S0TgHSdhfaGeBMD0i0htnLrRNZo68w"
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

  clearAllMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Clear All",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat'),
            ),
            onPressed: () {
              clearAllFunction();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat'),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  clearAllFunction() {
    for (var i = 0; i < callList.length; i++) {
      database
          .reference()
          .child("call_history")
          .child(callList[i].key)
          .remove();
    }
    setState(() {
      callList = [];
    });
  }

  deleteOrder(String orderId, int index) {
    database
        .reference()
        .child("call_history")
        .child(orderId)
        .remove()
        .then((_) {
      setState(() {
        callList.removeAt(index);
      });
    });
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    callList.forEach((userDetail) {
      if (userDetail.name.toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

List _searchResult = [];
