import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call_method.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call_screen.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/voiceCall_screen.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';

class PickupScreen extends StatefulWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({@required this.call});

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool mini = false;
  @override
  void initState() {
  //  callNotification();
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
        widget.call.callerName,
        widget.call.stype == "videocall"
            ? "$appName Video Call"
            : "$appName Voice Call",
        platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    return mini == false
        ? Scaffold(
            backgroundColor: appColorWhite,
            appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: appColorGrey),
                    Container(width: 5),
                    widget.call.stype == "videocall"
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
                          widget.call.callerName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: boldFamily,
                          ),
                        ),
                        SizedBox(height: 20),
                        widget.call.stype == "videocall"
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
                                widget.call.callerPic,
                              ),
                            )),
                        SizedBox(height: 20),
                       
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                                onTap: () async {
                                  await flutterLocalNotificationsPlugin
                                      .cancel(0);
                                  await widget.callMethods
                                      .endCall(call: widget.call);
                                },
                                child: Image.asset(
                                  "assets/images/decline.png",
                                  height: 80,
                                )),
                            SizedBox(width: 40),
                            InkWell(
                                onTap: () async {
                                  await flutterLocalNotificationsPlugin
                                      .cancel(0);
                                  print("?????????");
                                  print(widget.call.stype);
                                  if (widget.call.stype == "videocall") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CallScreen(call: widget.call),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VoiceCallScreen(call: widget.call),
                                      ),
                                    );
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
            ))
        : Padding(
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            child: Card(
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                height: 100,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      mini = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.call.callerName,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Text(
                                widget.call.stype == "videocall"
                                    ? "$appName Video Call"
                                    : "$appName Voice Call",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                            onTap: () async {
                              await flutterLocalNotificationsPlugin.cancel(0);
                              await widget.callMethods
                                  .endCall(call: widget.call);
                            },
                            child: Image.asset(
                              "assets/images/decline.png",
                              height: 40,
                              width: 40,
                            )),
                        Container(
                          width: 15,
                        ),
                        InkWell(
                            onTap: () async {
                              await flutterLocalNotificationsPlugin.cancel(0);
                              print("?????????");
                              print(widget.call.stype);
                              if (widget.call.stype == "videocall") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CallScreen(call: widget.call),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VoiceCallScreen(call: widget.call),
                                  ),
                                );
                              }
                            },
                            child: Image.asset(
                              "assets/images/accept.png",
                              height: 40,
                              width: 40,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
