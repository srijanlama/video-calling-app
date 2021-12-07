import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsappclone/Screens/accountoptions.dart';
import 'package:flutterwhatsappclone/Screens/archiveChatList.dart';
import 'package:flutterwhatsappclone/Screens/broadCast/broadcast1.dart';
import 'package:flutterwhatsappclone/Screens/callScreen.dart';
import 'package:flutterwhatsappclone/Screens/chatoptions.dart';
import 'package:flutterwhatsappclone/Screens/editProfile.dart';
import 'package:flutterwhatsappclone/Screens/groupChat/createGroup1.dart';
import 'package:flutterwhatsappclone/Screens/saveContact.dart';
import 'package:flutterwhatsappclone/Screens/contactinfo.dart';
import 'package:flutterwhatsappclone/Screens/groupChat/groupChat.dart';
import 'package:flutterwhatsappclone/Screens/newchat.dart';
import 'package:flutterwhatsappclone/Screens/staredMsg.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/pickup_layout.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/provider/get_phone.dart';
import 'package:flutterwhatsappclone/share_preference/preferencesKey.dart';
import 'package:flutterwhatsappclone/story/myStatus.dart';
import 'package:flutterwhatsappclone/story/penStatusScreen.dart';
import 'package:flutterwhatsappclone/story/sendImageStory.dart';
import 'package:flutterwhatsappclone/story/sendVideoStory.dart';
import 'package:flutterwhatsappclone/story/store_page_view.dart';
//import 'package:flutterwhatsappclone/story/videoTrimer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/user_provider.dart';

// Future<dynamic> _backgroundMessageHandler(Map<String, dynamic> message) async {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   await flutterLocalNotificationsPlugin.cancel(0);
// }

class HomeScreen extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseDatabase database = new FirebaseDatabase();
  TextEditingController controller = new TextEditingController();
  bool selectAll = false;
  var selectPeerId = [];
  List chatList;
  bool search = false;

  Animation gap;
  Animation base;
  Animation reverse;
  AnimationController storyController;

  List myPostList = [];
  List postList = [];
  UserProvider userProvider;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;

  @override
  void initState() {
    getContactsFromGloble().then((value) {
      isLoading = false;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refreshUser();
    });
    // notificationInitinalize();
    print(mobileContacts);
    getSavedContactsUserIds();

    storyController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    base = CurvedAnimation(parent: storyController, curve: Curves.easeOut);
    reverse = Tween<double>(begin: .0, end: -1.0).animate(base);
    gap = Tween<double>(begin: 5, end: 1.0).animate(base)
      ..addListener(() {
        setState(() {});
      });
    storyController.forward();

    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null)
        database.reference().child("user").child(user.uid).update({
          "status": "Online",
        });
    });

    getLocalImages();
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);

      globalName = "";
      globalImage = "";
      mobNo = "";
      fullMob = "";

      userID = user.uid;

      getUser(userID);
    });

    super.initState();
  }

  refresh() {
    setState(() {});
  }

  notificationInitinalize() {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    // final IOSInitializationSettings initializationSettingsIOS =
    //     IOSInitializationSettings();
    // final InitializationSettings initializationSettings =
    //     InitializationSettings(
    //         android: initializationSettingsAndroid,
    //         iOS: initializationSettingsIOS);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   userProvider = Provider.of<UserProvider>(context, listen: false);
    //   userProvider.refreshUser();
    // });
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: true, badge: true, alert: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {});

    _firebaseMessaging.configure(
//      onBackgroundMessage: _backgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) {
        print('onMessage');
        print(message);
        Fluttertoast.showToast(
            msg: message['notification']['title'] +
                ":" +
                message['notification']['body']);
        print(message);
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch');
        print(message);
        Fluttertoast.showToast(
            msg: message['notification']['title'] +
                ":" +
                message['notification']['body']);

        return;
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume');
        print(message);

        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => Chat(
                      peerID: message['data']['user_id'],
                      archive: false,
                      pin: '',
                    )));

        return;
      },
    );
  }

  getSavedContactsUserIds() {
    FirebaseAuth.instance.currentUser().then((user) {
      userID = user.uid;
    }).then((value) {
      database.reference().child('user').once().then((DataSnapshot snapshot) {
        snapshot.value.forEach((key, values) {
          setState(() {
            if (mobileContacts.contains(values["mobile"]) &&
                userID != values["userId"]) {
              savedContactUserId.add(values["userId"]);
            }
          });
        });
      });
    });
  }

  getLocalImages() async {
    localImage.clear();
    SharedPreferences preferences1 = await SharedPreferences.getInstance();
    if (preferences1.containsKey("localImage")) {
      setState(() {
        localImage = preferences1.getStringList('localImage');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        endDrawer: drawerWidget(),
        appBar: search == true
            ? AppBar(
                title: searchTextField(),
                centerTitle: false,
                elevation: 0,
                backgroundColor: appColorWhite,
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  menuButton(),
                  Container(width: 15),
                ],
              )
            : AppBar(
                title: Text(
                  appName.toUpperCase(),
                  style: TextStyle(
                      fontSize: 20,
                      color: appColorBlue,
                      fontFamily: boldFamily,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: false,
                elevation: 0,
                backgroundColor: appColorWhite,
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  newChatButton(),
                  Container(width: 15),
                  searchButton(),
                  Container(width: 15),
                  menuButton(),
                  Container(width: 15),
                ],
              ),
        body: userID == '' || isLoading == true
            ? Center(child: loader())
            : DefaultTabController(
                length: 3,
                initialIndex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    SingleChildScrollView(
                        padding: const EdgeInsets.all(0),
                        scrollDirection: Axis.horizontal,
                        child: storyWidget()),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[100]),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 6, bottom: 6),
                        child: TabBar(
                          labelColor: Colors.black,
                          //isScrollable: true,
                          labelStyle: TextStyle(
                              fontSize: 11.0, fontFamily: "MontserratBold"),
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: appColorBlue),
                              color: appColorWhite),
                          tabs: <Widget>[
                            Tab(
                              text: 'CHATS',
                            ),
                            Tab(
                              text: 'STATUS',
                            ),
                            Tab(
                              text: 'CALLS',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          friendListToMessage(userID),
                          storyTab(),
                          CallHistory(controller: controller)
                        ],
                      ),
                    )
                  ],
                )

                // Column(
                //   children: [
                //     Expanded(
                //       child: SingleChildScrollView(
                //         child: Column(
                //           children: [
                //             storyWidget(),
                //             SizedBox(
                //               height: 20,
                //             ),
                //             friendListToMessage(userId)
                //           ],
                //         ),
                //       ),
                //     ),
                //     selectAll == true
                //         ? Container(
                //             color: Colors.grey[100],
                //             child: Padding(
                //               padding: const EdgeInsets.only(
                //                   left: 20, right: 20, top: 3, bottom: 3),
                //               child: Row(
                //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                 children: <Widget>[
                //                   InkWell(
                //                     onTap: () {
                //                       setState(() {
                //                         selectAll = false;
                //                       });

                //                       for (var i = 0; i <= selectPeerId.length; i++) {
                //                         Firestore.instance
                //                             .collection("chatList")
                //                             .document(userId)
                //                             .collection(userId)
                //                             .document(selectPeerId[i])
                //                             .updateData({'archive': true});
                //                       }
                //                     },
                //                     child: Container(
                //                       width: SizeConfig.blockSizeHorizontal * 25,
                //                       height: SizeConfig.blockSizeVertical * 4,
                //                       child: Center(
                //                           child: Text(
                //                         'Archive',
                //                         style: TextStyle(
                //                             color: appColorBlue,
                //                             fontSize: 16,
                //                             fontWeight: FontWeight.bold),
                //                       )),
                //                     ),
                //                   ),
                //                   InkWell(
                //                     onTap: () {
                //                       setState(() {
                //                         selectAll = false;
                //                       });

                //                       for (var i = 0; i <= selectPeerId.length; i++) {
                //                         Firestore.instance
                //                             .collection("chatList")
                //                             .document(userId)
                //                             .collection(userId)
                //                             .document(selectPeerId[i])
                //                             .updateData({'badge': '0'});
                //                       }
                //                     },
                //                     child: Container(
                //                       width: SizeConfig.blockSizeHorizontal * 25,
                //                       height: SizeConfig.blockSizeVertical * 4,
                //                       child: Center(
                //                           child: Text(
                //                         'Read All',
                //                         style: TextStyle(
                //                             color: appColorBlue,
                //                             fontSize: 16,
                //                             fontWeight: FontWeight.bold),
                //                       )),
                //                     ),
                //                   ),
                //                   InkWell(
                //                     onTap: () {
                //                       setState(() {
                //                         selectAll = false;
                //                       });

                //                       for (var i = 0; i <= selectPeerId.length; i++) {
                //                         Firestore.instance
                //                             .collection("chatList")
                //                             .document(userId)
                //                             .collection(userId)
                //                             .document(selectPeerId[i])
                //                             .delete();
                //                       }
                //                     },
                //                     child: Container(
                //                       width: SizeConfig.blockSizeHorizontal * 25,
                //                       height: SizeConfig.blockSizeVertical * 4,
                //                       child: Center(
                //                           child: Text(
                //                         'Delete',
                //                         style: TextStyle(
                //                             color: appColorBlue,
                //                             fontSize: 16,
                //                             fontWeight: FontWeight.bold),
                //                       )),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           )
                //         : Container(),
                //   ],
                // ),
                ),
      ),
    );
  }

  Widget newChatButton() {
    return Container(
      width: 25,
      child: IconButton(
        padding: const EdgeInsets.all(0),
        icon: Icon(
          CupertinoIcons.envelope_badge_fill,
          color: appColorBlue,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewChat()),
          );
        },
      ),
    );
  }

  Widget backButton() {
    return Container(
      width: 25,
      child: IconButton(
        padding: const EdgeInsets.all(0),
        icon: Icon(
          Icons.arrow_back,
          color: appColorBlue,
          size: 22,
        ),
        onPressed: () {
          setState(() {
            controller.clear();
            search = false;
          });
        },
      ),
    );
  }

  Widget menuButton() {
    return Container(
      width: 25,
      child: IconButton(
        padding: const EdgeInsets.all(0),
        icon: Icon(
          CupertinoIcons.square_grid_2x2_fill,
          color: appColorBlue,
        ),
        onPressed: () {
          scaffoldKey.currentState.openEndDrawer();
        },
      ),
    );
  }

  Widget drawerWidget() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8), topLeft: Radius.circular(40)),
          child: Drawer(
            elevation: 0,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditProfile(
                                                  refresh: refresh)),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          globalImage.length > 0
                                              ? Container(
                                                  height: 45,
                                                  width: 45,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9),
                                                    child: customImage(
                                                        globalImage),
                                                  ))
                                              : Container(
                                                  height: 45,
                                                  width: 45,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[400],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Image.asset(
                                                      "assets/images/user.png",
                                                      height: 10,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                          Container(width: 20),
                                          Text(
                                            globalName,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: appColorBlack,
                                                fontFamily: boldFamily,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(width: 10),
                                          Icon(CupertinoIcons
                                              .pencil_ellipsis_rectangle)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 25,
                                    child: IconButton(
                                      padding: const EdgeInsets.all(0),
                                      icon: Icon(
                                        CupertinoIcons.square_grid_2x2,
                                        color: appColorBlue,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  Container(width: 10)
                                ],
                              ),
                            )),
                        Divider(color: Colors.black45, height: 2),
                        Container(height: 30),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateGroup1()),
                            );
                          },
                          child: Row(
                            children: [
                              Container(width: 30),
                              Expanded(
                                child: Text(
                                  'NEW GROUP',
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black45,
                                      fontFamily: boldFamily,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(
                                Icons.add,
                                color: Colors.black45,
                                size: 25,
                              ),
                              Container(width: 30),
                            ],
                          ),
                        ),
                        Container(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EBroadcast()),
                            );
                          },
                          child: Row(
                            children: [
                              Container(width: 30),
                              Expanded(
                                child: Text(
                                  'NEW BROADCAST',
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black45,
                                      fontFamily: boldFamily,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(
                                Icons.add,
                                color: Colors.black45,
                                size: 25,
                              ),
                              Container(width: 30),
                            ],
                          ),
                        ),
                        Container(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StarMsg()),
                            );
                          },
                          child: Row(
                            children: [
                              Container(width: 30),
                              Expanded(
                                child: Text(
                                  'STARRED MESSAGES',
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black45,
                                      fontFamily: boldFamily,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(
                                CupertinoIcons.star_circle_fill,
                                color: Colors.black45,
                                size: 25,
                              ),
                              Container(width: 30),
                            ],
                          ),
                        ),
                        Container(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ArchiveChatList()),
                            );
                          },
                          child: Row(
                            children: [
                              Container(width: 30),
                              Expanded(
                                child: Text(
                                  'ARCHIVED CHATS',
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black45,
                                      fontFamily: boldFamily,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(
                                CupertinoIcons.archivebox_fill,
                                color: Colors.black45,
                                size: 25,
                              ),
                              Container(width: 30),
                            ],
                          ),
                        ),
                        // Container(height: 20),
                        // InkWell(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => SettingOptions()),
                        //     );
                        //   },
                        //   child: Row(
                        //     children: [
                        //       Container(width: 30),
                        //       Expanded(
                        //         child: Text(
                        //           'SETTINGS',
                        //           maxLines: 1,
                        //           style: TextStyle(
                        //               fontSize: 13,
                        //               color: Colors.black45,
                        //               fontFamily: boldFamily,
                        //               fontWeight: FontWeight.bold),
                        //         ),
                        //       ),
                        //       Icon(
                        //         CupertinoIcons.gear_alt_fill,
                        //         color: Colors.black45,
                        //         size: 25,
                        //       ),
                        //       Container(width: 30),
                        //     ],
                        //   ),
                        // ),
                        Container(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Divider(color: Colors.black45, height: 2),
                        ),
                        Container(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AccountOptions()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(width: 30),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Accounts',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black45,
                                        fontFamily: boldFamily,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Privacy, Security, Blocked',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatOptions()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(width: 30),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chats',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black45,
                                        fontFamily: boldFamily,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Theme, Wallpaper, Chat History',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Container(height: 20),
                        // InkWell(
                        //   onTap: () {},
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     children: [
                        //       Container(width: 30),
                        //       Column(
                        //         mainAxisAlignment: MainAxisAlignment.start,
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text(
                        //             'Notifications',
                        //             maxLines: 1,
                        //             style: TextStyle(
                        //                 fontSize: 13,
                        //                 color: Colors.black45,
                        //                 fontFamily: boldFamily,
                        //                 fontWeight: FontWeight.bold),
                        //           ),
                        //           Text(
                        //             'Message, Call & Group Tone',
                        //             maxLines: 1,
                        //             style: TextStyle(
                        //                 fontSize: 10,
                        //                 color: Colors.black45,
                        //                 fontWeight: FontWeight.bold),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        Container(height: 20),
                        InkWell(
                          onTap: () {
                            launch('https://www.primocys.com/');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(width: 30),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Help',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black45,
                                        fontFamily: boldFamily,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'FAQ, Contact Us, Privacy Policy',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(height: 20),
                        InkWell(
                          onTap: () {
                            Alert(
                              context: context,
                              title: "Log out",
                              desc: "Are you sure you want to log out?",
                              style: AlertStyle(
                                  isCloseButton: false,
                                  descStyle: TextStyle(
                                      fontFamily: "Montserrat", fontSize: 15),
                                  titleStyle:
                                      TextStyle(fontFamily: "MontserratBold")),
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "MontserratBold"),
                                  ),
                                  onPressed: () async {
                                    FirebaseAuth.instance
                                        .currentUser()
                                        .then((user) {
                                      if (user != null)
                                        database
                                            .reference()
                                            .child("user")
                                            .child(user.uid)
                                            .update({
                                          "status": DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          "inChat": ""
                                        });
                                    });
                                    SharedPreferences preferences =
                                        await SharedPreferences.getInstance();
                                    preferences
                                        .remove(SharedPreferencesKey
                                            .LOGGED_IN_USERRDATA)
                                        .then((_) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhoneAuthGetPhone(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    });
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  color: Color.fromRGBO(0, 179, 134, 1.0),
                                ),
                                DialogButton(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "MontserratBold"),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  gradient: LinearGradient(colors: [
                                    Color.fromRGBO(116, 116, 191, 1.0),
                                    Color.fromRGBO(52, 138, 199, 1.0)
                                  ]),
                                ),
                              ],
                            ).show();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(width: 30),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Logout',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black45,
                                        fontFamily: boldFamily,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Click here to sign out',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Share.share(
                        "‎Let's chat on $appName! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://play.google.com/store/apps/details?id=com.flutter.whoxaNew");
                  },
                  child: Column(
                    children: [
                      Text(
                        'Invite a Friend',
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(height: 25),
                      Text(
                        'from',
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(height: 25),
                      Text(
                        '$appName'.toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 16,
                            color: appColorBlue,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchButton() {
    return Container(
      width: 25,
      child: IconButton(
        padding: const EdgeInsets.all(0),
        icon: Icon(
          CupertinoIcons.search,
          color: appColorBlue,
        ),
        onPressed: () {
          setState(() {
            search = true;
          });
        },
      ),
    );
  }

  Widget editButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: selectAll == false
          ? Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: CustomText(
                  text: "Edit",
                  alignment: Alignment.centerLeft,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appColorBlue,
                ),
                onPressed: () {
                  setState(() {
                    selectAll = true;
                  });
                },
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: CustomText(
                  text: "Done",
                  alignment: Alignment.centerLeft,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: appColorBlue,
                ),
                onPressed: () {
                  selectPeerId.clear();

                  setState(() {
                    selectAll = false;
                  });
                },
              ),
            ),
    );
  }

  Widget searchTextField() {
    return Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Row(
          children: [
            backButton(),
            Container(width: 10),
            Expanded(
              child: Container(
                height: 40,
                child: Center(
                  child: TextField(
                    controller: controller,
                    onChanged: (_) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    decoration: new InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[400]),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[400]),
                      ),
                      filled: false,
                      hintStyle:
                          new TextStyle(color: Colors.grey[600], fontSize: 14),
                      hintText: "SEARCH",
                      contentPadding: EdgeInsets.only(top: 8, left: 5),
                      fillColor: Colors.grey[200],
                      suffixIcon: Icon(
                        CupertinoIcons.search,
                        color: appColorBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget friendListToMessage(String userData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("chatList")
              .document(userData)
              .collection(userData)
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              chatList = snapshot.data.documents;
              return Container(
                width: MediaQuery.of(context).size.width,
                child: snapshot.data.documents.length > 0
                    ?
                    // ? _searchResult.length != 0 ||
                    //         controller.text.trim().toLowerCase().isNotEmpty
                    //     ? ListView.builder(
                    //         itemCount: _searchResult.length,
                    //         physics: NeverScrollableScrollPhysics(),
                    //         shrinkWrap: true,
                    //         itemBuilder: (context, int index) {
                    //           return _searchResult[index]['archive'] != null &&
                    //                   _searchResult[index]['archive'] == false
                    //               ? _searchResult[index]['chatType'] != null &&
                    //                       _searchResult[index]['chatType'] ==
                    //                           "group"
                    //                   ? buildGroupItem(_searchResult, index)
                    //                   : buildItem(_searchResult, index)
                    //               : Container();
                    //         },
                    //       )  :
                    ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return chatList[index]['archive'] != null &&
                                  chatList[index]['archive'] == false
                              ? chatList[index]['chatType'] != null &&
                                      chatList[index]['chatType'] == "group"
                                  ? buildGroupItem(chatList, index)
                                  : buildItem(chatList, index)
                              : Container();
                        },
                      )
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/noimage.jpg",
                              width: 300,
                            ),
                            Text("Currently you don't have any messages"),
                          ],
                        ),
                      ),
              );
            }
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    CupertinoActivityIndicator(),
                  ]),
            );
          },
        ),
      ),
    );
  }

  Widget buildItem(List chatList, int index) {
    return chatList[index]['id'] == null
        ? Container()
        : StreamBuilder(
            stream: FirebaseDatabase.instance
                .reference()
                .child('user')
                .child(chatList[index]['id'])
                .onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.snapshot.value != null) {
                return getContactName(snapshot.data.snapshot.value["mobile"])
                            .contains(new RegExp(controller.text,
                                caseSensitive: false)) ||
                        controller.text.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 10, bottom: 10),
                        child: Material(
                          elevation: 5,
                          color: appColorWhite,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 10),
                            child: Row(
                              children: [
                                selectAll == true
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: selectPeerId
                                                .contains(chatList[index]['id'])
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectPeerId.remove(
                                                        chatList[index]['id']);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: appColorBlue,
                                                ))
                                            : InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectPeerId.add(
                                                        chatList[index]['id']);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.radio_button_unchecked,
                                                  color: appColorGrey,
                                                )),
                                      )
                                    : Container(),
                                Expanded(
                                  child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Chat(
                                                    peerID: chatList[index]
                                                        ['id'],
                                                    archive: chatList[index]
                                                                ['archive'] !=
                                                            null
                                                        ? chatList[index]
                                                            ['archive']
                                                        : false,
                                                    pin: chatList[index]
                                                                    ['pin'] !=
                                                                null &&
                                                            chatList[index]
                                                                        ['pin']
                                                                    .length >
                                                                0
                                                        ? '2549518301000'
                                                        : '',
                                                    chatListTime:
                                                        chatList[index]
                                                            ['timestamp'])));
                                      },
                                      onLongPress: () {
                                        _settingModalBottomSheet(
                                            context,
                                            userID,
                                            chatList[index]['id'],
                                            chatList[index]['archive'] != null
                                                ? chatList[index]['archive']
                                                : false,
                                            chatList[index]['timestamp'],
                                            chatList[index]['pin'] != null
                                                ? chatList[index]['pin']
                                                : '',
                                            chatList[index]['mute'] != null
                                                ? chatList[index]['mute']
                                                : false,
                                            chatList[index]['badge'],
                                            chatList[index]['chatType'] !=
                                                        null &&
                                                    chatList[index]
                                                            ['chatType'] ==
                                                        "group"
                                                ? "group"
                                                : "normal",
                                            snapshot
                                                .data.snapshot.value["name"],
                                            snapshot
                                                .data.snapshot.value["mobile"]);
                                      },
                                      leading: Container(
                                        height: 100,
                                        width: 60,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            InkWell(
                                                onTap: () {
                                                  showDialog(
                                                    context,
                                                    snapshot.data.snapshot
                                                        .value["name"],
                                                    snapshot.data.snapshot
                                                        .value["img"],
                                                    snapshot.data.snapshot
                                                        .value["mobile"],
                                                    chatList[index]['id'],
                                                  );
                                                },
                                                child: snapshot
                                                            .data
                                                            .snapshot
                                                            .value["img"]
                                                            .length >
                                                        0
                                                    ? Container(
                                                        height: 50,
                                                        width: 53,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9),
                                                          child: customImage(
                                                              snapshot
                                                                      .data
                                                                      .snapshot
                                                                      .value[
                                                                  "img"]),
                                                        ))
                                                    : Container(
                                                        height: 50,
                                                        width: 53,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[400],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Image.asset(
                                                            "assets/images/user.png",
                                                            height: 10,
                                                            color: Colors.white,
                                                          ),
                                                        ))),
                                            Positioned.fill(
                                              top: 0,
                                              left: 0,
                                              bottom: 10,
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: snapshot.data.snapshot
                                                            .value["status"] ==
                                                        "Online"
                                                    ? Icon(Icons.circle,
                                                        color: Colors.green,
                                                        size: 17)
                                                    : Container(),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      title: Text(
                                        getContactName(snapshot
                                            .data.snapshot.value["mobile"]),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: appColorBlack,
                                            fontSize: 14,
                                            fontFamily: boldFamily),
                                      ),
                                      subtitle: snapshot.data.snapshot
                                                      .value["status"] ==
                                                  "typing" &&
                                              snapshot.data.snapshot
                                                      .value["inChat"] ==
                                                  userID
                                          ? CustomText(
                                              text: 'typing..',
                                              alignment: Alignment.centerLeft,
                                              fontSize: 13,
                                              color: appColorBlue,
                                            )
                                          : msgTypeWidget(
                                              chatList[index]['type'],
                                              chatList[index]['content'])),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        readTimestamp(int.parse(
                                            chatList[index]['timestamp'])),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: int.parse(chatList[index]
                                                        ['badge']) >
                                                    0
                                                ? appColorBlue
                                                : Colors.grey,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          int.parse(chatList[index]['badge']) >
                                                  0
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: appColorBlue,
                                                  ),
                                                  alignment: Alignment.center,
                                                  height: 20,
                                                  width: 20,
                                                  child: Text(
                                                    chatList[index]['badge'],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 12),
                                                  ),
                                                )
                                              : Container(),
                                          chatList[index]['pin'] != null &&
                                                  chatList[index]['pin']
                                                          .length >
                                                      0
                                              ? Icon(Icons.push_pin,
                                                  color: appColorBlue, size: 16)
                                              : Container(),
                                          chatList[index]['mute'] == true
                                              ? Icon(Icons.volume_off,
                                                  color: appColorBlue, size: 17)
                                              : Container()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container();
              }
              return Container();
            },
          );
  }

  Widget buildGroupItem(List chatList, int index) {
    return chatList[index]['name']
                .contains(new RegExp(controller.text, caseSensitive: false)) ||
            controller.text.isEmpty
        ? Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: Material(
              elevation: 5,
              color: appColorWhite,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
                child: Row(
                  children: [
                    selectAll == true
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: selectPeerId.contains(chatList[index]['id'])
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectPeerId
                                            .remove(chatList[index]['id']);
                                      });
                                    },
                                    child: Icon(
                                      Icons.check_circle,
                                      color: appColorBlue,
                                    ))
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectPeerId.add(chatList[index]['id']);
                                      });
                                    },
                                    child: Icon(
                                      Icons.radio_button_unchecked,
                                      color: appColorGrey,
                                    )),
                          )
                        : Container(),
                    Expanded(
                      child: new ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => GroupChat(
                                          currentuser: userID,
                                          currentusername: globalName,
                                          currentuserimage: globalImage,
                                          peerID: chatList[index]['id'],
                                          peerUrl: chatList[index]
                                                          ['profileImage']
                                                      .length >
                                                  0
                                              ? chatList[index]['profileImage']
                                              : "",
                                          peerName: chatList[index]['name'],
                                          archive:
                                              chatList[index]['archive'] != null
                                                  ? chatList[index]['archive']
                                                  : false,
                                          pin: chatList[index]['pin'] != null &&
                                                  chatList[index]['pin']
                                                          .length >
                                                      0
                                              ? '2549518301000'
                                              : '',
                                          mute: chatList[index]['mute'] != null
                                              ? chatList[index]['mute']
                                              : false,
                                        )));
                          },
                          onLongPress: () {
                            //getIds(chatList[index]['id']);

                            _settingModalBottomSheet(
                                context,
                                userID,
                                chatList[index]['id'],
                                chatList[index]['archive'] != null
                                    ? chatList[index]['archive']
                                    : false,
                                chatList[index]['timestamp'],
                                chatList[index]['pin'] != null
                                    ? chatList[index]['pin']
                                    : '',
                                chatList[index]['mute'] != null
                                    ? chatList[index]['mute']
                                    : false,
                                chatList[index]['badge'],
                                "group",
                                "",
                                "");
                          },
                          leading: new Stack(
                            children: <Widget>[
                              InkWell(
                                  onTap: () {
                                    showDialog(
                                      context,
                                      chatList[index]['name'],
                                      chatList[index]['profileImage'],
                                      "",
                                      chatList[index]['id'],
                                    );
                                  },
                                  child: chatList[index]['profileImage'] !=
                                              null &&
                                          chatList[index]['profileImage']
                                                  .length >
                                              0
                                      ? Container(
                                          height: 50,
                                          width: 55,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            child: customImage(chatList[index]
                                                ['profileImage']),
                                          ))
                                      : Container(
                                          height: 50,
                                          width: 55,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Image.asset(
                                              "assets/images/groupuser.png",
                                              height: 10,
                                              color: Colors.white,
                                            ),
                                          ))),
                            ],
                          ),
                          title: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text(
                                chatList[index]['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: appColorBlack,
                                    fontSize: 14,
                                    fontFamily: boldFamily),
                              ),
                            ],
                          ),
                          subtitle: msgTypeWidget(chatList[index]['type'],
                              chatList[index]['content'])),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: new Text(
                              readTimestamp(
                                  int.parse(chatList[index]['timestamp'])),
                              style: new TextStyle(
                                  color: int.parse(chatList[index]['badge']) > 0
                                      ? appColorBlue
                                      : Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: 5,
                          ),
                          Row(
                            children: [
                              int.parse(chatList[index]['badge']) > 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appColorBlue,
                                      ),
                                      alignment: Alignment.center,
                                      height: 20,
                                      width: 20,
                                      child: Text(
                                        chatList[index]['badge'],
                                        style: TextStyle(
                                            color: appColorWhite,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12),
                                      ),
                                    )
                                  : Container(),
                              chatList[index]['pin'] != null &&
                                      chatList[index]['pin'].length > 0
                                  ? Icon(Icons.push_pin,
                                      color: appColorBlue, size: 16)
                                  : Container(),
                              chatList[index]['mute'] == true
                                  ? Icon(Icons.volume_off,
                                      color: appColorBlue, size: 17)
                                  : Container()
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  Widget msgTypeWidget(int type, String content) {
    return new Container(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          type == 1
              ? Row(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                      size: 17,
                    ),
                    Text(
                      "  Photo",
                      maxLines: 1,
                      style: new TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                )
              : type == 4
                  ? Row(
                      children: [
                        Icon(
                          Icons.video_call,
                          color: Colors.grey,
                          size: 17,
                        ),
                        Text(
                          "  Video",
                          maxLines: 1,
                          style: new TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    )
                  : type == 5
                      ? Row(
                          children: [
                            Icon(
                              Icons.note,
                              color: Colors.grey,
                              size: 17,
                            ),
                            Text(
                              "  File",
                              maxLines: 1,
                              style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        )
                      : type == 6
                          ? Row(
                              children: [
                                Icon(
                                  Icons.audiotrack,
                                  color: Colors.grey,
                                  size: 17,
                                ),
                                Text(
                                  "  Audio",
                                  maxLines: 1,
                                  style: new TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            )
                          : Text(
                              content,
                              maxLines: 1,
                              style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal),
                            ),
        ],
      ),
    );
  }

  void _settingModalBottomSheet(context, userId, peerId, arch, timestamp, pin,
      mute, badge, chatType, peerName, peerMobile) {
    print(peerId);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                timestamp == '2549518301000'
                    ? ListTile(
                        title: Center(child: new Text('Unpin')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'pin': '', 'timestamp': pin});
                        })
                    : ListTile(
                        title: Center(child: new Text('Pin')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({
                            'pin': timestamp,
                            'timestamp': '2549518301000'
                          });
                        }),
                badge == "0"
                    ? ListTile(
                        title: Center(child: new Text('Mark as Unread')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'badge': '1'});
                        })
                    : ListTile(
                        title: Center(child: new Text('Mark as read')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'badge': '0'});
                        },
                      ),
                mute == true
                    ? ListTile(
                        title: Center(child: new Text('Unmute')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'mute': false});
                        },
                      )
                    : ListTile(
                        title: Center(child: new Text('Mute')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'mute': true});
                        },
                      ),
                arch == true
                    ? ListTile(
                        title: Center(child: new Text('Unarchive')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'archive': false});
                        },
                      )
                    : ListTile(
                        title: Center(child: new Text('Archive')),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .updateData({'archive': true});
                        },
                      ),
                savedContactUserId.contains(peerId) || chatType == "group"
                    ? Container()
                    : ListTile(
                        title: Center(child: new Text('Save Contact')),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SaveContact(
                                    name: peerName,
                                    phone: peerMobile,
                                    peerId: peerId)),
                          );
                        },
                      ),
                chatType == "group"
                    ? ListTile(
                        title: Center(
                          child: new Text(
                            'Exit Group',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);

                          final FirebaseDatabase database =
                              new FirebaseDatabase();

                          database
                              .reference()
                              .child('group')
                              .child(peerId)
                              .once()
                              .then((peerData) {
                            var ids = [];
                            ids.addAll(peerData.value['userId']);
                            ids.remove(userId);
                            DatabaseReference _userRef =
                                database.reference().child('group');

                            _userRef.child(peerId).update({
                              "userId": ids,
                            }).then((_) {
                              Firestore.instance
                                  .collection("chatList")
                                  .document(userId)
                                  .collection(userId)
                                  .document(peerId)
                                  .delete();
                            });
                          });
                        },
                      )
                    : ListTile(
                        title: Center(
                          child: new Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance
                              .collection("chatList")
                              .document(userId)
                              .collection(userId)
                              .document(peerId)
                              .delete();
                        },
                      ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: new RawMaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 2.0,
                      fillColor: Colors.grey[300],
                      child: Icon(
                        Icons.close,
                        size: 20.0,
                      ),
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void showDialog(BuildContext context, name, image, phone, id) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Barrier",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: SizeConfig.safeBlockVertical * 100,
            width: SizeConfig.screenWidth,
            child: Column(
              children: <Widget>[
                Container(
                    decoration: new BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          topRight: const Radius.circular(30.0),
                        )),
                    height: SizeConfig.safeBlockVertical * 30,
                    width: SizeConfig.screenWidth,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0)),
                      child: image.length > 0
                          ? Image.network(
                              image,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 50,
                            ),
                    )),
                Material(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0)),
                    ),
                    height: SizeConfig.blockSizeVertical * 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 8),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.blockSizeVertical * 2.5,
                                fontFamily: 'Montserrat'),
                          ),
                        ),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Text(
                                  phone,
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2,
                                      color: Colors.grey,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            ),
                            phone == ""
                                ? Container()
                                : RawMaterialButton(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();

                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => Chat(
                                                    peerID: id,
                                                  )));
                                    },
                                    elevation: 1,
                                    fillColor: Colors.white,
                                    child: Image.asset(
                                      "assets/images/chat.png",
                                      height: 27,
                                      color: appColorBlue,
                                    ),
                                    shape: CircleBorder(),
                                  ),
                            phone == ""
                                ? Container()
                                : RawMaterialButton(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ContactInfo(id: id)),
                                      );
                                    },
                                    elevation: 1,
                                    fillColor: Colors.white,
                                    child: Icon(
                                      Icons.info,
                                      size: 25.0,
                                      color: appColorBlue,
                                    ),
                                    shape: CircleBorder(),
                                  )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            margin: EdgeInsets.only(bottom: 45, left: 18, right: 18, top: 200),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  Widget storyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          myStatusWidget(),
          Container(height: 20),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 10),
                child: Text(
                  'RECENT UPDATES',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: boldFamily,
                      color: Colors.black45),
                ),
              ),
            ],
          ),
          instaStories(),
        ],
      ),
    );
  }

  Widget myStatusWidget() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("storyUser")
          .where(FieldPath.documentId, isEqualTo: userID)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return snapshot.hasData && snapshot.data.documents.length > 0
            ? ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: snapshot.data.documents.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  myPostList = snapshot.data.documents;
                  timeInfo(snapshot.data.documents, index);
                  return myPostList[index]["story"].toString() == "[]" &&
                          myPostList[index]["userId"] != userID
                      ? Container()
                      : Container(
                          height: SizeConfig.blockSizeVertical * 12,
                          child: Center(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    onTap: () {
                                      List listImage = [];
                                      for (var i = 0;
                                          i < myPostList[index]["story"].length;
                                          i++) {
                                        listImage
                                            .add(myPostList[index]["story"][i]);
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => StoryPageView(
                                                context,
                                                images: listImage,
                                                peerId: postList[index]
                                                    ["userId"],
                                                userId: userID)),
                                      );
                                    },
                                    leading: Container(
                                      height: 70,
                                      width: 70,
                                      child: new Stack(
                                        children: <Widget>[
                                          Container(
                                              height: 55,
                                              width: 55,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                child: customImage(
                                                  myPostList[index]["story"][
                                                              myPostList[index][
                                                                          "story"]
                                                                      .length -
                                                                  1]["type"] ==
                                                          "image"
                                                      ? myPostList[index]
                                                              ["story"][
                                                          myPostList[index]
                                                                      ["story"]
                                                                  .length -
                                                              1]["image"]
                                                      : videoImage,
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                    title: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Text(
                                          'My Status',
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "MontserratBold",
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    subtitle: new Container(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: new Text(
                                        format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(
                                            myPostList[index]["timestamp"],
                                          )),
                                        ),
                                        style: new TextStyle(
                                            color: Colors.grey, fontSize: 12.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[200],
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: appColorBlue,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PenStatusScreen()),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            SizeConfig.blockSizeHorizontal * 1,
                                      ),
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[200],
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.visibility,
                                            size: 20,
                                            color: appColorBlue,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyStatus()),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            SizeConfig.blockSizeHorizontal * 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                },
              )
            : Container(
                height: SizeConfig.blockSizeVertical * 12,
                child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: InkWell(
                            onTap: () {
                              openDialog(context);
                            },
                            child: Container(
                              height: 70,
                              width: 70,
                              child: new Stack(
                                children: <Widget>[
                                  globalImage.length > 0
                                      ? Container(
                                          height: 55,
                                          width: 55,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            child: customImage(globalImage),
                                          ))
                                      : Container(
                                          height: 55,
                                          width: 55,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Image.asset(
                                              "assets/images/user.png",
                                              height: 10,
                                              color: Colors.white,
                                            ),
                                          )),
                                  Positioned(
                                      bottom: 0,
                                      right: 5,
                                      child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              color: appColorBlue,
                                              shape: BoxShape.circle),
                                          child: Icon(
                                            Icons.add,
                                            color: appColorWhite,
                                            size: 18,
                                          ))),
                                ],
                              ),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'My Status',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "MontserratBold",
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          subtitle: Container(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text(
                              'Add to my status',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[200],
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: appColorBlue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PenStatusScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }

  openDialog(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Video",
              style: TextStyle(
                  color: appColorBlack,
                  fontSize: 16,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: () async {
              File video =
                  // ignore: deprecated_member_use
                  await ImagePicker.pickVideo(source: ImageSource.gallery);

              VideoPlayerController.file(video)
                ..initialize().then((_) {
                  setState(() {
                    if (video != null) {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) =>
                      //           SendVideoStory(videoFile: video)),
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SendVideoStory(videoFile: video)),
                      );
                    }
                  });
                });
              Navigator.of(context, rootNavigator: true).pop("Discard");
              // Navigator.of(context, rootNavigator: true).pop("Discard");

              // File _image;
              // final picker = ImagePicker();
              // final imageFile =
              //     await picker.getImage(source: ImageSource.camera);

              // if (imageFile != null) {
              //   setState(() {
              //     if (imageFile != null) {
              //       _image = File(imageFile.path);
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => SendStory(imageFile: _image)),
              //       );
              //     } else {}
              //   });
              // }
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Image",
              style: TextStyle(
                  color: appColorBlack,
                  fontSize: 16,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("Discard");

              File _image;
              final picker = ImagePicker();
              final imageFile =
                  await picker.getImage(source: ImageSource.gallery);

              if (imageFile != null) {
                setState(() {
                  if (imageFile != null) {
                    _image = File(imageFile.path);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SendStory(imageFile: _image)),
                    );
                  } else {}
                });
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontFamily: "MontserratBold"),
          ),
          isDefaultAction: true,
          onPressed: () {
            // Navigator.pop(context, 'Cancel');
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  Widget instaStories() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("storyUser")
          // .where("mobile", whereIn: mobileContacts)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var oldList = [];
          for (var i = 0; i < snapshot.data.documents.length; i++) {
            if (mobileContacts.contains(
                snapshot.data.documents[i]["mobile"] != null
                    ? snapshot.data.documents[i]["mobile"]
                    : "0")) {
              oldList.add(snapshot.data.documents[i]);
            }
          }
          var newList = oldList.toSet().toList();

          return Container(
              // height: 55,
              alignment: Alignment.centerLeft,
              child: newList.length > 0
                  ? ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: newList.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, int index) {
                        timeInfo(newList, index);
                        return newList[index]["userId"] == userID
                            ? Container()
                            : postWidget(newList, index);
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text(
                          "No recent updates to show right now",
                        ),
                      ),
                    ));
        }
        return Container();
      },
    );
  }

  Widget postWidget(postList, index) {
    return getContactName(postList[index]["mobile"])
                .contains(new RegExp(controller.text, caseSensitive: false)) ||
            controller.text.isEmpty
        ? postList[index]["story"].toString() == "[]"
            ? Container()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ListTile(
                      onTap: () {
                        List listImage = [];
                        for (var i = 0;
                            i < postList[index]["story"].length;
                            i++) {
                          listImage.add(postList[index]["story"][i]);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StoryPageView(context,
                                  images: listImage,
                                  peerId: postList[index]["userId"],
                                  userId: userID)),
                        );
                      },
                      leading: Container(
                        width: 57,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: appColorBlue, width: 3)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: customImage(postList[index]["story"][
                                            postList[index]["story"].length - 1]
                                        ["type"] ==
                                    "image"
                                ? postList[index]["story"]
                                        [postList[index]["story"].length - 1]
                                    ["image"]
                                : videoImage)),
                      ),
                      title: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            getContactName(postList[index]["mobile"]),
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: "MontserratBold"),
                          ),
                        ],
                      ),
                      subtitle: new Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: new Text(
                          format(
                            DateTime.fromMillisecondsSinceEpoch(int.parse(
                              postList[index]["timestamp"],
                            )),
                          ),
                          style: new TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              )
        : Container();
  }

  getUser(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    database.reference().child('user').child(userId).once().then((peerData) {
      setState(() {
        globalName = peerData.value['name'];
        globalImage = peerData.value['img'];
        mobNo = peerData.value['mobile'];
        fullMob = peerData.value['countryCode'] + peerData.value['mobile'];

        preferences.setString('name', globalName);
        preferences.setString('image', globalImage);
      });
    });

    setState(() {});
  }

  // onSearchTextChanged(String text) async {
  //   _searchResult.clear();
  //   if (text.isEmpty) {
  //     setState(() {});
  //     return;
  //   }

  //   chatList.forEach((userDetail) {
  //     if (userDetail['name'] != null) if (userDetail['name']
  //         .toLowerCase()
  //         .contains(text.toLowerCase())) _searchResult.add(userDetail);
  //   });

  //   setState(() {});
  // }

  //STORYY>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Widget storyWidget() {
    return Row(
      children: [
        Container(width: 20),
        InkWell(
          onTap: () {
            openDialog(context);
          },
          child: Container(
            height: 55,
            width: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: appColorBlue, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              Icons.add,
              size: 30,
              color: appColorWhite,
            ),
          ),
        ),
        StreamBuilder(
          stream: Firestore.instance
              .collection("storyUser")
              // .where("mobile", whereIn: mobileContacts)
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var oldList = [];
              for (var i = 0; i < snapshot.data.documents.length; i++) {
                if (mobileContacts.contains(
                    snapshot.data.documents[i]["mobile"] != null
                        ? snapshot.data.documents[i]["mobile"]
                        : "0")) {
                  oldList.add(snapshot.data.documents[i]);
                }
              }
              postList = oldList.toSet().toList();

              return Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  height: 55,
                  alignment: Alignment.centerLeft,
                  child: postList.length > 0
                      ? ListView.builder(
                          padding: const EdgeInsets.all(0),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: postList.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            timeInfo(postList, index);
                            return rawPostWidget(postList, index);
                          },
                        )
                      : Container(),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Container(
                  // height: 50,
                  // alignment: Alignment.center,
                  // child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     mainAxisSize: MainAxisSize.max,
                  //     children: <Widget>[
                  //       CupertinoActivityIndicator(),
                  //     ]),
                  ),
            );
          },
        ),
      ],
    );
  }

  Widget rawPostWidget(postList, index) {
    return postList[index]["story"].toString() == "[]"
        ? Container()
        : Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Container(
              width: 57,
              child: InkWell(
                onTap: () {
                  List listImage = [];
                  for (var i = 0; i < postList[index]["story"].length; i++) {
                    listImage.add(postList[index]["story"][i]);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StoryPageView(context,
                            images: listImage,
                            peerId: postList[index]["userId"],
                            userId: userID)),
                  );
                },
                child: Container(
                  width: 57,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appColorBlue, width: 3)),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: customImage(postList[index]["story"]
                                      [postList[index]["story"].length - 1]
                                  ["type"] ==
                              "image"
                          ? postList[index]["story"]
                              [postList[index]["story"].length - 1]["image"]
                          : videoImage)),
                ),
              ),
            ),
          );
  }

  timeInfo(orderId, int index) async {
    for (var i = 0; i < orderId[index]["story"].length; i++) {
      // print(orderId[index]["story"][i]["time"]);
      var startTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(orderId[index]["story"][i]["time"]));
      var currentTime = DateTime.now();
      int diff = currentTime.difference(startTime).inDays;

      if (diff >= 1) {
        // setState(() {
        //   postList.remove(orderId[index]);
        // });
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + diff.toString());

        await Firestore.instance
            .collection("storyUser")
            .document(orderId[index]["userId"])
            .updateData({
          "story": FieldValue.arrayRemove([orderId[index]["story"][i]])
        }).then((value) {
          print("REMOVE");

          var document1 = Firestore.instance
              .collection("storyUser")
              .document(orderId[index]["userId"]);
          document1.get().then((value) async {
            if (value["story"].toString() == "[]") {
              await Firestore.instance
                  .collection("storyUser")
                  .document(orderId[index]["userId"])
                  .delete();
            }
          }).then((value) {});
        });
      } else {
        // Firestore.instance.collection("storyUser").document(uid).updateData({
        //   "story": FieldValue.arrayUnion([orderId[index]["story"][i]])
        // }).then((value) {
        //   print("UPDATE");
        // });
      }
    }
  }
}

//List _searchResult = [];
