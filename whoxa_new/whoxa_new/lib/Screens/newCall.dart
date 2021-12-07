import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call_utilities.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutterwhatsappclone/Screens/videoCall/user.dart' as videoCall;

class NewCall extends StatefulWidget {
  @override
  NewChatScreenState createState() {
    return new NewChatScreenState();
  }
}

class NewChatScreenState extends State<NewCall> {
  List<User> userlist;
  Query query;
  String userId;
  StreamSubscription<Event> _onOrderAddedSubscription;
  StreamSubscription<Event> _onOrderChangedSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  Iterable<Item> data;
  TextEditingController controller = new TextEditingController();

  videoCall.User sender = videoCall.User();
  videoCall.User receiver = videoCall.User();
  @override
  void initState() {
    sender.uid = userID;
    sender.name = globalName;
    sender.profilePhoto = globalImage;

   
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      setState(() {
        userId = user.uid;
      });

      // ignore: deprecated_member_use
      userlist = new List();
      query = database.reference().child("user").orderByChild("userId");
      _onOrderAddedSubscription = query.onChildAdded.listen(onEntryAdded1);
      _onOrderChangedSubscription =
          query.onChildChanged.listen(onEntryChanged1);
      contactsWidget();
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
      if (User.fromSnapshot(event.snapshot).name != null)
        userlist.add(User.fromSnapshot(event.snapshot));
      userlist.sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: SizeConfig.blockSizeVertical * 6,
            ),
            Container(
              height: SizeConfig.blockSizeVertical * 17,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 25),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'NEW CALL',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'MontserratBold',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: appColorBlue,
                                ),
                              ),
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
                      padding:
                          const EdgeInsets.only(top: 10, right: 20, left: 20),
                      child: Container(
                        decoration: new BoxDecoration(
                            color: appColorBlue,
                            borderRadius: new BorderRadius.all(
                              Radius.circular(40.0),
                            )),
                        height: 40,
                        child: Center(
                          child: TextField(
                            controller: controller,
                            onChanged: onSearchTextChanged,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.grey[300]),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(40.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.grey[300]),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(40.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.grey[300]),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(40.0),
                                ),
                              ),
                              filled: true,
                              hintStyle: new TextStyle(color: Colors.grey),
                              hintText: "Search",
                              contentPadding: EdgeInsets.only(top: 10.0),
                              fillColor: Colors.grey[200],
                              prefixIcon: Icon(
                                Icons.search,
                                color: appColorBlue,
                                size: 30.0,
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
           
            // Container(
            //   height: SizeConfig.safeBlockVertical * 7,
            //   color: Colors.grey[300],
            //   child: Row(
            //     children: <Widget>[
            //       Padding(
            //         padding: const EdgeInsets.only(left: 15),
            //         child: Text(
            //           'CONTACTS',
            //           style: TextStyle(
            //               fontSize: SizeConfig.safeBlockHorizontal * 5,
            //               fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            contactsWidget()
          ],
        ),
      ),
    );
  }

  Widget contactsWidget() {
    return Expanded(
      flex: 5,
      child: userlist != null && userlist.length > 0
          ? _searchResult.length != 0 ||
                  controller.text.trim().toLowerCase().isNotEmpty
              ? ListView.builder(
                  itemCount: _searchResult.length,
                  itemBuilder: (context, int index) {
                    return allCallWidget(_searchResult, index);
                  },
                )
              : ListView.builder(
                  itemCount: userlist.length,
                  itemBuilder: (BuildContext context, int index) {
                    print(userlist[index].mobile);
                    return allCallWidget(userlist, index);
                  },
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget allCallWidget(userlist, index) {
    return mobileContacts.contains(userlist[index].mobile) &&
            userId != userlist[index].userId
        ? Column(
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
                          (userlist[index].img != null &&
                                  userlist[index].img.length > 0)
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      new NetworkImage(userlist[index].img),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[600],
                                  )),
                        ],
                      ),
                      title: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            userlist[index].name ?? "",
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      subtitle: new Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: new Row(
                          children: [
                            Text(userlist[index].mobile ?? "")
                            // ItemsTile(c.phones),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        receiver.uid = userlist[index].userId;
                        receiver.name = userlist[index].name;
                        receiver.profilePhoto = userlist[index].img;
                        sendCallNotification(userlist[index].token,
                            "Wootsapp Voice Calling....");
                        CallUtils.dial(
                            from: sender,
                            to: receiver,
                            context: context,
                            status: "voicecall");
                      },
                      icon: Icon(
                        Icons.call,
                        color: appColorBlue,
                      )),
                  Container(width: 0),
                  IconButton(
                      onPressed: () {
                        receiver.uid = userlist[index].userId;
                        receiver.name = userlist[index].name;
                        receiver.profilePhoto = userlist[index].img;
                        sendCallNotification(userlist[index].token,
                            "Wootsapp Video Calling....");
                        CallUtils.dial(
                            from: sender,
                            to: receiver,
                            context: context,
                            status: "videocall");
                      },
                      icon: Icon(
                        Icons.videocam,
                        color: appColorBlue,
                      )),
                  // Container(width: 10),
                ],
              ),
            ],
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

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    userlist.forEach((userDetail) {
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
