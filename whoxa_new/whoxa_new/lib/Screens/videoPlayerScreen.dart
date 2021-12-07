import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:video_player/video_player.dart';
// ignore: must_be_immutable
class SamplePlayer extends StatefulWidget {
  String url;
  SamplePlayer({this.url});
  @override
  _SamplePlayerState createState() => _SamplePlayerState();
}

class _SamplePlayerState extends State<SamplePlayer> {
  FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.url),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
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
      body: Container(
        child: FlickVideoPlayer(flickManager: flickManager),
      ),
    );
  }
}
