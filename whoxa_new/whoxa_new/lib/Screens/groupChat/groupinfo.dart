import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/contactinfo.dart';
import 'package:flutterwhatsappclone/Screens/groupChat/editGroup.dart';
import 'package:flutterwhatsappclone/Screens/mediaScreen.dart';
import 'package:flutterwhatsappclone/Screens/staredMsg.dart';
import 'package:flutterwhatsappclone/Screens/viewImages.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/groupModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;

// ignore: must_be_immutable
class GroupInfo extends StatefulWidget {
  String groupName;
  String groupKey;
  var ids;
  var imageMedia;
  var videoMedia;
  var docsMedia;

  GroupInfo(
      {this.groupName,
      this.groupKey,
      this.ids,
      this.imageMedia,
      this.videoMedia,
      this.docsMedia});
  @override
  GroupInfoState createState() {
    return new GroupInfoState();
  }
}

class GroupInfoState extends State<GroupInfo> {
  List<GroupModel> _orderList;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StreamSubscription<Event> _onOrderAddedSubscription;
  StreamSubscription<Event> _onOrderChangedSubscription;
  Query _orderQuery;
  bool _showLoader = true;
  FirebaseDatabase database = new FirebaseDatabase();
  String userId;
  String groupName = '';
  String groupImage = '';
  String groupDescription = '';

  var newPersonId = [];

  var inviteId = [];
  var inviteName = [];
  var inviteImage = [];

  @override
  void initState() {
    getContactsFromGloble().then((value) {
      callFunction();
    });

    super.initState();
  }

  callFunction() {
    print(widget.groupKey);
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      userId = user.uid;

      _orderList = [];
      _orderQuery = _database.reference().child("group");

      _onOrderAddedSubscription = _orderQuery.onChildAdded.listen(onEntryAdded);
      _onOrderChangedSubscription =
          _orderQuery.onChildChanged.listen(onEntryChanged);
      _showLoader = false;
    });
  }

  @override
  void dispose() {
    _onOrderAddedSubscription.cancel();
    _onOrderChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _orderList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    _orderList[_orderList.indexOf(oldEntry)] =
        GroupModel.fromSnapshot(event.snapshot);
  }

  onEntryAdded(Event event) {
    setState(() {
      _orderList.add(GroupModel.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appColorWhite,
          title: Text(
            "Group Info",
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
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: CustomText(
                  text: "Edit",
                  alignment: Alignment.centerLeft,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appColorBlue,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditGroup(
                            groupName: groupName,
                            groupImage: groupImage,
                            groupDescription: groupDescription,
                            groupIds: widget.ids,
                            groupKey: widget.groupKey)),
                  );
                },
              ),
            ),
          ],
        ),
        body: _body());
  }

  Widget _body() {
    return _showLoader == true
        ? Center(child: loader())
        : ListView.builder(
            itemCount: _orderList.length,
            itemBuilder: (BuildContext context, int index) {
              if (_orderList[index].key == widget.groupKey) {
                groupName = _orderList[index].castName;
                groupImage = _orderList[index].castImage;
                groupDescription = _orderList[index].castDesc;
                return Column(
                  children: [
                    groupImage.length > 0
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewImages(
                                        images: [groupImage], number: 0)),
                              );
                            },
                            child: Image.network(
                              groupImage,
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
                            Container(
                              height: SizeConfig.blockSizeVertical * 8,
                              child: Center(
                                child: ListTile(
                                  title: new Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Text(
                                              _orderList[index].castName,
                                              style: new TextStyle(
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal *
                                                      4,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "MontserratBold",
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.asset(
                                                          "assets/images/chat.png",
                                                          color: appColorBlue,
                                                        ),
                                                      )),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ),
                                            // ClipOval(
                                            //   child: Material(
                                            //     color: Colors
                                            //         .grey[100], // button color
                                            //     child: InkWell(
                                            //       child: SizedBox(
                                            //           width: 40,
                                            //           height: 40,
                                            //           child: Padding(
                                            //             padding:
                                            //                 const EdgeInsets
                                            //                     .all(8.0),
                                            //             child: Image.asset(
                                            //               "assets/images/video_fill.png",
                                            //               color: appColorBlue,
                                            //             ),
                                            //           )),
                                            //       onTap: () {},
                                            //     ),
                                            //   ),
                                            // ),
                                            // ClipOval(
                                            //   child: Material(
                                            //     color: Colors
                                            //         .grey[100], // button color
                                            //     child: InkWell(
                                            //       child: SizedBox(
                                            //           width: 40,
                                            //           height: 40,
                                            //           child: Padding(
                                            //             padding:
                                            //                 const EdgeInsets
                                            //                     .all(10),
                                            //             child: Image.asset(
                                            //               "assets/images/grey_call.png",
                                            //               color: appColorBlue,
                                            //             ),
                                            //           )),
                                            //       onTap: () {},
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(height: 0.5, color: Colors.grey),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditGroup(
                                          groupName: groupName,
                                          groupImage: groupImage,
                                          groupDescription: groupDescription,
                                          groupIds: widget.ids,
                                          groupKey: widget.groupKey)),
                                );
                              },
                              child: Container(
                                // height: SizeConfig.blockSizeVertical * 6,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Center(
                                    child: ListTile(
                                      title: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: new Text(
                                              _orderList[index].castDesc != ""
                                                  ? _orderList[index].castDesc
                                                  : "Add group description",
                                              style: new TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Container(width: 10),
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
                            ),
                            Container(height: 0.5, color: Colors.grey),
                            Container(
                              height: 50,
                              color: Colors.grey[100],
                            ),
                            Container(height: 0.5, color: Colors.grey),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MediaScreen(
                                          imageMedia: widget.imageMedia,
                                          videoMedia: widget.videoMedia,
                                          docsMedia: widget.docsMedia)),
                                );
                              },
                              child: Container(
                                height: SizeConfig.blockSizeVertical * 6,
                                child: Center(
                                  child: ListTile(
                                    title: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: new Text(
                                            'Media, Links and Doc ',
                                            style: new TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    3.7,
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
                                  MaterialPageRoute(
                                      builder: (context) => StarMsg()),
                                );
                              },
                              child: Container(
                                height: SizeConfig.blockSizeVertical * 6,
                                child: Center(
                                  child: ListTile(
                                    title: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: new Text(
                                            'Starred Messages',
                                            style: new TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    3.7,
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
                            //   onTap: () {
                            //     invite(
                            //         _orderList[index].userId,
                            //         _orderList[index].castName,
                            //         _orderList[index].castImage,
                            //         _orderList[index].key);
                            //   },
                            //   child: Container(
                            //     height: SizeConfig.blockSizeVertical * 6,
                            //     child: Center(
                            //       child: ListTile(
                            //         title: new Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           children: <Widget>[
                            //             Expanded(
                            //               child: new Text(
                            //                 'Invite to Group via Link',
                            //                 style: new TextStyle(
                            //                     fontSize: SizeConfig
                            //                             .blockSizeHorizontal *
                            //                         3.7,
                            //                     fontWeight: FontWeight.bold,
                            //                     color: Colors.blue),
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
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                    width: SizeConfig.screenWidth,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, top: 20, bottom: 10),
                                      child: Text(_orderList[index]
                                              .userId
                                              .length
                                              .toString() +
                                          ' participants'),
                                    )),
                              ],
                            ),
                            Container(height: 0.5, color: Colors.grey),

                            _orderList[index].createrId.contains(userId)
                                ? ListTile(
                                    onTap: () {
                                      newPersonId = [];
                                      addParticipants(
                                          _orderList[index].userId,
                                          _orderList[index].castName,
                                          _orderList[index].castImage);
                                    },
                                    leading: new Stack(
                                      children: <Widget>[
                                        InkWell(
                                          child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.add,
                                                  color: appColorBlue,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                    title: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Text(
                                          "Add Participants",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: appColorBlue,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            Container(height: 0.5, color: Colors.grey),

                            Container(
                              child: ListView.builder(
                                padding: EdgeInsets.only(top: 0),
                                itemCount: _orderList[index].userId.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index2) {
                                  return groupWidget(
                                      _orderList[index].userId, index, index2);
                                },
                              ),
                            ),
                            Container(height: 30),
                            // Container(height: 0.5, color: Colors.grey),
                            // Container(
                            //   color: Colors.white,
                            //   height: SizeConfig.blockSizeVertical * 6,
                            // ),
                            // Container(height: 0.5, color: Colors.grey),
                            // Container(
                            //   height: SizeConfig.blockSizeVertical * 6,
                            //   child: Center(
                            //     child: ListTile(
                            //       title: new Row(
                            //         children: <Widget>[
                            //           Expanded(
                            //             child: new Text(
                            //               'Exit Group',
                            //               style: new TextStyle(
                            //                   fontSize: SizeConfig
                            //                           .blockSizeHorizontal *
                            //                       3.5,
                            //                   fontWeight: FontWeight.bold,
                            //                   color: Colors.red),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // Container(height: 0.5, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            });
  }

  Widget groupWidget(var ids, int index1, int index2) {
    return Column(
      children: [
        StreamBuilder(
          stream: FirebaseDatabase.instance
              .reference()
              .child('user')
              .child(ids[index2])
              .onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListTile(
                onTap: () {
                  if (ids[index2] != userId &&
                      _orderList[index1].createrId.contains(userId)) {
                    _settingModalBottomSheet(context,
                        _orderList[index1].createrId, ids[index2], ids);
                  } else {
                    if (ids[index2] != userId) {
                      _settingModalBottomSheet2(context, ids[index2]);
                    }
                  }
                },
                leading: new Stack(
                  children: <Widget>[
                    InkWell(
                      onLongPress: () {},
                      child: snapshot.data.snapshot.value["img"] != ""
                          ? Container(
                              height: 40,
                              width: 40,
                              child: CircleAvatar(
                                //radius: 60,
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Colors.grey,
                                backgroundImage: new NetworkImage(
                                    snapshot.data.snapshot.value["img"]),
                              ),
                            )
                          : Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.person),
                              )),
                    ),
                  ],
                ),
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(
                      snapshot.data.snapshot.value["name"],
                      style: new TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _orderList[index1]
                            .createrId
                            .contains(snapshot.data.snapshot.value["userId"])
                        ? Text(
                            "admin",
                            style: TextStyle(fontSize: 13),
                          )
                        : Container()
                  ],
                ),
                trailing: Wrap(
                  spacing: 10,
                  children: <Widget>[
                    snapshot.data.snapshot.value["status"] == "Online"
                        ? Icon(Icons.circle, color: Colors.green, size: 15)
                        : Icon(Icons.circle, size: 15)
                  ],
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
        Container(
          height: 0.3,
          color: Colors.grey,
        )
      ],
    );
  }

  void _settingModalBottomSheet(context, adminIds, peerId, allIds) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Center(
                    child: new ListTile(
                        title: Center(child: new Text('View Profile')),
                        onTap: () {
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
                                    chat: true)),
                          );
                          // Navigator.push(
                          //     context,
                          //     CupertinoPageRoute(
                          //         builder: (context) => Chat(
                          //             peerID: peerId,
                          //             archive: false,
                          //             mute: false,
                          //             chatListTime: '')));
                        })),
                adminIds.contains(peerId)
                    ? ListTile(
                        title: Center(child: new Text('Dismiss As Admin')),
                        onTap: () {
                          var newAdminsIds = [];
                          newAdminsIds.addAll(adminIds);
                          newAdminsIds.remove(peerId);
                          DatabaseReference _userRef = database
                              .reference()
                              .child('group')
                              .child(widget.groupKey);
                          _userRef.update({
                            "createrId": newAdminsIds,
                          }).then((_) {
                            setState(() {
                              Navigator.pop(context);
                            });
                          });
                        },
                      )
                    : ListTile(
                        title: Center(child: new Text('Make Group Admin')),
                        onTap: () {
                          var newAdminsIds = [];
                          newAdminsIds.addAll(adminIds);
                          newAdminsIds.add(peerId);

                          DatabaseReference _userRef = database
                              .reference()
                              .child('group')
                              .child(widget.groupKey);
                          _userRef.update({
                            "createrId": newAdminsIds,
                          }).then((_) {
                            setState(() {
                              Navigator.pop(context);
                            });
                          });
                        },
                      ),
                ListTile(
                  title: Center(
                      child: new Text(
                    'Remove from group',
                    style: TextStyle(color: Colors.red),
                  )),
                  onTap: () {
                    Navigator.pop(context);
                    var newAdminsIds = [];
                    newAdminsIds.addAll(allIds);
                    newAdminsIds.remove(peerId);

                    DatabaseReference _userRef = database
                        .reference()
                        .child('group')
                        .child(widget.groupKey);
                    _userRef.update({
                      "userId": newAdminsIds,
                    }).then((_) {
                      cloud.Firestore.instance
                          .collection("chatList")
                          .document(peerId)
                          .collection(peerId)
                          .document(widget.groupKey)
                          .delete()
                          .then((value) {
                        setState(() {
                          _body();
                        });
                      });
                    });
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

  void _settingModalBottomSheet2(context, peerId) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Center(
                    child: new ListTile(
                        title: Center(child: new Text('View Profile')),
                        onTap: () {
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
                                    chat: true)),
                          );
                          // Navigator.push(
                          //     context,
                          //     CupertinoPageRoute(
                          //         builder: (context) => Chat(
                          //             peerID: peerId,
                          //             archive: false,
                          //             mute: false,
                          //             chatListTime: '')));
                        })),
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

  addParticipants(allUsersId, groupName, groupImage) {
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
                                      style: TextStyle(color: appColorBlue),
                                    )),
                                Text(
                                  "Add Participants",
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
                                          for (var i = 0;
                                              i < newPersonId.length;
                                              i++) {
                                            cloud.Firestore.instance
                                                .collection("chatList")
                                                .document(newPersonId[i])
                                                .collection(newPersonId[i])
                                                .document(widget.groupKey)
                                                .setData({
                                              'id': widget.groupKey,
                                              'name': groupName,
                                              'timestamp': DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString(),
                                              'content': "you added in a group",
                                              'badge': '1',
                                              'profileImage': groupImage,
                                              'type': 0,
                                              'archive': false,
                                              'mute': false,
                                              'chatType': "group"
                                            }).then((onValue) async {
                                              newPersonId.addAll(allUsersId);

                                              DatabaseReference _userRef =
                                                  database
                                                      .reference()
                                                      .child('group')
                                                      .child(widget.groupKey);
                                              _userRef.update({
                                                "userId": newPersonId
                                                    .toSet()
                                                    .toList(),
                                              }).then((_) {
                                                setState(() {
                                                  _showLoader = true;
                                                  callFunction();
                                                  _body();
                                                  Navigator.pop(context);
                                                });
                                              });
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Text(
                                            "Add",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              color: appColorBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Text(
                                          "Add",
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
                        Container(
                          height: 500,
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return allUsersId
                                            .contains(lists[index]["userId"])
                                        ? Container()
                                        : mobileContacts.contains(
                                                    lists[index]["mobile"]) &&
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
                                                              (lists[index]["img"] !=
                                                                          null &&
                                                                      lists[index]["img"]
                                                                              .length >
                                                                          0)
                                                                  ? CircleAvatar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .grey,
                                                                      backgroundImage:
                                                                          new NetworkImage(lists[index]
                                                                              [
                                                                              "img"]),
                                                                    )
                                                                  : CircleAvatar(
                                                                      backgroundColor:
                                                                          Colors.grey[
                                                                              300],
                                                                      child:
                                                                          Text(
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
                                                                lists[index][
                                                                        "name"] ??
                                                                    "",
                                                                style: new TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          subtitle:
                                                              new Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5.0),
                                                            child: new Row(
                                                              children: [
                                                                Text(lists[
                                                                        index]
                                                                    ["mobile"])
                                                                // ItemsTile(c.phones),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  newPersonId.contains(
                                                          lists[index]
                                                              ["userId"])
                                                      ? InkWell(
                                                          onTap: () {},
                                                          child: IconButton(
                                                            onPressed: () {
                                                              setState1(() {
                                                                newPersonId.remove(
                                                                    lists[index]
                                                                        [
                                                                        "userId"]);
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  appColorBlue,
                                                              size: 28,
                                                            ),
                                                          ))
                                                      : IconButton(
                                                          onPressed: () {
                                                            setState1(() {
                                                              newPersonId.add(
                                                                  lists[index][
                                                                      "userId"]);
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .radio_button_off_outlined,
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
                                  },
                                );
                              }
                              return Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                  ),
                );
              },
            );
          });
        });
  }

  invite(allUsersId, groupName, groupImage, groupId) {
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
                                      style: TextStyle(color: appColorBlue),
                                    )),
                                Text(
                                  "Invite to Group",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.black),
                                ),
                                inviteId.length > 0
                                    ? InkWell(
                                        onTap: () {
                                          createMessage(groupId);
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Text(
                                            "Send",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              color: appColorBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Text(
                                          "Send",
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
                        Container(
                          height: 500,
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return allUsersId
                                            .contains(lists[index]["userId"])
                                        ? Container()
                                        : mobileContacts.contains(
                                                    lists[index]["mobile"]) &&
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
                                                              (lists[index]["img"] !=
                                                                          null &&
                                                                      lists[index]["img"]
                                                                              .length >
                                                                          0)
                                                                  ? CircleAvatar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .grey,
                                                                      backgroundImage:
                                                                          new NetworkImage(lists[index]
                                                                              [
                                                                              "img"]),
                                                                    )
                                                                  : CircleAvatar(
                                                                      backgroundColor:
                                                                          Colors.grey[
                                                                              300],
                                                                      child:
                                                                          Text(
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
                                                                lists[index][
                                                                        "name"] ??
                                                                    "",
                                                                style: new TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          subtitle:
                                                              new Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5.0),
                                                            child: new Row(
                                                              children: [
                                                                Text(lists[
                                                                        index]
                                                                    ["mobile"])
                                                                // ItemsTile(c.phones),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  inviteId.contains(lists[index]
                                                          ["userId"])
                                                      ? InkWell(
                                                          onTap: () {},
                                                          child: IconButton(
                                                            onPressed: () {
                                                              setState1(() {
                                                                inviteId.remove(
                                                                    lists[index]
                                                                        [
                                                                        "userId"]);
                                                                inviteName.remove(
                                                                    lists[index]
                                                                        [
                                                                        "name"]);
                                                                inviteImage.remove(
                                                                    lists[index]
                                                                        [
                                                                        "img"]);
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  appColorBlue,
                                                              size: 28,
                                                            ),
                                                          ))
                                                      : IconButton(
                                                          onPressed: () {
                                                            setState1(() {
                                                              inviteId.add(lists[
                                                                      index]
                                                                  ["userId"]);
                                                              inviteName.add(
                                                                  lists[index]
                                                                      ["name"]);
                                                              inviteImage.add(
                                                                  lists[index]
                                                                      ["img"]);
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .radio_button_off_outlined,
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
                                  },
                                );
                              }
                              return Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                  ),
                );
              },
            );
          });
        });
  }

  createMessage(groupId) {
    var msg = [];
    var type = [];
    var contact = [];

    for (var i = 0; i < inviteId.length; i++) {
      msg.add(groupId);
      type.add(10);
      contact.add("");
    }

    for (var i = 0; i < inviteId.length; i++) {
      onForward(inviteId[i], inviteName[i], inviteImage[i], msg[i], type[i],
          contact[i]);
    }

    Navigator.pop(context);
  }

  Future<void> onForward(
    peerID2,
    peerName2,
    peerUrl2,
    String content,
    int type,
    String contact,
  ) async {
    // 10 = Invite to group
    int badgeCount = 0;

    if (content.trim() != '') {
      var groupChatId;
      if (userID.hashCode <= peerID2.hashCode) {
        groupChatId = userID + "-" + peerID2;
      } else {
        groupChatId = peerID2 + "-" + userID;
      }

      var documentReference = cloud.Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      cloud.Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': userID,
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
        await cloud.Firestore.instance
            .collection("chatList")
            .document(userID)
            .collection(userID)
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
            await cloud.Firestore.instance
                .collection("chatList")
                .document(peerID2)
                .collection(peerID2)
                .document(userID)
                .get()
                .then((doc) async {
              debugPrint(doc.data["badge"]);
              if (doc.data["badge"] != null) {
                badgeCount = int.parse(doc.data["badge"]);
                await cloud.Firestore.instance
                    .collection("chatList")
                    .document(peerID2)
                    .collection(peerID2)
                    .document(userID)
                    .setData({
                  'id': userID,
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
            await cloud.Firestore.instance
                .collection("chatList")
                .document(peerID2)
                .collection(peerID2)
                .document(userID)
                .setData({
              'id': userID,
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
}
