import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/chat.dart';
import 'package:flutterwhatsappclone/Screens/groupChat/createGroup1.dart';
import 'package:flutterwhatsappclone/Screens/newcontact.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

class NewChat extends StatefulWidget {
  @override
  NewChatScreenState createState() {
    return new NewChatScreenState();
  }
}

class NewChatScreenState extends State<NewChat> {
  List<User> userlist;
  TextEditingController controller = new TextEditingController();
  Query query;
  String userId;
  StreamSubscription<Event> _onOrderAddedSubscription;
  StreamSubscription<Event> _onOrderChangedSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  var mob = [];
  bool isLoading = true;

  @override
  void initState() {
    print(mobileContacts.length.toString());

    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;
        // ignore: deprecated_member_use
        userlist = new List();
        query = database.reference().child("user");
        _onOrderAddedSubscription = query.onChildAdded.listen(onEntryAdded1);
        _onOrderChangedSubscription =
            query.onChildChanged.listen(onEntryChanged1);
      });
    }).then((value) {
      isLoading = false;
    });
    super.initState();
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
      // for (var i = 0; i < userlist.length; i++) {
      //   mob.add(userlist[i].mobile);
      // }
      // print(mob);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == true
          ? Center(
              child: loader(),
            )
          : allcontacts == null
              ? Container()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Container(
                      child: Material(
                        elevation: 0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              // height: SizeConfig.blockSizeVertical * 15,
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: appColorBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'New Chat',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "MontserratBold",
                                            color: appColorBlack,
                                          ),
                                        ),
                                        Text(
                                          '      ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: appColorWhite,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15, left: 15),
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
                                            style:
                                                TextStyle(color: Colors.grey),
                                            decoration: new InputDecoration(
                                              border: new OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
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
                            Divider(
                              thickness: 1,
                            ),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreateGroup1()),
                                      );
                                    },
                                    child: Container(
                                      height:
                                          SizeConfig.blockSizeVertical * 6.2,
                                      child: Center(
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.grey[200],
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.people,
                                                size: 25,
                                                color: appColorBlue,
                                              ),
                                              onPressed: () {},
                                            ),
                                          ),
                                          title: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              new Text(
                                                'New Group',
                                                style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: appColorBlue),
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
                                            builder: (context) => NewContact()),
                                      );
                                    },
                                    child: Container(
                                      height:
                                          SizeConfig.blockSizeVertical * 6.2,
                                      child: Center(
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.grey[200],
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.person_add,
                                                size: 25,
                                                color: appColorBlue,
                                              ),
                                              onPressed: () {},
                                            ),
                                          ),
                                          title: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              new Text(
                                                'New Contact',
                                                style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: appColorBlue),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(height: 5),
                                ],
                              ),
                            ),
                            Container(
                              height: SizeConfig.safeBlockVertical * 7,
                              color: Colors.grey[200],
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      'CONTACTS',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  4,
                                          fontFamily: "MontserratBold",
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            contactsWidget(),
                            // InkWell(
                            //   onTap: () {
                            //     Share.share(
                            //         "‎Let's chat on EocoChat! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://play.google.com/store/apps/details?id=com.devinventive.eocochat");
                            //   },
                            //   child: Container(
                            //     height: SizeConfig.safeBlockVertical * 7,
                            //     color: Colors.grey[200],
                            //     child: Row(
                            //       children: <Widget>[
                            //         Padding(
                            //           padding: const EdgeInsets.only(left: 15),
                            //           child: Text(
                            //             'Invite Friend to EocoChat',
                            //             style: TextStyle(
                            //                 fontSize:
                            //                     SizeConfig.safeBlockHorizontal *
                            //                         4,
                            //                 fontFamily: "MontserratBold",
                            //                 fontWeight: FontWeight.bold),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // inviteFriend()
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget contactsWidget() {
    return userlist != null && userlist.length > 0
        ? ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: userlist.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              // print(userlist[index].mobile);
              return mobileContacts.contains(userlist[index].mobile) &&
                      userId != userlist[index].userId
                  ? getContactName(userlist[index].mobile).contains(new RegExp(
                              controller.text,
                              caseSensitive: false)) ||
                          controller.text.isEmpty
                      ? Column(
                          children: <Widget>[
                            new Divider(
                              height: 1,
                            ),
                            new ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat(
                                            peerID: userlist[index].userId,
                                          )),
                                );
                              },
                              leading: new Stack(
                                children: <Widget>[
                                  (userlist[index].img.length > 0)
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(userlist[index].img),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          child: Image.asset(
                                            "assets/images/user.png",
                                            height: 25,
                                            color: Colors.white,
                                          )),
                                ],
                              ),
                              title: Text(
                                getContactName(userlist[index].mobile),
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              subtitle: new Container(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: new Row(
                                  children: [
                                    Text(
                                      userlist[index].mobile ?? "",
                                      style: TextStyle(fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container()
                  : Container();
            },
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget inviteFriend() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: allcontacts.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return allcontacts != null
            ? mob.contains(
                    allcontacts[index].phones.map((e) => e.value).toString())
                ? Container()
                : Column(
                    children: <Widget>[
                      new Divider(
                        height: 1,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: new ListTile(
                              onTap: () {},
                              leading: new Stack(
                                children: <Widget>[
                                  CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        allcontacts[index].displayName != null
                                            ? allcontacts[index].displayName[0]
                                            : "?",
                                        style: TextStyle(
                                            color: appColorBlue,
                                            fontSize: 20,
                                            fontFamily: "MontserratBold",
                                            fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                              title: Text(
                                allcontacts[index].displayName ?? "",
                                maxLines: 1,
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: new Container(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    allcontacts[index]
                                        .phones
                                        .map((e) => e.value)
                                        .toString()
                                        .replaceAll("(", "")
                                        .replaceAll(")", ""),
                                    maxLines: 1,
                                  )),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              inviteMe(allcontacts[index]
                                  .phones
                                  .map((e) => e.value)
                                  .toString());
                            },
                            child: CustomText(
                              text: "Invite",
                              color: appColorBlue,
                              fontSize: 15,
                              alignment: Alignment.center,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 15,
                          )
                        ],
                      ),
                    ],
                  )
            : Container;
      },
    );
  }

  // onSearchTextChanged(String text) async {
  //   _searchResult.clear();
  //   if (text.isEmpty) {
  //     setState(() {});
  //     return;
  //   }

  //   userlist.forEach((userDetail) {
  //     if (userDetail.name != null)
  //     // for (int i = 0; i < chatList.length; i++) {
  //     if (userDetail.name.toLowerCase().contains(text.toLowerCase()) ||
  //             userDetail.mobile.toLowerCase().contains(text.toLowerCase())
  //         // ||chatList[i]['name'].toLowerCase().contains(text.toLowerCase())
  //         ) _searchResult.add(userDetail);
  //     // }
  //   });

  //   setState(() {});
  // }

  inviteMe(phone) async {
    // Android
    String uri =
        'sms:$phone?body=${"‎Let's chat on Whoxa! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://play.google.com/store/apps/details?id=com.flutter.whoxaNew"}';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      String uri =
          'sms:$phone?body=${"‎Let's chat on Whoxa! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://play.google.com/store/apps/details?id=com.flutter.whoxaNew"}';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }
}

//List _searchResult = [];
