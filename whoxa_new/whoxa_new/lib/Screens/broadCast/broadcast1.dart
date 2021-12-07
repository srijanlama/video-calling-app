import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterwhatsappclone/Screens/broadCast/broadCastChat.dart';
import 'package:flutterwhatsappclone/Screens/broadCast/broadcast2.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/broadcastModal.dart';

class EBroadcast extends StatefulWidget {
  @override
  _EBroadcastState createState() => _EBroadcastState();
}

class _EBroadcastState extends State<EBroadcast> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<BroadCastModel> _orderList;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StreamSubscription<Event> _onOrderAddedSubscription;
  StreamSubscription<Event> _onOrderChangedSubscription;
  Query _orderQuery;
  bool _showLoader = true;
  FirebaseDatabase database = new FirebaseDatabase();
  String userId;
  String number = '';
  String currentUserName;
  String currentUserImage;
  String currentUserToken;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      userId = user.uid;
      getUserData();
 // ignore: deprecated_member_use
      _orderList = new List();
      _orderQuery = _database
          .reference()
          .child("broadcast")
          .orderByChild("createrId")
          .equalTo(user.uid);
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

    setState(() {
      _orderList[_orderList.indexOf(oldEntry)] =
          BroadCastModel.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _orderList.add(BroadCastModel.fromSnapshot(event.snapshot));
    });
  }

  deleteOrder(String orderId, int index) {
    _database.reference().child("broadcast").child(orderId).remove().then((_) {
      setState(() {
        _orderList.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: appColorWhite,
              title: Text(
                "Broadcast Lists",
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
            body: LayoutBuilder(builder: (context, constraint) {
              return Column(
                children: <Widget>[
                  _showLoader == true ? loader() : _designPage(context),
                  Divider(
                    thickness: 1,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectBroadcast(number: number)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 15),
                      child: Container(
                          alignment: Alignment.bottomCenter,
                          width: double.infinity,
                          child: Text("New List",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                                  fontWeight: FontWeight.bold,
                                  color: appColorBlue))),
                    ),
                  ),
                ],
              );
            })),
      ),
    );
  }

  Widget _designPage(context) {
    if (_orderList != null && _orderList.length > 0) {
      return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: _orderList.length,
            itemBuilder: (BuildContext context, int index) {
              String orderId = _orderList[index].key;
              String title = _orderList[index].castName;

              var name = _orderList[index].name;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BroadCastChat(
                            peerID: _orderList[index].userId,
                            peerUrl: _orderList[index].img,
                            peerName: _orderList[index].name,
                            peerToken: _orderList[index].token,
                            currentusername: currentUserName,
                            currentuserimage: currentUserImage,
                            currentuser: userId,
                            castId: _orderList[index].key,
                            castTitle: title)),
                  );
                },
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: Column(
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      //  width: 150,
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Container(height: 3),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        name.join(','),
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.info_outline,
                                color: appColorBlue,
                                size: 25,
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(height: 5),
                      Divider(
                        height: 10.0,
                      ),
                      Container(height: 5),
                    ],
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        deleteOrder(orderId, index);
                      },
                    ),
                  ],
                ),
              );
            }),
      );
    } else {
      return Expanded(
          child: Container(
        alignment: Alignment.center,
        height: SizeConfig.screenHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You should use broadcast list to message \nmultiple people at once',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Only contact with $number in their \naddress book will receive your broadcast\nmessage ',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ));
    }
  }

  getUserData() async {
    final FirebaseDatabase database = new FirebaseDatabase();

    database.reference().child('user').child(userId).once().then((peerData) {
      setState(() {
        number = peerData.value['mobile'];
        currentUserName = peerData.value['name'];
        currentUserImage = peerData.value['img'];
        currentUserToken = peerData.value['token'];
      });
    });
  }
}
