import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/Constant.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;

  AnimationController animationController;
  Animation<double> animation;

  startTime() async {
    var _duration = new Duration(seconds: 4);
    return new Timer(_duration, navigationPage);
  }

  // void navigationPage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => Intro()),
  //   );
  // }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed(APP_SCREEN);
  }

  @override
  void initState() {
    super.initState();
    getUser();
    permissionAcessPhone();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 4));
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });

    // new Timer(new Duration(milliseconds: 3000), () {
    //   checkFirstSeen();
    // });
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      if (preferences.containsKey('name')) {
        globalName = preferences.getString('name');
        globalImage = preferences.getString('image');
      }
    });
  }

  permissionAcessPhone() async {
    await [
      Permission.contacts,
      Permission.notification,
      Permission.camera,
    ].request();

    if (await Permission.contacts.request().isGranted) {
      getContactsFromGloble();
      startTime();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: appColorWhite,
      body: Stack(
        children: [
          Center(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: appColorWhite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  imageLogo(),
                  globalName.length > 0 ? Container(height: 80) : Container(),
                  globalName.length > 0 ? textWidget() : Container(),
                ],
              ),
            ),
          ),
          bottomWidget()
        ],
      ),
    );
  }

  Widget imageLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 80,
          width: 80,
          child: Image.asset(
            'assets/images/applogo.png',
            fit: BoxFit.cover,
          ),
        ),
        globalImage.length > 0 ? Container(width: 50, height: 0) : Container(),
        globalImage.length > 0
            ? Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appColorBlue, width: 4)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: customImage(globalImage),
                ))
            : Container(),
      ],
    );
  }

  Widget textWidget() {
    return Column(
      children: [
        Text(
          "Logged in as ",
          style: TextStyle(
              color: Colors.black45, fontSize: 12, fontFamily: boldFamily),
        ),
        Container(height: 10),
        Text(
          globalName,
          style: TextStyle(
              color: Colors.black45, fontSize: 22, fontFamily: boldFamily),
        ),
      ],
    );
  }

  Widget bottomWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "from",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black45, fontSize: 14, fontFamily: boldFamily),
            ),
          ],
        ),
        Container(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$appName".toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: appColorBlue, fontSize: 20, fontFamily: boldFamily),
            ),
          ],
        ),
        Container(height: 40),
      ],
    );
  }
}
