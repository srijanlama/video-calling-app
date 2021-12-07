// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutterwhatsappclone/Screens/videoCall/call_method.dart';
// import 'package:flutterwhatsappclone/constatnt/global.dart';
// import 'package:jitsi_meet/feature_flag/feature_flag.dart';
// import 'package:jitsi_meet/jitsi_meet.dart';
// import 'package:jitsi_meet/jitsi_meeting_listener.dart';

// // ignore: must_be_immutable
// class JitsiGroup extends StatefulWidget {
//   String channelId;
//   String callType;

//   JitsiGroup({this.channelId, this.callType});

//   @override
//   _CallScreenState createState() => _CallScreenState();
// }

// class _CallScreenState extends State<JitsiGroup> {
//   final CallMethods callMethods = CallMethods();

//   String serverText = TextEditingController().text;
//   String roomText = "";
//   String subjectText = "";
//   String nameText = TextEditingController(text: "Plugin Test User").text;
//   String emailText = TextEditingController(text: "fake@email.com").text;
//   var isAudioOnly;
//   var isAudioMuted;
//   var isVideoMuted;

//   var options = JitsiMeetingOptions();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.callType == 'voice') {
//       isAudioMuted = false;
//       isAudioOnly = true;
//       isVideoMuted = true;
//     } else {
//       isVideoMuted = false;
//       isAudioOnly = false;
//       isAudioMuted = false;
//     }

//     roomText = widget.channelId;
//     subjectText =
//         widget.callType == 'voice' ? "Whoxa voice call" : "Whoxa video call";
//     nameText = globalName;
//     emailText = "";

//     JitsiMeet.addListener(JitsiMeetingListener(
//         onConferenceWillJoin: _onConferenceWillJoin,
//         onConferenceJoined: _onConferenceJoined,
//         onConferenceTerminated: _onConferenceTerminated,
//         onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
//         onPictureInPictureTerminated: _onPictureInPictureTerminated,
//         onError: _onError));

//     _joinMeeting();
//   }

//   _joinMeeting() async {
//     // Navigator.pop(context);

//     try {
//       FeatureFlag featureFlag = FeatureFlag();
//       featureFlag.welcomePageEnabled = false;
//       // Here is an example, disabling features for each platform
//       if (Platform.isAndroid) {
//         // Disable ConnectionService usage on Android to avoid issues (see README)
//         featureFlag.callIntegrationEnabled = false;
//       } else if (Platform.isIOS) {
//         // Disable PIP on iOS as it looks weird
//         featureFlag.pipEnabled = false;
//       }

//       //uncomment to modify video resolution
//       //featureFlag.resolution = FeatureFlagVideoResolution.MD_RESOLUTION;

//       // Define meetings options here
//       options
//         ..room = roomText
//         ..serverURL = "https://meet.ritriv.com/test"
//         ..subject = subjectText
//         ..userDisplayName = nameText
//         //  ..userAvatarURL = globalImage
//         ..userEmail = emailText
//         ..audioOnly = isAudioOnly
//         ..audioMuted = isAudioMuted
//         ..videoMuted = isVideoMuted
//         ..featureFlag = featureFlag;

//       debugPrint("JitsiMeetingOptions: $options");
//       await JitsiMeet.joinMeeting(
//         options,
//         listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
//           print(
//               "1👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//           debugPrint("${options.room} will join with message: $message");
//         }, onConferenceJoined: ({message}) {
//           print(
//               "2👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//           debugPrint("${options.room} joined with message: $message");
//         }, onConferenceTerminated: ({message}) {
//           print(
//               "3👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");

//           debugPrint("${options.room} terminated with message: $message");
//         }, onPictureInPictureWillEnter: ({message}) {
//           print(
//               "4👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//           debugPrint("${options.room} entered PIP mode with message: $message");
//         }, onPictureInPictureTerminated: ({message}) {
//           print(
//               "5👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//           debugPrint("${options.room} exited PIP mode with message: $message");
//         }),
//         // by default, plugin default constraints are used
//         //roomNameConstraints: new Map(), // to disable all constraints
//         //roomNameConstraints: customContraints, // to use your own constraint(s)
//       );
//     } catch (error) {
//       debugPrint("error: $error");
//     }
//   }

//   void _onConferenceWillJoin({message}) {
//     Firestore.instance
//         .collection("groupCall")
//         .document(userID + "whoxa")
//         .delete()
//         .then((value) {
//       Navigator.pop(context);
//     });
//     print(
//         "6👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//   }

//   void _onConferenceJoined({message}) {
//     print(
//         "7👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//   }

//   void _onConferenceTerminated({message}) {
//     print(
//         "8👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//     print(message);
//     CollectionReference col1 = Firestore.instance.collection('groupCall');
//     final snapshots = col1.snapshots().map((snapshot) => snapshot.documents
//         .where((doc) => doc["channelId"] == widget.channelId));

//     snapshots.first.then((value) {
//       value.forEach((document) {
//         document.reference.delete();
//       });
//     });
//   }

//   void _onPictureInPictureWillEnter({message}) {
//     print(
//         "9👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//   }

//   void _onPictureInPictureTerminated({message}) {
//     print(
//         "10👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//   }

//   _onError(error) {
//     print(
//         "11👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌👌");
//   }

//   @override
//   void dispose() {
//     // clear users
//     JitsiMeet.removeAllListeners();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(backgroundColor: Colors.white, body: Container());
//   }
// }
