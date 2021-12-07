import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/fullScreenVideo.dart';
import 'package:flutterwhatsappclone/Screens/videoView.dart';
import 'package:flutterwhatsappclone/Screens/viewImages.dart';
import 'package:flutterwhatsappclone/Screens/widgets/player_widget.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/models/starModel.dart';
import 'package:url_launcher/url_launcher.dart';

class StarMsg extends StatefulWidget {
  @override
  _SavedPostState createState() => _SavedPostState();
}

class _SavedPostState extends State<StarMsg>
    with SingleTickerProviderStateMixin {
  List<StarModel> _orderList;
  StreamSubscription<Event> _onOrderAddedSubscription;
  Query _orderQuery;
  String userId;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<Event> _onOrderChangedSubscription;
  TabController tabController;

  @override
  void initState() {
    tabController = new TabController(length: 4, vsync: this);
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      userId = user.uid;
      // ignore: deprecated_member_use
      _orderList = new List();
      _orderQuery = _database
          .reference()
          .child("star")
          .orderByChild("currentUserId")
          .equalTo(user.uid);
      _onOrderAddedSubscription = _orderQuery.onChildAdded.listen(onEntryAdded);
      _onOrderChangedSubscription =
          _orderQuery.onChildChanged.listen(onEntryChanged);
    });
    super.initState();
  }

  onEntryAdded(Event event) {
    setState(() {
      _orderList.add(StarModel.fromSnapshot(event.snapshot));
    });
  }

  onEntryChanged(Event event) {
    var oldEntry1 = _orderList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _orderList[_orderList.indexOf(oldEntry1)] =
          StarModel.fromSnapshot(event.snapshot);
    });
  }

  deleteOrder(String orderId, int index) {
    _database.reference().child("star").child(orderId).remove().then((_) {
      print("Delete $orderId successful");
      setState(() {
        _orderList.removeAt(index);
      });
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _onOrderAddedSubscription.cancel();
    _onOrderChangedSubscription.cancel();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "Starred Messages",
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
      body: NestedScrollView(
        headerSliverBuilder: (context, value) {
          return [
            // SliverToBoxAdapter(child: Header()),
            SliverToBoxAdapter(
              child: TabBar(
                controller: tabController,
                labelColor: appColorBlack,
                unselectedLabelColor: Colors.grey,
                indicatorColor: appColorBlue,
                tabs: [
                  Tab(icon: Text("All")),
                  Tab(icon: Text("Image")),
                  Tab(icon: Text("Video")),
                  Tab(icon: Text("Docs")),
                ],
              ),
            ),
          ];
        },
        body: Container(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            children: <Widget>[
              starList('11'),
              starList('1'),
              starList('4'),
              starList('5'),
            ],
          ),
        ),
      ),
    );
  }

  Widget starList(String msgType) {
    if (_orderList != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
                reverse: true,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _orderList.length,
                itemBuilder: (BuildContext context, int index) {
                  String orderId = _orderList[index].key;
                  String cid = _orderList[index].userId;
                  String pid = _orderList[index].peerId;

                  return _orderList[index].type == msgType || msgType == '11'
                      ? Dismissible(
                          key: Key(orderId),
                          background: Container(color: Colors.white),
                          onDismissed: (direction) async {
                            var groupChatId;

                            if (cid.hashCode <= pid.hashCode) {
                              groupChatId = '$cid-$pid';
                            } else {
                              groupChatId = '$pid-$cid';
                            }
                            print(groupChatId);
                            print(_orderList[index].time);

                            fire.Firestore.instance
                                .collection('messages')
                                .document(groupChatId)
                                .collection(groupChatId)
                                .where("timestamp",
                                    isEqualTo: _orderList[index].time)
                                .getDocuments()
                                .then((querySnapshot) {
                              querySnapshot.documents
                                  .forEach((documentSnapshot) {
                                var star = querySnapshot.documents[0]["star"];
                                var data = [];
                                data.addAll(star);
                                print(">>>>>>>>>>>>>>>>>>>>>>>>>");
                                print(data);
                                data.remove(userId);

                                documentSnapshot.reference
                                    .updateData({"star": data}).then((value) {
                                  deleteOrder(orderId, index);
                                });
                              });
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 5, bottom: 5),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.3,
                                        ),
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            child: CupertinoActivityIndicator(),
                                            width: 15.0,
                                            height: 15.0,
                                            padding: EdgeInsets.all(10.0),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Material(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Icon(
                                                Icons.person,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          imageUrl: _orderList[index]
                                                      .img
                                                      .length >
                                                  0
                                              ? _orderList[index].img
                                              : "https://www.xovi.com/wp-content/plugins/all-in-one-seo-pack/images/default-user-image.png",
                                          width: 35.0,
                                          height: 35.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                    ),
                                    Container(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          _orderList[index].userId != userID
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 4),
                                                  child: Icon(
                                                    Icons.check_circle,
                                                    color: Colors.blue,
                                                  ),
                                                )
                                              : Container(),
                                          Text(
                                            _orderList[index].name,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Text(
                                    //   converTime(fire.Timestamp.fromDate(DateTime.parse(_orderList[index].time))),
                                    //   style: TextStyle(
                                    //       color: Colors.black,
                                    //       fontSize: 14.0,
                                    //       fontStyle: FontStyle.normal),
                                    // ),
                                  ],
                                ),
                                _orderList[index].userId == userId
                                    ? _orderList[index].type == "1" ||
                                            _orderList[index].type == "9"
                                        ? myImageWidget(_orderList[index].msg,
                                            _orderList[index].time)
                                        : _orderList[index].type == "4"
                                            ? myVideoWidget(
                                                _orderList[index].msg,
                                                _orderList[index].time)
                                            : _orderList[index].type == "5"
                                                ? myDocWidget(
                                                    _orderList[index].msg,
                                                    _orderList[index].time)
                                                : _orderList[index].type == "6"
                                                    ? myAudioWidget(
                                                        _orderList[index].msg,
                                                        _orderList[index].time)
                                                    : myTextWidget(
                                                        _orderList[index].msg,
                                                        _orderList[index].time)
                                    //PEER>>>>>>>>>PEER>>>>>>>>>PEER>>>>>>>>>>>PEER
                                    : _orderList[index].type == "1" ||
                                            _orderList[index].type == "9"
                                        ? peerImageWidget(_orderList[index].msg,
                                            _orderList[index].time)
                                        : _orderList[index].type == "4"
                                            ? peerVideoWidget(
                                                _orderList[index].msg,
                                                _orderList[index].time)
                                            : _orderList[index].type == "5"
                                                ? peerDocWidget(
                                                    _orderList[index].msg,
                                                    _orderList[index].time)
                                                : _orderList[index].type == "6"
                                                    ? peerAudioWidget(
                                                        _orderList[index].msg,
                                                        _orderList[index].time)
                                                    : peerTextWidget(
                                                        _orderList[index].msg,
                                                        _orderList[index].time)
                              ],
                            ),
                          ))
                      : Container();
                }),
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          "",
          style: TextStyle(color: Colors.black),
        ),
      );
    }
  }

  myTextWidget(content, timeStamp) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                  color: chatRightTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 17,
              ),
              // Text(
              //   format(
              //       DateTime.fromMillisecondsSinceEpoch(int.parse(
              //         timeStamp,
              //       )),
              //       locale: 'en_short'),
              //   style: TextStyle(
              //       color: Colors.grey,
              //       fontSize: 12.0,
              //       fontStyle: FontStyle.normal),
              // ),
            ],
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 10.0),
      width: 230.0,
      decoration: BoxDecoration(
          color: chatRightColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20))),
    );
  }

  myImageWidget(content, timeStamp) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: chatRightColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ViewImages(images: [content], number: 0)),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        width: 30.0,
                        height: 30.0,
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(appColorBlue),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Material(
                        child: Center(child: Text("Not Avilable")),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                      imageUrl: content,
                      width: 270.0,
                      height: 250.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 8.0,
                  bottom: 4.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.star,
                        size: 17,
                      ),
                      // Text(
                      //   DateFormat('hh:mm a').format(
                      //     DateTime.fromMillisecondsSinceEpoch(int.parse(
                      //       timeStamp,
                      //     )),
                      //   ),
                      //   style: TextStyle(
                      //       color: appColorWhite,
                      //       fontSize: 12.0,
                      //       fontStyle: FontStyle.normal),
                      // ),
                      Container(width: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
        ),
      ],
    );
  }

  myVideoWidget(content, timeStamp) {
    return Container(
      width: 230.0,
      decoration: BoxDecoration(
          color: chatRightColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
        // ignore: deprecated_member_use
        child: FlatButton(
          child: Material(
            color: chatRightColor,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 70,
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FittedBox(
                          fit: BoxFit.cover,
                          child: VideoView(
                            url: content,
                            play: false,
                            // id: _orderList[index].key
                          )),
                    ),
                  ),
                ),
                Container(
                  width: 5,
                ),
                Container(
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(height: 10),
                      Expanded(
                        child: Container(
                          width: 120,
                          child: Center(
                            child: Text(
                              "VIDEO_",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: TextStyle(
                                  color: chatRightTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.star,
                            size: 17,
                          ),
                          // Text(
                          //   DateFormat('hh:mm a').format(
                          //     DateTime.fromMillisecondsSinceEpoch(int.parse(
                          //       timeStamp,
                          //     )),
                          //   ),
                          //   style: TextStyle(
                          //       color: Colors.grey,
                          //       fontSize: 12.0,
                          //       fontStyle: FontStyle.normal),
                          // ),
                          Container(width: 5),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            clipBehavior: Clip.hardEdge,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullScreenVideo(video: content)),
            );
          },
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  myDocWidget(content, timeStamp) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
          color: chatRightColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
        // ignore: deprecated_member_use
        child: FlatButton(
          child: Material(
            color: chatRightColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Icon(
                            Icons.note,
                            color: chatRightTextColor,
                          )),
                      Container(
                        width: 5,
                      ),
                      Container(
                        width: 120,
                        child: Text(
                          "FILE_",
                          maxLines: 1,
                          style: TextStyle(
                              color: chatRightTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.star,
                        size: 17,
                      ),
                      // Text(
                      //   DateFormat('hh:mm a').format(
                      //     DateTime.fromMillisecondsSinceEpoch(int.parse(
                      //       timeStamp,
                      //     )),
                      //   ),
                      //   style: TextStyle(
                      //       color: Colors.grey,
                      //       fontSize: 12.0,
                      //       fontStyle: FontStyle.normal),
                      // ),
                      Container(width: 3),
                    ],
                  ),
                ),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            clipBehavior: Clip.hardEdge,
          ),
          onPressed: () {
            _launchURL(
              content,
            );
          },
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  myAudioWidget(content, timeStamp) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
            width: 250,
            decoration: BoxDecoration(
                color: chatRightColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: PlayerWidget(url: content),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.star,
                        size: 17,
                      ),
                      // Text(
                      //   DateFormat('hh:mm a').format(
                      //     DateTime.fromMillisecondsSinceEpoch(int.parse(
                      //       timeStamp,
                      //     )),
                      //   ),
                      //   style: TextStyle(
                      //       color: Colors.grey,
                      //       fontSize: 12.0,
                      //       fontStyle: FontStyle.normal),
                      // ),
                      Container(width: 3),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  peerTextWidget(content, timeStamp) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 17,
              ),
              Text(
                "",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.normal),
              ),
            ],
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 10.0),
      width: 230.0,
      decoration: BoxDecoration(
          color: chatLeftColor2,
          //Color(0XFFc4d1ec),
          // border: Border.all(color: Color(0xffE8E8E8)),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20))),
    );
  }

  peerImageWidget(content, timeStamp) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: chatLeftColor2,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ViewImages(images: [content], number: 1)),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        width: 30.0,
                        height: 30.0,
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Color(0xffE8E8E8),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(appColorBlue),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Material(
                        child: Text("Not Avilable"),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                      imageUrl: content,
                      width: 270.0,
                      height: 250.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  right: 8.0,
                  bottom: 4.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.star,
                            size: 17,
                          ),
                          // Text(
                          //   DateFormat('hh:mm a').format(
                          //     DateTime.fromMillisecondsSinceEpoch(int.parse(
                          //       timeStamp,
                          //     )),
                          //   ),
                          //   style: TextStyle(
                          //       color: appColorWhite,
                          //       fontSize: 12.0,
                          //       fontStyle: FontStyle.normal),
                          // ),
                          Container(width: 3),
                          Container(width: 5),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
        ),
      ],
    );
  }

  peerVideoWidget(content, timeStamp) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
          color: chatLeftColor2,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
        // ignore: deprecated_member_use
        child: FlatButton(
          child: Material(
            color: chatLeftColor2,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 70,
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FittedBox(
                          fit: BoxFit.cover,
                          child: VideoView(
                            url: content,
                            play: false,
                            // id: _orderList[index].key
                          )),
                    ),
                  ),
                ),
                Container(
                  width: 5,
                ),
                Container(
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(height: 10),
                      Expanded(
                        child: Container(
                          width: 120,
                          child: Center(
                            child: Text(
                              "VIDEO_",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: TextStyle(
                                  color: chatLeftTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.star,
                            size: 17,
                          ),
                          // Text(
                          //   DateFormat('hh:mm a').format(
                          //     DateTime.fromMillisecondsSinceEpoch(int.parse(
                          //       timeStamp,
                          //     )),
                          //   ),
                          //   style: TextStyle(
                          //       color: Colors.grey,
                          //       fontSize: 12.0,
                          //       fontStyle: FontStyle.normal),
                          // ),
                          // Container(width: 3),
                          Container(width: 5),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            clipBehavior: Clip.hardEdge,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullScreenVideo(video: content)),
            );
          },
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  peerDocWidget(content, timeStamp) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
          color: chatLeftColor2,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
        // ignore: deprecated_member_use
        child: FlatButton(
          child: Material(
            color: chatLeftColor2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Icon(Icons.note)),
                      Container(
                        width: 5,
                      ),
                      Container(
                        width: 120,
                        child: Text(
                          "FILE_",
                          maxLines: 1,
                          style: TextStyle(
                              color: chatLeftTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.star,
                        size: 17,
                      ),
                      // Text(
                      //   DateFormat('hh:mm a').format(
                      //     DateTime.fromMillisecondsSinceEpoch(int.parse(
                      //       timeStamp,
                      //     )),
                      //   ),
                      //   style: TextStyle(
                      //       color: Colors.grey,
                      //       fontSize: 12.0,
                      //       fontStyle: FontStyle.normal),
                      // ),
                      Container(width: 3),
                    ],
                  ),
                ),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            clipBehavior: Clip.hardEdge,
          ),
          onPressed: () {
            _launchURL(
              content,
            );
          },
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  peerAudioWidget(content, timeStamp) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 5),
      child: Container(
          width: 250,
          decoration: BoxDecoration(
              color: chatLeftColor2,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: PlayerWidget(url: content),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.star,
                      size: 17,
                    ),
                    // Text(
                    //   DateFormat('hh:mm a').format(
                    //     DateTime.fromMillisecondsSinceEpoch(int.parse(
                    //       timeStamp,
                    //     )),
                    //   ),
                    //   style: TextStyle(
                    //       color: Colors.grey,
                    //       fontSize: 12.0,
                    //       fontStyle: FontStyle.normal),
                    // ),
                    Container(width: 3),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
