// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
// import 'package:flutterwhatsappclone/Screens/callScreen.dart';
// import 'package:flutterwhatsappclone/Screens/home.dart';
// import 'package:flutterwhatsappclone/Screens/setting.dart';
// // import 'package:flutterwhatsappclone/Screens/test.dart';
// import 'package:flutterwhatsappclone/Screens/videoCall/pickup_layout.dart';
// import 'package:flutterwhatsappclone/provider/get_phone.dart';
// import 'package:flutterwhatsappclone/share_preference/preferencesKey.dart';
// import 'package:flutterwhatsappclone/story/status.dart';
// import 'package:flutterwhatsappclone/constatnt/global.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:flutterwhatsappclone/Screens/videoCall/user_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Future<dynamic> _backgroundMessageHandler(Map<String, dynamic> message) async {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   await flutterLocalNotificationsPlugin.cancel(0);
// }

// class TabbarScreen extends StatefulWidget {
//   final String userID;
//   TabbarScreen({this.userID});
//   @override
//   _TabbarScreenState createState() => _TabbarScreenState();
// }

// class _TabbarScreenState extends State<TabbarScreen> {
//   int _currentIndex = 0;
//   UserProvider userProvider;
//   final FirebaseDatabase database = new FirebaseDatabase();

//   List<dynamic> _handlePages = [
//     ChatList(),
//     Status(),
//     CallHistory(),
//     SettingOptions()
//     //ReadContacts()
//   ];
//   final FirebaseDatabase _database = FirebaseDatabase.instance;
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   bool showApp = false;
//   bool isLoading = true;
//   @override
//   void initState() {
//     checkUser();

    
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final IOSInitializationSettings initializationSettingsIOS =
//         IOSInitializationSettings();
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: initializationSettingsAndroid,
//             iOS: initializationSettingsIOS);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       userProvider = Provider.of<UserProvider>(context, listen: false);
//       userProvider.refreshUser();
//     });

//     _firebaseMessaging.configure(
//       onBackgroundMessage: _backgroundMessageHandler,
//     );
//     FirebaseAuth.instance.currentUser().then((user) {
//       if (user != null)
//         _database.reference().child("user").child(user.uid).update({
//           "status": "Online",
//         });
//     });
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       userProvider = Provider.of<UserProvider>(context, listen: false);
//       userProvider.refreshUser();
//     });

//     permissionAcessPhone();

//     super.initState();
//   }

//   permissionAcessPhone() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.notification,
//       Permission.location,
//       Permission.storage,
//       Permission.camera,
//       Permission.contacts,
//       Permission.microphone,
//       Permission.mediaLibrary,
//     ].request();
//     print(statuses[Permission.location]);
//     if (await Permission.contacts.request().isGranted) {
//       getContactsFromGloble().then((value) {
//         getSavedContactsUserIds();
//       });
//     }
//   }

//   getSavedContactsUserIds() {
//     FirebaseAuth.instance.currentUser().then((user) {
//       print(user.uid);
//       setState(() {
//         userID = user.uid;
//       });
//     }).then((value) {
//       database.reference().child('user').once().then((DataSnapshot snapshot) {
//         snapshot.value.forEach((key, values) {
//           if (mobileContacts.contains(values["mobile"]) &&
//               userID != values["userId"]) {
//             setState(() {
//               savedContactUserId.add(values["userId"]);
//               print(savedContactUserId);
//             });
//           }
//         });
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     FlutterStatusbarcolor.setStatusBarColor(appColorBlue);
//     FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
//     return showApp == true
//         ? PickupLayout(
//             scaffold: WillPopScope(
//               onWillPop: () async {
//                 if (_currentIndex == 0) {
//                   SystemNavigator.pop();
//                 } else {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => TabbarScreen()),
//                   );
//                 }

//                 return false;
//               },
//               child: Scaffold(
//                 body: _handlePages[_currentIndex],
//                 bottomNavigationBar: BottomNavigationBar(
//                   type: BottomNavigationBarType.fixed,
//                   currentIndex: _currentIndex,
//                   onTap: (index) {
//                     setState(() {
//                       _currentIndex = index;
//                     });
//                   },
//                   items: <BottomNavigationBarItem>[
//                     _currentIndex == 0
//                         ? BottomNavigationBarItem(
//                             icon: Image.asset(
//                               "assets/images/chat.png",
//                               height: 27,
//                               color: appColorBlue,
//                             ),
//                             label: "",
//                           )
//                         : BottomNavigationBarItem(
//                             icon: Image.asset(
//                               "assets/images/chat.png",
//                               height: 27,
//                               color: appColorGrey,
//                             ),
//                             label: "",
//                           ),
//                     _currentIndex == 1
//                         ? BottomNavigationBarItem(
//                             icon: Image.asset(
//                               "assets/images/cam.png",
//                               height: 25,
//                               color: appColorBlue,
//                             ),
//                             label: "",
//                           )
//                         : BottomNavigationBarItem(
//                             icon: Image.asset(
//                               "assets/images/cam.png",
//                               height: 25,
//                               color: appColorGrey,
//                             ),
//                             label: "",
//                           ),
//                     _currentIndex == 2
//                         ? BottomNavigationBarItem(
//                             icon: Image.asset(
//                               "assets/images/call_blue.png",
//                               height: 27,
//                               color: appColorBlue,
//                             ),
//                             label: "",
//                           )
//                         : BottomNavigationBarItem(
//                             icon: Image.asset(
//                               "assets/images/call_blue.png",
//                               height: 27,
//                               color: appColorGrey,
//                             ),
//                             label: "",
//                           ),
//                     _currentIndex == 3
//                         ? BottomNavigationBarItem(
//                             icon: Image.asset(
//                               "assets/images/settings.png",
//                               height: 25,
//                               color: appColorBlue,
//                             ),
//                             label: "",
//                           )
//                         : BottomNavigationBarItem(
//                             icon: Image.asset(
//                               "assets/images/settings.png",
//                               height: 25,
//                               color: appColorGrey,
//                             ),
//                             label: "",
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         : Scaffold(
//             body: Container(
//               width: double.infinity,
//               color: Colors.white,
//               child: isLoading == true
//                   ? Center(
//                       child: Container(
//                         height: 60,
//                         width: 60,
//                         padding: EdgeInsets.all(15.0),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.transparent),
//                         child: CircularProgressIndicator(
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.blue)),
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.only(left: 20, right: 20),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Oops! Something went wrong, please login again.",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontSize: 16),
//                           ),
//                           Container(height: 20),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               InkWell(
//                                 onTap: () async {
//                                   SharedPreferences preferences =
//                                       await SharedPreferences.getInstance();
//                                   preferences
//                                       .remove(SharedPreferencesKey
//                                           .LOGGED_IN_USERRDATA)
//                                       .then((_) {
//                                     Navigator.of(context).pushAndRemoveUntil(
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             PhoneAuthGetPhone(),
//                                       ),
//                                       (Route<dynamic> route) => false,
//                                     );
//                                   });
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       color: appColorBlue,
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(8))),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(6),
//                                     child: Icon(
//                                       Icons.login,
//                                       size: 18,
//                                       color: appColorWhite,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//             ),
//           );
//   }

//   checkUser() async {
//     FirebaseAuth.instance.currentUser().then((user) {
//       if (user != null)
//         database
//             .reference()
//             .child('user')
//             .child(user.uid)
//             .once()
//             .then((peerData) {
//           setState(() {
//             if (peerData.value['name'] != null) {
//               isLoading = false;
//               showApp = true;
//             } else {
//               isLoading = false;
//             }
//           });
//         });
//     });
//   }
// }
