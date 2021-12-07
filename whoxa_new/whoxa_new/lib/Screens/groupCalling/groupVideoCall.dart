import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/services.dart';
import 'package:flutterwhatsappclone/constatnt/Constant.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:path_provider/path_provider.dart';

class GroupVideoCall extends StatefulWidget {
  final String channelName;
  final String callerId;

  const GroupVideoCall({Key key, this.channelName, this.callerId})
      : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<GroupVideoCall> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;
  bool closeCall = false;

  String totalDuration = '0';

  AudioPlayer player = AudioPlayer();

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.callerId == userID) {
      _loadsound();
    }
    // initialize agora sdk
    initialize();
  }

  void _loadsound() async {
    final ByteData data = await rootBundle.load("assets/audio/calling.mp3");
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/calling.mp3');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    String mp3Uri = tempFile.uri.toString();
    _playsound(mp3Uri);
  }

  _playsound(mp3Uri) {
    // player.earpieceOrSpeakersToggle();
    player.play(mp3Uri);
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
          totalDuration = '0';
        });
      },
      leaveChannel: (stats) {
        setState(() {
          player.stop();
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
        });
      },
      rtcStats: (value) {
        setState(() {
          totalDuration = durationToString(value.duration);
          if (closeCall == true && value.userCount == 1) {
            _onCallEnd(context);
          }
          if (value.userCount == 2 || value.userCount == null) {
            closeCall = true;
            player.stop();
          }
          player.onPlayerCompletion.listen((event) {
            _onCallEnd(context);
          });

          print(value.userCount);
        });
      },
      connectionLost: () {
        setState(() {
          player.stop();
        });
      },
    ));
  }

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            totalDuration,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: appColorWhite),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: _onToggleMute,
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                onPressed: () => _onCallEnd(context),
                child: Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: _onSwitchCamera,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(12.0),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onCallEnd(context);
       
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: <Widget>[
              _viewRows(),
              _toolbar(),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  Future<void> _onCallEnd(BuildContext context) async {
    player.stop();
    await Firestore.instance
        .collection("groupCall")
        .document(widget.channelName)
        .get()
        .then((value) async {
      if (value.exists) {
        await Firestore.instance
            .collection("groupCall")
            .document(widget.channelName)
            .updateData({
          "groupUsers": FieldValue.arrayRemove([userID]),
          "joinedUser": FieldValue.arrayRemove([userID])
        }).then((value) async {
          await Firestore.instance
              .collection("groupCall")
              .document(widget.channelName)
              .get()
              .then((value) async {
            if (value["joinedUser"].length <= 1) {
              await Firestore.instance
                  .collection("groupCall")
                  .document(widget.channelName)
                  .delete();
            }
          });
          Navigator.pop(context);
        });
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}
