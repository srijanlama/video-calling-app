import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/videoView.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';

// ignore: must_be_immutable
class FullScreenVideo extends StatefulWidget {
  String video;

  FullScreenVideo({this.video});
  @override
  SettingOptionsState createState() {
    return new SettingOptionsState();
  }
}

class SettingOptionsState extends State<FullScreenVideo> {
  bool isInView = true;
  bool isLoading;

  @override
  void initState() {
    isLoading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "",
          style: TextStyle(
              fontFamily: "MontserratBold", fontSize: 17, color: appColorBlack),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: appColorBlue,
            )),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: isLoading == true ? Center(child: loader()) : Container(),
          ),
          VideoView(url: widget.video, play: isInView, id: "not null"),
        ],
      ),
    );
  }
}
