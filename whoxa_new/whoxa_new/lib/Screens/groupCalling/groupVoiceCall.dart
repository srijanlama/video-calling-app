import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutterwhatsappclone/constatnt/Constant.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:path_provider/path_provider.dart';

class GroupVoiceCall extends StatefulWidget {
  final String channelName;
  final String callerId;
  final String callerName;
  final String callerImage;

  const GroupVoiceCall(
      {Key key,
      this.channelName,
      this.callerId,
      this.callerName,
      this.callerImage})
      : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<GroupVoiceCall> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;
  bool closeCall = false;
  bool speaker = false;

  String totalDuration = '0';
  String totalUserJoined = '0';

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
    await _engine.enableAudio();
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
          totalUserJoined = value.userCount.toString();
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

          print(value.duration);
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
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              _onSpeaker();
            },
            child: Column(
              children: [
                Icon(
                  speaker
                      ? CupertinoIcons.speaker_2_fill
                      : CupertinoIcons.speaker_2_fill,
                  color: speaker ? Colors.black : appColorGrey,
                  size: 28,
                ),
                Container(height: 10),
                Text(
                  "Speaker",
                  style: TextStyle(
                      color: speaker ? Colors.black : appColorGrey,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            shape: CircleBorder(),
            elevation: 0,
            fillColor: speaker ? Colors.white : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Column(
              children: [
                Icon(
                  muted
                      ? CupertinoIcons.mic_slash_fill
                      : CupertinoIcons.mic_fill,
                  color: muted ? Colors.black : appColorGrey,
                  size: 28,
                ),
                Container(height: 10),
                Text(
                  "Mute",
                  style: TextStyle(
                      color: muted ? Colors.black : appColorGrey,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            shape: CircleBorder(),
            elevation: 0,
            fillColor: muted ? Colors.white : Colors.white,
            padding: const EdgeInsets.all(12.0),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, color: appColorGrey),
                Container(width: 5),
                Text(
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
        body: Container(
          decoration: BoxDecoration(color: appColorWhite),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.callerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: boldFamily,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Voice Call",
                        style: TextStyle(
                            fontSize: 12,
                            color: appColorGrey,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(height: 10),
                      Text(
                        "Total Joined : $totalUserJoined",
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
                              widget.callerImage,
                            ),
                          )),
                      SizedBox(height: 20),
                      Text(
                        totalDuration,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          _onCallEnd(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              border:
                                  Border.all(color: settingColorRed, width: 2),
                              color: appColorWhite),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, top: 18, bottom: 18),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "End Call",
                                    style: TextStyle(
                                        color: appColorBlack,
                                        fontSize: 16,
                                        fontFamily: boldFamily),
                                  ),
                                  Container(width: 10),
                                  Icon(CupertinoIcons.phone_fill),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _toolbar()
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  void _onSpeaker() {
    setState(() {
      speaker = !speaker;
    });
    if (speaker == true) {
      _engine.setEnableSpeakerphone(speaker);
    } else {
      _engine.setEnableSpeakerphone(speaker);
      player.earpieceOrSpeakersToggle();
    }
  }
}
