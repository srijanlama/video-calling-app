// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:video_trimmer/trim_editor.dart';
// import 'package:video_trimmer/video_trimmer.dart';
// import 'package:video_trimmer/video_viewer.dart';
// import '../constatnt/global.dart';
// import 'package:flutterwhatsappclone/story/sendVideoStory.dart';

// // ignore: must_be_immutable
// class VideoTrimer extends StatefulWidget {
//   File videoFile;
//   VideoTrimer({this.videoFile});
//   @override
//   _TrimmerViewState createState() => _TrimmerViewState();
// }

// class _TrimmerViewState extends State<VideoTrimer> {
//   final Trimmer _trimmer = Trimmer();
//   double _startValue = 0.0;
//   double _endValue = 0.0;
//   bool isLoading = true;

//   bool _isPlaying = false;
//   bool _progressVisibility = false;

//   Future<String> _saveVideo() async {
//     setState(() {
//       _progressVisibility = true;
//     });

//     String _value;

//     await _trimmer
//         .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
//         .then((value) {
//       setState(() {
//         _progressVisibility = false;
//         _value = value;
//       });
//     });

//     return _value;
//   }

//   @override
//   void initState() {
//     loadVideo();
//     super.initState();
//   }

//   loadVideo() async {
//     await _trimmer.loadVideo(videoFile: widget.videoFile).then((value) {
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           "",
//           style: TextStyle(
//               fontFamily: "MontserratBold", fontSize: 17, color: Colors.black),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: Colors.black,
//             )),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 15),
//             child: IconButton(
//               padding: const EdgeInsets.all(0),
//               onPressed: _progressVisibility
//                   ? null
//                   : () async {
//                       _saveVideo().then((outputPath) {
//                         if (outputPath != null)
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SendVideoStory(
//                                     videoFile: File(outputPath))),
//                           );
//                         print('OUTPUT PATH: $outputPath');
//                       });
//                     },
//               icon: Text(
//                 "Next",
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//           )
//         ],
//       ),
//       body: Builder(
//         builder: (context) => Center(
//           child: isLoading == true
//               ? Center(child: loader())
//               : Container(
//                   padding: EdgeInsets.only(bottom: 30.0),
//                   color: Colors.black,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.max,
//                     children: <Widget>[
//                       Visibility(
//                         visible: _progressVisibility,
//                         child: LinearProgressIndicator(
//                           backgroundColor: Colors.red,
//                         ),
//                       ),
//                       Expanded(
//                         child: VideoViewer(),
//                       ),
//                       Center(
//                         child: TrimEditor(
//                           viewerHeight: 50.0,
//                           viewerWidth: MediaQuery.of(context).size.width,
//                           maxVideoLength: Duration(seconds: 30),
//                           onChangeStart: (value) {
//                             _startValue = value;
//                           },
//                           onChangeEnd: (value) {
//                             _endValue = value;
//                           },
//                           onChangePlaybackState: (value) {
//                             setState(() {
//                               _isPlaying = value;
//                             });
//                           },
//                         ),
//                       ),
//                       // ignore: deprecated_member_use
//                       FlatButton(
//                         child: _isPlaying
//                             ? Icon(
//                                 Icons.pause,
//                                 size: 80.0,
//                                 color: Colors.white,
//                               )
//                             : Icon(
//                                 Icons.play_arrow,
//                                 size: 80.0,
//                                 color: Colors.white,
//                               ),
//                         onPressed: () async {
//                           bool playbackState =
//                               await _trimmer.videPlaybackControl(
//                             startValue: _startValue,
//                             endValue: _endValue,
//                           );
//                           setState(() {
//                             _isPlaying = playbackState;
//                           });
//                         },
//                       )
//                     ],
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }
