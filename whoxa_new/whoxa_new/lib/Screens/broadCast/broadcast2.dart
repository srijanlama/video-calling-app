import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/models/broadcastModal.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/user.dart';

// ignore: must_be_immutable
class SelectBroadcast extends StatefulWidget {
  String number;
  SelectBroadcast({this.number});
  @override
  SelectBroadcastState createState() {
    return new SelectBroadcastState();
  }
}

class SelectBroadcastState extends State<SelectBroadcast> {
  List<User> userlist;
  Query query;
  TextEditingController controller = new TextEditingController();
  String userId;
  StreamSubscription<Event> _onOrderAddedSubscription;
  StreamSubscription<Event> _onOrderChangedSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  TextEditingController titleController = TextEditingController();

  String currentUserName;
  String currentUserImage;
  String currentUserToken;
  String number = '';

  var userIds = [];
  var userNames = [];
  var userImages = [];
  var userTokens = [];

  @override
  void initState() {
    number = widget.number;
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;
        getUserData();
      });
      // ignore: deprecated_member_use
      userlist = new List();
      query = database.reference().child("user").orderByChild("userId");
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
    var oldEntry = userlist.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      userlist[userlist.indexOf(oldEntry)] = User.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded1(Event event) {
    setState(() {
      userlist.add(User.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Material(
          elevation: 10,
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical * 17,
                  child: Material(
                    color: Colors.grey[100],
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: appColorBlue,
                                  ),
                                ),
                              ),
                              Text(
                                'Recipients',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "MontserratBold",
                                  color: appColorBlack,
                                ),
                              ),
                              userIds.length > 0
                                  ? InkWell(
                                      onTap: () {
                                        createBroadCast();
                                      },
                                      child: Text(
                                        'Create',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: appColorBlue,
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      child: Text(
                                        'Create',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: appColorGrey,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                            padding: const EdgeInsets.only(right: 15, left: 15),
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
                                  onChanged: onSearchTextChanged,
                                  style: TextStyle(color: Colors.grey),
                                  decoration: new InputDecoration(
                                    border: new OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.grey[200]),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.grey[200]),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15.0),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.grey[200]),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15.0),
                                      ),
                                    ),
                                    filled: true,
                                    hintStyle: new TextStyle(
                                        color: Colors.grey[600], fontSize: 14),
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
                        Container(height: 10),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.grey[400],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Only contacts with $number in their address book \nwill receive  your broadcast messages.',
                        style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                mainWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mainWidget() {
    return Expanded(
      flex: 5,
      child: userlist != null && userlist.length > 0
          ? _searchResult.length != 0 ||
                  controller.text.trim().toLowerCase().isNotEmpty
              ? ListView.builder(
                  itemCount: _searchResult.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _searchResult[index].userId == userId
                        ? Container()
                        : mobileContacts
                                    .contains(_searchResult[index].mobile) &&
                                userId != _searchResult[index].userId
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        new Divider(
                                          height: 1,
                                        ),
                                        new ListTile(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //       builder: (context) => Chat(
                                            //             peerID:
                                            //                 userlist[index].userId,
                                            //             peerUrl: userlist[index].img,
                                            //             peerName:
                                            //                 userlist[index].name,
                                            //             peerToken:
                                            //                 userlist[index].token,
                                            //             currentusername:
                                            //                 currentUserName,
                                            //             currentuserimage:
                                            //                 currentUserImage,
                                            //             currentuser: userId,
                                            //           )),
                                            // );
                                          },
                                          leading: new Stack(
                                            children: <Widget>[
                                              (_searchResult[index].img !=
                                                          null &&
                                                      _searchResult[index]
                                                              .img
                                                              .length >
                                                          0)
                                                  ? CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey,
                                                      backgroundImage:
                                                          new NetworkImage(
                                                              _searchResult[
                                                                      index]
                                                                  .img),
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey[300],
                                                      child: Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                            ],
                                          ),
                                          title: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              new Text(
                                                _searchResult[index].name ?? "",
                                                style: new TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),

                                              // new Text(
                                              //   "",
                                              //   style: new TextStyle(
                                              //       color: Colors.grey, fontSize: 14.0),
                                              // ),
                                            ],
                                          ),
                                          subtitle: new Container(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: new Row(
                                              children: [
                                                Text(_searchResult[index]
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
                                  userIds.contains(_searchResult[index].userId)
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  userIds.remove(
                                                      _searchResult[index]
                                                          .userId);
                                                  userNames.remove(
                                                      _searchResult[index]
                                                          .name);
                                                  userImages.remove(
                                                      _searchResult[index].img);
                                                  userTokens.remove(
                                                      _searchResult[index]
                                                          .token);
                                                });
                                              },
                                              child: Icon(
                                                Icons.check_circle,
                                                color: appColorBlue,
                                                size: 27,
                                              )),
                                        )
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  userIds.add(
                                                      _searchResult[index]
                                                          .userId);
                                                  userNames.add(
                                                      _searchResult[index]
                                                          .name);
                                                  userImages.add(
                                                      _searchResult[index].img);
                                                  userTokens.add(
                                                      _searchResult[index]
                                                          .token);
                                                });
                                              },
                                              child: Icon(
                                                Icons.radio_button_unchecked,
                                                size: 27,
                                                color: Colors.grey[400],
                                              )),
                                        )
                                ],
                              )
                            : Container();
                  },
                )
              : ListView.builder(
                  itemCount: userlist.length,
                  itemBuilder: (BuildContext context, int index) {
                    return userlist[index].userId == userId
                        ? Container()
                        : mobileContacts.contains(userlist[index].mobile) &&
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
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //       builder: (context) => Chat(
                                            //             peerID:
                                            //                 userlist[index].userId,
                                            //             peerUrl: userlist[index].img,
                                            //             peerName:
                                            //                 userlist[index].name,
                                            //             peerToken:
                                            //                 userlist[index].token,
                                            //             currentusername:
                                            //                 currentUserName,
                                            //             currentuserimage:
                                            //                 currentUserImage,
                                            //             currentuser: userId,
                                            //           )),
                                            // );
                                          },
                                          leading: new Stack(
                                            children: <Widget>[
                                              (userlist[index].img != null &&
                                                      userlist[index]
                                                              .img
                                                              .length >
                                                          0)
                                                  ? CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey,
                                                      backgroundImage:
                                                          new NetworkImage(
                                                              userlist[index]
                                                                  .img),
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey[300],
                                                      child: Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                            ],
                                          ),
                                          title: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              new Text(
                                                userlist[index].name ?? "",
                                                style: new TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),

                                              // new Text(
                                              //   "",
                                              //   style: new TextStyle(
                                              //       color: Colors.grey, fontSize: 14.0),
                                              // ),
                                            ],
                                          ),
                                          subtitle: new Container(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: new Row(
                                              children: [
                                                Text(userlist[index].mobile ??
                                                    "")
                                                // ItemsTile(c.phones),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  userIds.contains(userlist[index].userId)
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  userIds.remove(
                                                      userlist[index].userId);
                                                  userNames.remove(
                                                      userlist[index].name);
                                                  userImages.remove(
                                                      userlist[index].img);
                                                  userTokens.remove(
                                                      userlist[index].token);
                                                });
                                              },
                                              child: Icon(
                                                Icons.check_circle,
                                                color: appColorBlue,
                                                size: 27,
                                              )),
                                        )
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  userIds.add(
                                                      userlist[index].userId);
                                                  userNames.add(
                                                      userlist[index].name);
                                                  userImages
                                                      .add(userlist[index].img);
                                                  userTokens.add(
                                                      userlist[index].token);
                                                });
                                              },
                                              child: Icon(
                                                Icons.radio_button_unchecked,
                                                size: 27,
                                                color: Colors.grey[400],
                                              )),
                                        )
                                ],
                              )
                            : Container();
                  },
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void createBroadCast() {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState1) {
            return Center(
              child: Container(
                width: 300,
                height: 200,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                        child: Text(
                      'Enter Name of broadcast',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "MontserratBold",
                          fontSize: SizeConfig.blockSizeHorizontal * 4),
                    )),
                    SizedBox(
                      height: 10,
                    ),
                    Material(
                      child: CustomtextField(
                        controller: titleController,
                        maxLines: 1,
                        textInputAction: TextInputAction.next,
                        hintText: 'Enter broadcast name',
                        prefixIcon: Container(
                          margin: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.campaign,
                            color: Colors.black,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 5,
                      width: SizeConfig.screenWidth,
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        color: appColorGreen,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () {
                          if (titleController.text.length > 0) {
                            BroadCastModel model = new BroadCastModel(
                                userNames,
                                userIds,
                                userImages,
                                userTokens,
                                userId,
                                titleController.text);

                            database
                                .reference()
                                .child("broadcast")
                                .push()
                                .set(model.toJson())
                                .then((value) {
                              Navigator.pop(context);
                            });
                          } else {
                            Toast.show("Enter title", context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        },
                        child: Text(
                          "CREATE",
                          style: TextStyle(
                              fontSize: 14.0, fontFamily: "MontserratBold"),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  getUserData() async {
    final FirebaseDatabase database = new FirebaseDatabase();

    database.reference().child('user').child(userId).once().then((peerData) {
      setState(() {
        currentUserName = peerData.value['name'];
        currentUserImage = peerData.value['img'];
        currentUserToken = peerData.value['token'];
      });
    });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    userlist.forEach((userDetail) {
      if (userDetail.name != null)
      // for (int i = 0; i < chatList.length; i++) {
      if (userDetail.name.toLowerCase().contains(text.toLowerCase())
          // ||chatList[i]['name'].toLowerCase().contains(text.toLowerCase())
          ) _searchResult.add(userDetail);
      // }
    });

    setState(() {});
  }
}

List _searchResult = [];
