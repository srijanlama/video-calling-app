import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/main.dart';
import 'package:flutterwhatsappclone/models/groupModel.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/user.dart';
import 'package:flutterwhatsappclone/constatnt/Constant.dart';
import 'package:contacts_service/contacts_service.dart';

class CreateGroup1 extends StatefulWidget {
  @override
  SelectBroadcastState createState() {
    return new SelectBroadcastState();
  }
}

class SelectBroadcastState extends State<CreateGroup1> {
  List<User> userlist;
  Query query;
  String userId;
  StreamSubscription<Event> _onOrderAddedSubscription;
  StreamSubscription<Event> _onOrderChangedSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  TextEditingController titleController = TextEditingController();
  TextEditingController controller = new TextEditingController();
  String currentUserName;
  String currentUserImage;
  String currentUserToken;
  int badgeCount = 0;

  var userIds = [];
  var userNames = [];
  var userImages = [];
  var userTokens = [];

  @override
  void initState() {
    super.initState();
    getContactsFromGloble().then((_) {
      refreshContacts();
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
      }).then((value) {
        mainWidget();
      });
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

  List<Contact> _contacts;
  var check = [];

  Future<void> refreshContacts() async {
    var contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
        .toList();
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          .toList();

    setState(() {
      _contacts = contacts;

      if (_contacts != null) {
        for (int i = 0; i < _contacts.length; i++) {
          Contact c = _contacts?.elementAt(i);
          check.add(c.phones.map((e) => e.value));
          //print(check);
        }
      }
    });

    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return;
        if (this.mounted) {
          setState(() => contact.avatar = avatar);
        } // Don't redraw if no change.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _contacts == null
          ? Container()
          : Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Material(
                elevation: 10,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: SizeConfig.blockSizeVertical * 15,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    'Add Participants',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "MontserratBold",
                                      color: appColorBlack,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (userIds.length > 1) {
                                        createGroup(context);
                                      }
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
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.only(right: 15, left: 15),
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
                                      onChanged: (_) {
                                        setState(() {});
                                      },
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
                                            color: Colors.grey[600],
                                            fontSize: 14),
                                        hintText: "Search",
                                        contentPadding:
                                            EdgeInsets.only(top: 10.0),
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
                          ],
                        ),
                      ),
                      mainWidget()
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget mainWidget() {
    return Expanded(
      child: userlist != null && userlist.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: userlist.length,
              itemBuilder: (BuildContext context, int index) {
                return getContactName(userlist[index].mobile).contains(
                            new RegExp(controller.text,
                                caseSensitive: false)) ||
                        controller.text.isEmpty
                    ? userWidget(userlist, index)
                    : Container();
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget userWidget(List userlist, int index) {
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
                          onTap: () {},
                          leading: new Stack(
                            children: <Widget>[
                              (userlist[index].img != null &&
                                      userlist[index].img.length > 0)
                                  ? CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          new NetworkImage(userlist[index].img),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      child: Image.asset(
                                        "assets/images/user.png",
                                        height: 25,
                                        color: Colors.white,
                                      )),
                            ],
                          ),
                          title: Text(
                            getContactName(userlist[index].mobile),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appColorBlack,
                              fontSize: 16.0,
                            ),
                          ),
                          subtitle: Container(
                            padding: EdgeInsets.only(top: 0),
                            child: new Row(
                              children: [
                                Text(
                                  userlist[index].mobile ?? "",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 13),
                                )
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
                          padding: const EdgeInsets.only(right: 20),
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  userIds.remove(userlist[index].userId);
                                  userNames.remove(userlist[index].name);
                                  userImages.remove(userlist[index].img);
                                  userTokens.remove(userlist[index].token);
                                });
                              },
                              child: Icon(
                                Icons.check_circle,
                                color: appColorBlue,
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  userIds.add(userlist[index].userId);
                                  userNames.add(userlist[index].name);
                                  userImages.add(userlist[index].img);
                                  userTokens.add(userlist[index].token);
                                });
                              },
                              child: Icon(
                                Icons.radio_button_unchecked,
                                color: appColorGrey,
                              )),
                        )
                ],
              )
            : Container();
  }

  void createGroup(BuildContext context) {
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Material(
                        child: Text(
                      'Enter Name of Group',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "MontserratBold",
                          fontSize: SizeConfig.blockSizeHorizontal * 3.8),
                    )),
                    SizedBox(
                      height: 10,
                    ),
                    Material(
                      child: CustomtextField(
                        controller: titleController,
                        maxLines: 1,
                        textInputAction: TextInputAction.next,
                        hintText: 'Enter Group name',
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
                            GroupModel model = new GroupModel(userIds, [userId],
                                titleController.text, "", "");

                            var orderRef =
                                database.reference().child("group").push();
                            orderRef.set(model.toJson()).then((value) async {
                              fire.Firestore.instance
                                  .collection("chatList")
                                  .document(userId)
                                  .collection(userId)
                                  .document(orderRef.key)
                                  .setData({
                                'id': orderRef.key,
                                'name': titleController.text,
                                'timestamp': DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                'content': "you added in a group",
                                'badge': '1',
                                'profileImage': '',
                                'type': 0,
                                'archive': false,
                                'mute': false,
                                'chatType': "group"
                              }).then((onValue) async {});

                              for (var i = 0; i <= userIds.length; i++) {
                                fire.Firestore.instance
                                    .collection("chatList")
                                    .document(userIds[i])
                                    .collection(userIds[i])
                                    .document(orderRef.key)
                                    .setData({
                                  'id': orderRef.key,
                                  'name': titleController.text,
                                  'timestamp': DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  'content': "you added in a group",
                                  'badge': '1',
                                  'profileImage': '',
                                  'type': 0,
                                  'archive': false,
                                  'mute': false,
                                  'chatType': "group"
                                }).then((onValue) async {
                                  Navigator.of(context)
                                      .pushReplacementNamed(APP_SCREEN);
                                  //  Navigator.pop(context);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => TabbarScreen()),
                                  // );
                                });
                              }
                            });
                            print(orderRef.key);
                          } else {
                            Toast.show("Enter group name", context,
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

        userIds.add(userId);
        userNames.add(currentUserName);
        userImages.add(currentUserImage);
        userTokens.add(currentUserToken);
      });
    });
  }
}
