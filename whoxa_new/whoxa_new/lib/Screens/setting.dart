import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterwhatsappclone/Screens/accountoptions.dart';
import 'package:flutterwhatsappclone/Screens/chatoptions.dart';
import 'package:flutterwhatsappclone/Screens/editProfile.dart';
import 'package:flutterwhatsappclone/Screens/staredMsg.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/provider/get_phone.dart';
import 'package:flutterwhatsappclone/share_preference/preferencesKey.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingOptions extends StatefulWidget {
  @override
  SettingOptionsState createState() {
    return new SettingOptionsState();
  }
}

class SettingOptionsState extends State<SettingOptions> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
              fontFamily: "MontserratBold", fontSize: 17, color: appColorBlack),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appColorWhite,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: appColorBlack,
            size: 23,
          ),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // GridView(
              //   shrinkWrap: true,
              //   physics: BouncingScrollPhysics(),
              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 2),
              //   children: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

              //       // Wrap each item (Card) with Focused Menu Holder
              //       .map((e) => FocusedMenuHolder(
              //             menuWidth: MediaQuery.of(context).size.width * 0.50,
              //             blurSize: 5.0,
              //             menuItemExtent: 45,
              //             menuBoxDecoration: BoxDecoration(
              //                 color: Colors.grey,
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(15.0))),
              //             duration: Duration(milliseconds: 100),
              //             animateMenuItems: true,
              //             blurBackgroundColor: Colors.black54,
              //             openWithTap:
              //                 true, // Open Focused-Menu on Tap rather than Long Press
              //             menuOffset:
              //                 10.0, // Offset value to show menuItem from the selected item
              //             bottomOffsetHeight:
              //                 80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
              //             menuItems: <FocusedMenuItem>[
              //               // Add Each FocusedMenuItem  for Menu Options
              //               FocusedMenuItem(
              //                   title: Text("Open"),
              //                   trailingIcon: Icon(Icons.open_in_new),
              //                   onPressed: () {
              //                     // Navigator.push(
              //                     //     context,
              //                     //     MaterialPageRoute(
              //                     //         builder: (context) => ScreenTwo()));
              //                   }),
              //               FocusedMenuItem(
              //                   title: Text("Share"),
              //                   trailingIcon: Icon(Icons.share),
              //                   onPressed: () {}),
              //               FocusedMenuItem(
              //                   title: Text("Favorite"),
              //                   trailingIcon: Icon(Icons.favorite_border),
              //                   onPressed: () {}),
              //               FocusedMenuItem(
              //                   title: Text(
              //                     "Delete",
              //                     style: TextStyle(color: Colors.redAccent),
              //                   ),
              //                   trailingIcon: Icon(
              //                     Icons.delete,
              //                     color: Colors.redAccent,
              //                   ),
              //                   onPressed: () {}),
              //             ],
              //             onPressed: () {},
              //             child: Card(
              //               child: Column(
              //                 children: <Widget>[
              //                   Image.asset("assets/images/image_$e.jpg"),
              //                 ],
              //               ),
              //             ),
              //           ))
              //       .toList(),
              // ),
              Container(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        height: 0.5,
                        color: Colors.grey[400],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditProfile(refresh: refresh)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  leading: Container(
                                    height: 70,
                                    width: 70,
                                    child: new Stack(
                                      children: <Widget>[
                                        globalImage.length > 0
                                            ? CircleAvatar(
                                                radius: 30,
                                                backgroundImage:
                                                    NetworkImage(globalImage),
                                              )
                                            : Container(
                                                height: 65,
                                                width: 65,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[400],
                                                    shape: BoxShape.circle),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Image.asset(
                                                    "assets/images/user.png",
                                                    height: 10,
                                                    color: Colors.white,
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                  title: new Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new Text(
                                        globalName,
                                        style: new TextStyle(
                                            fontFamily: "MontserratBold",
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  // subtitle: new Container(
                                  //   padding: const EdgeInsets.only(top: 3),
                                  //   child: new Text(
                                  //     'my status',
                                  //     style: new TextStyle(
                                  //         color: Colors.grey, fontSize: 14),
                                  //   ),
                                  // ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: SizeConfig.blockSizeVertical * 6.4,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StarMsg()),
                                );
                              },
                              child: ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                      color: settingColoryellow,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.star,
                                      size: 23,
                                      color: appColorWhite,
                                    ),
                                  ),
                                ),
                                title: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      'Starred Messages',
                                      style: new TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: appColorGrey,
                              size: 20,
                            ),
                          ),
                          Container(width: 10)
                        ],
                      ),
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.grey[400],
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical * 6.4,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AccountOptions()),
                                );
                              },
                              child: ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                      color: settingColorBlue,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.vpn_key,
                                      size: 23,
                                      color: appColorWhite,
                                    ),
                                  ),
                                ),
                                title: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      'Account',
                                      style: new TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: appColorGrey,
                              size: 20,
                            ),
                          ),
                          Container(width: 10)
                        ],
                      ),
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.grey[400],
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical * 6.4,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatOptions()),
                                );
                              },
                              child: ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                      color: settingColorChat,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Image.asset(
                                        "assets/images/chat2.png",
                                        height: 20,
                                        color: Colors.white,
                                      )),
                                ),
                                title: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      'Chats',
                                      style: new TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: appColorGrey,
                              size: 20,
                            ),
                          ),
                          Container(width: 10)
                        ],
                      ),
                    ),
                    // Container(
                    //   height: 0.5,
                    //   color: Colors.grey[400],
                    // ),
                    // Container(
                    //   height: SizeConfig.blockSizeVertical * 6.4,
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: InkWell(
                    //           onTap: () {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                   builder: (context) =>
                    //                       NotificationOptions()),
                    //             );
                    //           },
                    //           child: ListTile(
                    //             leading: Container(
                    //               decoration: BoxDecoration(
                    //                   color: settingColorRed,
                    //                   borderRadius:
                    //                       BorderRadius.all(Radius.circular(8))),
                    //               child: Padding(
                    //                 padding: const EdgeInsets.all(4),
                    //                 child: Icon(
                    //                   Icons.notifications_none,
                    //                   size: 23,
                    //                   color: appColorWhite,
                    //                 ),
                    //               ),
                    //             ),
                    //             title: new Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceBetween,
                    //               children: <Widget>[
                    //                 new Text(
                    //                   'Notification',
                    //                   style: new TextStyle(
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.black),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Padding(
                    //         padding: const EdgeInsets.only(top: 0),
                    //         child: Icon(
                    //           Icons.arrow_forward_ios,
                    //           color: appColorGrey,
                    //           size: 20,
                    //         ),
                    //       ),
                    //       Container(width: 10)
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   height: 0.5,
                    //   color: Colors.grey[400],
                    // ),
                    // Container(
                    //   height: SizeConfig.blockSizeVertical * 6.4,
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: InkWell(
                    //           onTap: () {},
                    //           child: ListTile(
                    //             leading: Container(
                    //               decoration: BoxDecoration(
                    //                   color: settingColorChat,
                    //                   borderRadius:
                    //                       BorderRadius.all(Radius.circular(8))),
                    //               child: Padding(
                    //                   padding: const EdgeInsets.all(5),
                    //                   child: Image.asset(
                    //                     "assets/images/data.png",
                    //                     height: 20,
                    //                     color: Colors.white,
                    //                   )),
                    //             ),
                    //             title: new Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceBetween,
                    //               children: <Widget>[
                    //                 new Text(
                    //                   'Storage and Data',
                    //                   style: new TextStyle(
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.black),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Padding(
                    //         padding: const EdgeInsets.only(top: 0),
                    //         child: Icon(
                    //           Icons.arrow_forward_ios,
                    //           color: appColorGrey,
                    //           size: 20,
                    //         ),
                    //       ),
                    //       Container(width: 10)
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   height: 0.5,
                    //   color: Colors.grey[400],
                    // ),
                    // Container(
                    //   height: SizeConfig.blockSizeVertical * 6.4,
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: InkWell(
                    //           onTap: () {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                   builder: (context) => HelpOptions()),
                    //             );
                    //           },
                    //           child: ListTile(
                    //             leading: Container(
                    //               decoration: BoxDecoration(
                    //                   color: settingColorBlue,
                    //                   borderRadius:
                    //                       BorderRadius.all(Radius.circular(8))),
                    //               child: Padding(
                    //                   padding: const EdgeInsets.all(8),
                    //                   child: Image.asset(
                    //                     "assets/images/info.png",
                    //                     height: 15,
                    //                     color: Colors.white,
                    //                   )),
                    //             ),
                    //             title: new Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceBetween,
                    //               children: <Widget>[
                    //                 new Text(
                    //                   'Help',
                    //                   style: new TextStyle(
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.black),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Padding(
                    //         padding: const EdgeInsets.only(top: 0),
                    //         child: Icon(
                    //           Icons.arrow_forward_ios,
                    //           color: appColorGrey,
                    //           size: 20,
                    //         ),
                    //       ),
                    //       Container(width: 10)
                    //     ],
                    //   ),
                    // ),
                    Container(
                      height: 0.5,
                      color: Colors.grey[400],
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical * 6.4,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                Share.share(
                                    "‎Let's chat on $appName! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://play.google.com/store/apps/details?id=com.flutter.whoxaNew");
                              },
                              child: ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                      color: settingColorpink,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Image.asset(
                                        "assets/images/like.png",
                                        height: 18,
                                        color: Colors.white,
                                      )),
                                ),
                                title: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      'Tell a Friend',
                                      style: new TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: appColorGrey,
                              size: 20,
                            ),
                          ),
                          Container(width: 10)
                        ],
                      ),
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.grey[400],
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical * 6.4,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                Alert(
                                  context: context,
                                  title: "Log out",
                                  desc: "Are you sure you want to log out?",
                                  style: AlertStyle(
                                      isCloseButton: false,
                                      descStyle: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 15),
                                      titleStyle: TextStyle(
                                          fontFamily: "MontserratBold")),
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
                                            _database
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
                                            await SharedPreferences
                                                .getInstance();
                                        preferences
                                            .remove(SharedPreferencesKey
                                                .LOGGED_IN_USERRDATA)
                                            .then((_) {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PhoneAuthGetPhone(),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        });
                                        Navigator.of(context,
                                                rootNavigator: true)
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
                                        Navigator.of(context,
                                                rootNavigator: true)
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
                              child: ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                      color: settingColorChat,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.logout,
                                      size: 18,
                                      color: appColorWhite,
                                    ),
                                  ),
                                ),
                                title: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      'Log out',
                                      style: new TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: "Montserrat"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: appColorGrey,
                              size: 20,
                            ),
                          ),
                          Container(width: 10)
                        ],
                      ),
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
              //admobWidget(),
              Container(height: 500)
            ],
          ),
        ),
      ),
    );
  }
}
