import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call_method.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/user_provider.dart';
import 'package:flutterwhatsappclone/constatnt/Constant.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/models/callModal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class VoiceCallScreen extends StatefulWidget {
  final Call call;
  // ignore: avoid_init_to_null
  RtcEngine _engine = null;
  String recName;
  String recImage;

  VoiceCallScreen({@required this.call, this.recName, this.recImage});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<VoiceCallScreen> {
  final CallMethods callMethods = CallMethods();

  UserProvider userProvider;
  StreamSubscription callStreamSubscription;

  List<int> _users = <int>[];
  final _infoStrings = <String>[];
  bool isJoined = false, switchCamera = true, switchRender = true;
  bool muted = false;
  bool peerUser = false;
  bool currentUser = true;
  bool speaker = true;
  bool mini = false;
  String totalDuration = '0';
  String totalUser = '';

  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    if (widget.call.callerId == userID) {
      _loadsound();
    }
    super.initState();
    this._initEngine();

    addPostFrameCallback();
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
    player.earpieceOrSpeakersToggle();
    player.play(mp3Uri);
  }

  _initEngine() async {
    // ignore: deprecated_member_use
    widget._engine = await RtcEngine.create(APP_ID);
    this._addListeners();

    await widget._engine.enableVideo();
    await widget._engine.startPreview();
    await widget._engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await widget._engine.setClientRole(ClientRole.Broadcaster);
    initializeAgora();
  }

  _addListeners() {
    widget._engine?.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        // ignore: unnecessary_brace_in_string_interps
        // print('joinChannelSuccess ${channel} ${uid} ${elapsed}');
        callData(channel.toString());
        final info = 'onJoinChannel: $channel, uid: $uid';
        setState(() {
          _infoStrings.add(info);
          totalDuration = '0';
          totalUser = '';
          isJoined = true;
        });
      },
      userJoined: (uid, elapsed) {
        // ignore: unnecessary_brace_in_string_interps
        // print('userJoined  ${uid} ${elapsed}'
        //     "👍 ");
        //print('userJoined  ${uid} ${elapsed}');
        setState(() {
          final info = 'onUserJoined: $uid';
          _infoStrings.add(info);
          print("👍 " + info.toString());
          _users.add(uid);
          // remoteUid.add(uid);
        });
      },
      userOffline: (uid, reason) {
        // if call was picked
        setState(() {
          _users.removeWhere((element) => element == uid);
          final info = 'userOffline: $uid';
          print("👍 " + info.toString());
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) async {
        // print('leaveChannel ${stats.toJson()}');
        setState(() {
          player.stop();
          _infoStrings.add('onLeaveChannel');
          _users.clear();
          isJoined = false;
          widget._engine.destroy();
        });
      },
      firstRemoteVideoFrame: (
        int uid,
        int width,
        int height,
        int elapsed,
      ) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      },
      rtcStats: (value) {
        setState(() {
          totalDuration = durationToString(value.duration);
          totalUser = value.userCount.toString();
          print("👍👍👍👍👍👍👍👍👍👍👍👍👍👍 " + value.userCount.toString());
          if (value.userCount == 2 || value.userCount == null) {
            player.stop();
          }
          player.onPlayerCompletion.listen((event) {
            callMethods.endCall(
              call: widget.call,
            );
            setState(() {
              player.stop();
            });
          });
          print(value.userCount);
        });
      },
      connectionLost: () {
        setState(() {
          player.stop();
          final info = 'onConnectionLost';
          _infoStrings.add(info);
        });
      },
    ));
  }

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  Future<void> initializeAgora() async {
    // await widget._engine.enableWebSdkInteroperability(true);
    await widget._engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await widget._engine
        .joinChannel(null, widget.call.channelId, null, 0)
        .then((value) {
      setState(() {
        _onSpeaker();
      });
    });
  }

  addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userProvider.getUser.uid)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data) {
          case null:
            player.stop();
            // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;

          default:
            break;
        }
      });
    });
  }

  void _onSpeaker() {
    setState(() {
      speaker = !speaker;
    });
    if (speaker == true) {
      widget._engine.setEnableSpeakerphone(speaker);
    } else {
      widget._engine.setEnableSpeakerphone(speaker);
      player.earpieceOrSpeakersToggle();
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    widget._engine.muteLocalAudioStream(muted);
  }

  // void _onSwitchCamera() {
  //   widget._engine.switchCamera();
  // }

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
  void dispose() {
    // clear users

    // rtcStats.
    _users.clear();
    // destroy sdk
    widget._engine.leaveChannel();
    //AgoraRtcEngine.destroy();
    widget._engine?.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mini == false
            ? Scaffold(
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
                                widget.recName != null
                                    ? widget.recName
                                    : widget.call.callerName,
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
                              SizedBox(height: 20),
                              Container(
                                  height: 300,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: customImage(
                                      widget.recImage != null
                                          ? widget.recImage
                                          : widget.call.callerPic,
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
                                  callMethods.endCall(
                                    call: widget.call,
                                  );
                                  setState(() {
                                    player.stop();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      border: Border.all(
                                          color: settingColorRed, width: 2),
                                      color: appColorWhite),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30,
                                        right: 30,
                                        top: 18,
                                        bottom: 18),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
              )
            : Container(
                height: 50,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: InkWell(
                    onTap: () {
                      setState(() {
                        mini = false;
                      });
                    },
                    child: Container(
                      color: appColorGreen,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  FirebaseDatabase database = new FirebaseDatabase();

  callData(channelId) {
    FirebaseAuth.instance.currentUser().then((user) {
      CallModal model = new CallModal(
        widget.call.receiverName,
        widget.call.receiverPic,
        "voice",
        "Outgoing",
        widget.call.callerId,
        widget.call.receiverId,
        widget.call.callerId,
        DateTime.now().millisecondsSinceEpoch.toString(),
        channelId,
      );

      database
          .reference()
          .child("call_history")
          .child(widget.call.callerId + channelId)
          .set(model.toJson());

      CallModal model2 = new CallModal(
        widget.call.callerName,
        widget.call.callerPic,
        "voice",
        user.uid.toString() == widget.call.callerId ? "Missed" : "Incoming",
        widget.call.callerId,
        widget.call.receiverId,
        widget.call.receiverId,
        DateTime.now().millisecondsSinceEpoch.toString(),
        channelId,
      );

      database
          .reference()
          .child("call_history")
          .child(widget.call.receiverId + channelId)
          .set(model2.toJson());
    });
  }
}
