// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterwhatsappclone/Screens/groupCalling/groupVideoCall.dart';
import 'package:flutterwhatsappclone/Screens/groupCalling/groupVoiceCall.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';

// ignore: must_be_immutable
class GroupPickupScreen extends StatefulWidget {
  DocumentSnapshot document;

  GroupPickupScreen({this.document});

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<GroupPickupScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    if (widget.document['callerId'] != userID) {
      //callNotification();
    }

    super.initState();
  }

  callNotification() {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '$appName Notification',
      'your channel name',
      'your other channel description',
      sound: RawResourceAndroidNotificationSound('custom'),
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'custom.mp3');
    MacOSNotificationDetails macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(sound: 'custom.mp3');
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
        macOS: macOSPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
        0,
        widget.document['callerName'],
        widget.document['type'] == "videoCall"
            ? "$appName Video Call"
            : "$appName Voice Call",
        platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appColorWhite,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, color: appColorGrey),
                Container(width: 5),
                widget.document['type'] == "videoCall"
                    ? Text(
                        "End-to-end video call",
                        style: TextStyle(
                            fontFamily: boldFamily,
                            fontSize: 14,
                            color: appColorGrey),
                      )
                    : Text(
                        "End-to-end voice call",
                        style: TextStyle(
                            fontFamily: boldFamily,
                            fontSize: 14,
                            color: appColorGrey),
                      ),
              ],
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: null),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.document['callerName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: boldFamily,
                      ),
                    ),
                    SizedBox(height: 20),
                    widget.document['type'] == "videoCall"
                        ? Text(
                            "Video Call",
                            style: TextStyle(
                                fontSize: 12,
                                color: appColorGrey,
                                fontWeight: FontWeight.bold),
                          )
                        : Text(
                            "Voice Call",
                            style: TextStyle(
                                fontSize: 12,
                                color: appColorGrey,
                                fontWeight: FontWeight.bold),
                          ),
                    SizedBox(height: 20),
                    Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: customImage(
                            widget.document['callerImage'],
                          ),
                        )),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                            onTap: () async {
                              await flutterLocalNotificationsPlugin.cancel(0);
                              endCall();
                            },
                            child: Image.asset(
                              "assets/images/decline.png",
                              height: 80,
                            )),
                        SizedBox(width: 40),
                        InkWell(
                            onTap: () async {
                              await flutterLocalNotificationsPlugin.cancel(0);

                              if (widget.document['type'] == "videoCall") {
                                joinCall();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupVideoCall(
                                        channelName:
                                            widget.document['channelId'],
                                        callerId: widget.document['callerId'],
                                      ),
                                    ));
                              } else {
                                joinCall();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupVoiceCall(
                                        channelName:
                                            widget.document['channelId'],
                                        callerId: widget.document['callerId'],
                                        callerName: widget.document['callerName'],
                                        callerImage: widget.document['callerImage'],
                                      ),
                                    ));
                              }
                            },
                            child: Image.asset(
                              "assets/images/accept.png",
                              height: 80,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 40, left: 20),
            //   child: Align(
            //     alignment: Alignment.topLeft,
            //     child: IconButton(
            //         icon: Icon(Icons.arrow_back_ios, size: 25),
            //         onPressed: () {
            //           setState(() {
            //             mini = true;
            //           });
            //         }),
            //   ),
            // )
          ],
        ));
  }

  endCall() {
    Firestore.instance
        .collection("groupCall")
        .document(widget.document['channelId'])
        .setData({
      "groupUsers": FieldValue.arrayRemove([userID]),
    }, merge: true);
  }

  joinCall() {
    Firestore.instance
        .collection("groupCall")
        .document(widget.document['channelId'])
        .setData({
      "groupUsers": FieldValue.arrayRemove([userID]),
      "joinedUser": FieldValue.arrayUnion([userID])
    }, merge: true);
  }
}
