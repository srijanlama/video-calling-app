import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterwhatsappclone/story/myStatus.dart';
import 'package:flutterwhatsappclone/story/penStatusScreen.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/story/sendImageStory.dart';
import 'package:image_editor_pro/image_editor_pro.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:flutterwhatsappclone/story/store_page_view.dart';
import 'package:timeago/timeago.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Status extends StatefulWidget {
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  Animation gap;
  Animation base;
  Animation reverse;
  AnimationController controller;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String userId;
  // ignore: unused_field
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  //APP BAR SCROLL
  bool _showAppbar = true;
  ScrollController _scrollBottomBarController = new ScrollController();
  bool isScrollingDown = false;

  List myPostList = [];
  List postList = [];
  var muteUsers = [];
  bool showMute = false;

  @override
  void initState() {
    myScroll();
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.uid);
      userId = user.uid;
      setState(() {
        isLoading = false;
      });
    });

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    base = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    reverse = Tween<double>(begin: .0, end: -1.0).animate(base);
    gap = Tween<double>(begin: 5, end: 1.0).animate(base)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();

    super.initState();
  }

  getMuteUsers() async {
    muteUsers = [];
    SharedPreferences preferences1 = await SharedPreferences.getInstance();
    if (preferences1.containsKey("mute" + userId)) {
      setState(() {
        muteUsers = preferences1.getStringList("mute" + userId);

        print("MUTE USERS:");
        print(muteUsers);
        bodyWidget();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollBottomBarController.removeListener(() {});

    super.dispose();
  }

  void showBottomBar() {
    setState(() {});
  }

  void hideBottomBar() {
    setState(() {});
  }

  void myScroll() async {
    _scrollBottomBarController.addListener(() {
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          hideBottomBar();
        }
      }
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          showBottomBar();
        }
      }
    });
  }

  File _image;
  // ignore: missing_return
  Future<void> getimageditor() {
    // ignore: unused_local_variable
    final geteditimage =
        Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditorPro(
        appBarColor: Colors.black,
        bottomBarColor: Colors.grey,
      );
    })).then((geteditimage) {
      if (geteditimage != null) {
        setState(() {
          _image = geteditimage;
          if (_image != null) {
            // addPost(context, globalName, globalImage, _image);
          }
        });
      }
    }).catchError((er) {
      print(er);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: _showAppbar
              ? Container()
              : Text(
                  "Status",
                  style: TextStyle(
                      fontFamily: "MontserratBold",
                      fontSize: 17,
                      color: appColorBlack),
                ),
          centerTitle: true,
          elevation: _showAppbar ? 0 : 1,
          backgroundColor: Colors.grey[100],
          automaticallyImplyLeading: false,
        ),
        body: isLoading == true ? Center(child: loader()) : bodyWidget());
  }

  Widget bodyWidget() {
    return SingleChildScrollView(
      controller: _scrollBottomBarController,
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            //admobWidget(),
            Container(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Status',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 7,
                          fontFamily: "MontserratBold",
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 0.5,
              color: Colors.grey[400],
            ),
            myStatusWidget(),
            Container(
              height: 0.5,
              color: Colors.grey[400],
            ),
            Container(
              color: Colors.grey[100],
              child: Row(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, top: 30, bottom: 10),
                    child: Text(
                      'RECENT UPDATES',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 0.5,
              color: Colors.grey[400],
            ),
            instaStories(),
            Container(
              height: 700,
            ),
          ],
        ),
      ),
    );
  }

  Widget myStatusWidget() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("storyUser")
          .where(FieldPath.documentId, isEqualTo: userId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return snapshot.hasData && snapshot.data.documents.length > 0
            ? ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  myPostList = snapshot.data.documents;
                  timeInfo(snapshot.data.documents, index,
                      snapshot.data.documents[index]["userId"]);
                  return myPostList[index]["story"].toString() == "[]" &&
                          myPostList[index]["userId"] != userId
                      ? Container()
                      : Container(
                          color: Colors.grey[50],
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
                                                userId: userId)),
                                      );
                                    },
                                    leading: Container(
                                      height: 70,
                                      width: 70,
                                      child: new Stack(
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                              myPostList[index]["story"][
                                                          myPostList[index]
                                                                      ["story"]
                                                                  .length -
                                                              1]["type"] ==
                                                      "image"
                                                  ? myPostList[index]["story"][
                                                      myPostList[index]["story"]
                                                              .length -
                                                          1]["image"]
                                                  : videoImage,
                                            ),
                                          ),
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
                                          ),
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
                                            color: Colors.grey, fontSize: 14.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Row(
                                    children: <Widget>[
                                      // CircleAvatar(
                                      //   radius: 20,
                                      //   backgroundColor: Colors.white,
                                      //   child: IconButton(
                                      //     icon: Icon(
                                      //       Icons.photo_camera,
                                      //       size: 20,
                                      //       color: Colors.green,
                                      //     ),
                                      //     onPressed: () {
                                      //       // getImage(context, globalName,
                                      //       //     globalImage);
                                      //       // openCameraMenu(context);
                                      //     },
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   width:
                                      //       SizeConfig.blockSizeHorizontal * 1,
                                      // ),
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[200],
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.photo_camera,
                                            size: 20,
                                            color: appColorBlue,
                                          ),
                                          onPressed: () {
                                            openDeleteDialog(context);
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
                color: Colors.grey[50],
                height: SizeConfig.blockSizeVertical * 12,
                child: Center(
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
                                          padding: const EdgeInsets.all(10.0),
                                          child: Image.asset(
                                            "assets/images/user.png",
                                            height: 10,
                                            color: Colors.white,
                                          ),
                                        )),
                                Positioned(
                                    bottom: 0.9,
                                    right: 10,
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
                          title: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text(
                                'My Status',
                                style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "MontserratBold",
                                ),
                              ),
                            ],
                          ),
                          subtitle: new Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: new Text(
                              'Add to my status',
                              style: new TextStyle(
                                  color: Colors.grey, fontSize: 14.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: <Widget>[
                            new CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[200],
                              child: IconButton(
                                icon: Icon(
                                  Icons.photo_camera,
                                  size: 20,
                                  color: appColorBlue,
                                ),
                                onPressed: () {
                                  openDeleteDialog(context);
                                },
                              ),
                            ),
                            // SizedBox(
                            //   width: SizeConfig.blockSizeHorizontal * 1.5,
                            // ),
                            // SizedBox(
                            //   width: SizeConfig.blockSizeHorizontal * 1,
                            // ),
                            // CircleAvatar(
                            //   radius: 20,
                            //   backgroundColor: Colors.white,
                            //   child: IconButton(
                            //     icon: Icon(
                            //       Icons.image,
                            //       size: 23,
                            //       color: appColorBlue,
                            //     ),
                            //     onPressed: () {
                            //       // getImage(context, globalName,
                            //       //     globalImage);
                            //       // openMenu(context);
                            //     },
                            //   ),
                            // ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 1.5,
                            ),
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

  Widget instaStories() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("storyUser")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data.documents.length > 0
              ? ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, int index) {
                    postList = snapshot.data.documents;
                    timeInfo(snapshot.data.documents, index,
                        snapshot.data.documents[index]["userId"]);
                    return muteUsers.contains(
                                snapshot.data.documents[index]["userId"]) ||
                            snapshot.data.documents[index]["userId"] == userId
                        ? Container()
                        : mobileContacts.contains(
                                snapshot.data.documents[index]["mobile"])
                            ? postWidget(postList, index)
                            : Container();
                  },
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text("No recent updates to show right now"),
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
    );
  }

  Widget postWidget(postList, index) {
    return postList[index]["story"].toString() == "[]"
        ? Container()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ListTile(
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
                              userId: userId)),
                    );
                  },
                  onLongPress: () {
                    // if (muteUsers.contains(postList[index]["userId"])) {
                    //   unMuteMenu(context, postList[index]["userId"]);
                    // } else {
                    //   muteMenu(context, postList[index]["userId"]);
                    // }
                  },
                  leading: new Stack(
                    children: <Widget>[
                      RotationTransition(
                        turns: base,
                        child: DashedCircle(
                          gapSize: 2,
                          dashes: 20,
                          color: appColorBlue,
                          child: RotationTransition(
                            turns: reverse,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CircleAvatar(
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Colors.grey,
                                backgroundImage: new NetworkImage(
                                  postList[index]["story"][
                                              postList[index]["story"].length -
                                                  1]["type"] ==
                                          "image"
                                      ? postList[index]["story"][
                                          postList[index]["story"].length -
                                              1]["image"]
                                      : videoImage,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                        postList[index]["userName"],
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
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
                      style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  timeInfo(orderId, int index, uid) async {
    for (var i = 0; i < orderId[index]["story"].length; i++) {
      // print(orderId[index]["story"][i]["time"]);
      var startTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(orderId[index]["story"][i]["time"]));
      var currentTime = DateTime.now();
      int diff = currentTime.difference(startTime).inDays;

      if (diff >= 1) {
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + diff.toString());

        await Firestore.instance
            .collection("storyUser")
            .document(uid)
            .updateData({
          "story": FieldValue.arrayRemove([orderId[index]["story"][i]])
        }).then((value) {
          print("REMOVE");

          var document1 =
              Firestore.instance.collection("storyUser").document(uid);
          document1.get().then((value) async {
            if (value["story"].toString() == "[]") {
              await Firestore.instance
                  .collection("storyUser")
                  .document(uid)
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

  openDeleteDialog(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Camera",
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
                  await picker.getImage(source: ImageSource.camera);

              if (imageFile != null) {
                setState(() {
                  if (imageFile != null) {
                    _image = File(imageFile.path);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SendStory(imageFile: _image)),
                    );
                  } else {
                    print('No image selected.');
                  }
                });
              }
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Gallery",
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
                  } else {
                    print('No image selected.');
                  }
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
}
