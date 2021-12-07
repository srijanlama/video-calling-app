// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutterwhatsappclone/Screens/groupCalling/jitsiGroup.dart';
// import 'package:flutterwhatsappclone/Screens/videoCall/cached_image.dart';
// import 'package:flutterwhatsappclone/constatnt/global.dart';

// // ignore: must_be_immutable
// class GroupPickupScreen extends StatefulWidget {
//   DocumentSnapshot document;
//   GroupPickupScreen({this.document});
//   @override
//   _PickupScreenState createState() => _PickupScreenState();
// }

// class _PickupScreenState extends State<GroupPickupScreen> {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   bool mini = true;
//   @override
//   void initState() {
//     callNotification();
//     super.initState();
//   }

//   callNotification() {
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'Wootsapp Notification',
//       'your channel name',
//       'your other channel description',
//       sound: RawResourceAndroidNotificationSound('custom'),
//     );
//     IOSNotificationDetails iOSPlatformChannelSpecifics =
//         IOSNotificationDetails(sound: 'custom.mp3');
//     MacOSNotificationDetails macOSPlatformChannelSpecifics =
//         MacOSNotificationDetails(sound: 'custom.mp3');
//     NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics,
//         macOS: macOSPlatformChannelSpecifics);
//     flutterLocalNotificationsPlugin.show(
//         0,
//         widget.document['groupName'] + "(${widget.document['callerName']})",
//         // widget.call.stype == "videocall"
//         //     ? "Whoxa Video Call"
//         //     : "Whoxa Voice Call",
//         'Whoxa Video Call',
//         platformChannelSpecifics);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return mini == false
//         ? Scaffold(
//             body: Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Color(0XFF738464).withOpacity(0.1),
//                         Color(0XFF9b7573),
//                       ]),
//                 ),
//                 alignment: Alignment.center,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Text(
//                         // widget.call.stype == "videocall"
//                         //     ? "Wootsapp Video Call"
//                         //     : "Wootsapp Voice Call",
//                         "Wootsapp Video Call",
//                         style: TextStyle(
//                           fontSize: 20,
//                         ),
//                       ),
//                       SizedBox(height: 60),
//                       Text(
//                         widget.document['groupName'] +
//                             "(${widget.document['callerName']})",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                       CachedImage(
//                         widget.document['callerImage'],
//                         isRound: true,
//                         radius: 180,
//                       ),
//                       SizedBox(height: 40),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           InkWell(
//                               onTap: () async {
//                                 await flutterLocalNotificationsPlugin.cancel(0);
//                                 Firestore.instance
//                                     .collection("groupCall")
//                                     .document(userID + "whoxa")
//                                     .delete();
//                               },
//                               child: Image.asset(
//                                 "assets/images/decline.png",
//                                 height: 60,
//                               )),
//                           SizedBox(width: 40),
//                           InkWell(
//                               onTap: () async {
//                                 await flutterLocalNotificationsPlugin.cancel(0);

//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => JitsiGroup(
//                                         channelId: widget.document['channelId'],
//                                         callType: widget.document['callType']),
//                                   ),
//                                 );
//                               },
//                               child: Image.asset(
//                                 "assets/images/accept.png",
//                                 height: 60,
//                               )),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 40, left: 20),
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                       icon: Icon(Icons.arrow_back_ios, size: 25),
//                       onPressed: () {
//                         setState(() {
//                           mini = true;
//                         });
//                       }),
//                 ),
//               )
//             ],
//           ))
//         : Padding(
//             padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
//             child: Card(
//               color: Colors.grey[200],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Container(
//                 height: 100,
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       mini = false;
//                     });
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 15, right: 15),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 widget.document['groupName'] +
//                                     "(${widget.document['callerName']})",
//                                 style: TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16),
//                               ),
//                               Text(
//                                 // widget.call.stype == "videocall"
//                                 //     ? "Wootsapp Video Call"
//                                 //     : "Wootsapp Voice Call",
//                                 "Wootsapp Voice Call",
//                                 style: TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16),
//                               ),
//                             ],
//                           ),
//                         ),
//                         InkWell(
//                             onTap: () async {
//                               await flutterLocalNotificationsPlugin.cancel(0);
//                               Firestore.instance
//                                   .collection("groupCall")
//                                   .document(userID + "whoxa")
//                                   .delete();
//                             },
//                             child: Image.asset(
//                               "assets/images/decline.png",
//                               height: 40,
//                               width: 40,
//                             )),
//                         Container(
//                           width: 15,
//                         ),
//                         InkWell(
//                             onTap: () async {
//                               await flutterLocalNotificationsPlugin.cancel(0);

//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => JitsiGroup(
//                                       channelId: widget.document['channelId'],
//                                       callType: widget.document['callType']),
//                                 ),
//                               );
//                             },
//                             child: Image.asset(
//                               "assets/images/accept.png",
//                               height: 40,
//                               width: 40,
//                             )),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//   }
// }
