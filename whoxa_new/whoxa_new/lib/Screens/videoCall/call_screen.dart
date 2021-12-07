import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'dart:math' as math;

// ignore: must_be_immutable
class CallScreen extends StatefulWidget {
  final Call call;
  // ignore: avoid_init_to_null
  RtcEngine _engine = null;

  CallScreen({
    @required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();

  UserProvider userProvider;
  StreamSubscription callStreamSubscription;

  List<int> _users = <int>[];
  final _infoStrings = <String>[];
  bool isJoined = false, switchCamera = true, switchRender = true;
  bool muted = false;
  bool peerUser = false;
  bool currentUser = true;

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
    //player.earpieceOrSpeakersToggle();
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
    widget._engine?.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
      // ignore: unnecessary_brace_in_string_interps
      print('joinChannelSuccess ${channel} ${uid} ${elapsed}');
      callData(channel.toString());
      final info = 'onJoinChannel: $channel, uid: $uid';
      setState(() {
        _infoStrings.add(info);
        totalDuration = '0';
        totalUser = '';
        isJoined = true;
      });
    }, userJoined: (uid, elapsed) {
      // ignore: unnecessary_brace_in_string_interps
      print('userJoined  ${uid} ${elapsed}');
      setState(() {
        final info = 'onUserJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
        // remoteUid.add(uid);
      });
    }, userOffline: (uid, reason) {
      // if call was picked

      setState(() {
        _users.removeWhere((element) => element == uid);
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) async {
      print('leaveChannel ${stats.toJson()}');
      setState(() {
        player.stop();
        _infoStrings.add('onLeaveChannel');
        _users.clear();
        isJoined = false;
        widget._engine.destroy();
      });
    }, firstRemoteVideoFrame: (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }, rtcStats: (value) {
      setState(() {
        totalDuration = durationToString(value.duration);
        totalUser = value.userCount.toString();
        if (value.userCount == 2) {
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
    }, connectionLost: () {
      setState(() {
        final info = 'onConnectionLost';
        _infoStrings.add(info);
      });
    }));
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
    await widget._engine.joinChannel(null, widget.call.channelId, null, 0);
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

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    widget._engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    widget._engine.switchCamera();
  }

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
              fontSize: 20,
            ),
          ),
          Container(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: _onToggleMute,
                child: Icon(
                  muted ? Icons.mic : Icons.mic_off,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                onPressed: () {
                  callMethods.endCall(
                    call: widget.call,
                  );
                  setState(() {
                    player.stop();
                  });
                },
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
                child: Image.asset(
                  "assets/images/rotate.png",
                  height: 22,
                  // color: appColorBlack,
                ),
                // Icon(
                //   Icons.switch_camera,
                //   color: Colors.blueAccent,
                //   size: 20.0,
                // ),
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
  void dispose() {
    _users.clear();
    widget._engine.leaveChannel();
    widget._engine?.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            currentUser == true ? RtcLocalView.SurfaceView() : Container(),
            if (_users != null)
              peerUser == false
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.of(_users.map(
                            (e) => InkWell(
                              onTap: () {
                                setState(() {
                                  currentUser = false;
                                  peerUser = true;
                                });
                              },
                              child: Container(
                                width: 120,
                                height: 120,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: RtcRemoteView.SurfaceView(
                                    uid: e,
                                  ),
                                ),
                              ),
                            ),
                          )),
                        ),
                      ),
                    )
                  : Container(),
            peerUser == true
                ? Stack(
                    children: List.of(_users.map(
                      (e) => InkWell(
                        onTap: () {
                          setState(() {
                            currentUser = false;
                            peerUser = true;
                          });
                        },
                        child: Container(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: RtcRemoteView.SurfaceView(
                              uid: e,
                            ),
                          ),
                        ),
                      ),
                    )),
                  )
                : Container(),
            currentUser == false
                ? Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          currentUser = true;
                          peerUser = false;
                        });
                      },
                      child: Container(
                          width: 120,
                          height: 120,
                          child: RtcLocalView.SurfaceView()),
                    ))
                : Container(),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  FirebaseDatabase database = new FirebaseDatabase();

  callData(channelId) {
    FirebaseAuth.instance.currentUser().then((user) {
      CallModal model = new CallModal(
        widget.call.receiverName,
        widget.call.receiverPic,
        "video",
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
        "video",
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
