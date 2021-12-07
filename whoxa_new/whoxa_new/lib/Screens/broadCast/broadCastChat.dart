import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterwhatsappclone/Screens/videoPlayerScreen.dart';
import 'package:flutterwhatsappclone/Screens/videoView.dart';
import 'package:flutterwhatsappclone/Screens/widgets/player_widget.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:file/local.dart';

// ignore: must_be_immutable
class BroadCastChat extends StatefulWidget {
  LocalFileSystem localFileSystem;
  List peerID;
  List peerUrl;
  List peerName;
  List peerToken;
  String currentusername;
  String currentuserimage;
  String currentuser;
  String castId;
  String castTitle;
  bool archive;
  String pin;
  bool mute;

  BroadCastChat(
      {this.peerID,
      this.peerUrl,
      this.peerName,
      this.currentusername,
      this.currentuserimage,
      this.currentuser,
      this.castId,
      this.castTitle,
      this.peerToken,
      this.archive,
      this.pin,
      this.mute,
      localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _ChatState createState() =>
      _ChatState(peerID: peerID, peerUrl: peerUrl, peerName: peerName);
}

class _ChatState extends State<BroadCastChat> {
  List peerID;
  List peerUrl;
  List peerName;

  _ChatState({@required this.peerID, this.peerUrl, @required this.peerName});
  final _scaffoldKey = GlobalKey<ScaffoldState>();
//RECORDER

  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  // ignore: unused_field
  TextEditingController _controller = new TextEditingController();

  bool record = false;
  bool running = false;
  bool button = false;
  File voiceRecording;

  //RECORDER

  String groupChatId;
  var listMessage;
  File videoFile;
  VideoPlayerController _videoPlayerController;
  bool isLoading;
  String imageUrl;
  int limit = 20;
  String peerToken;
  String peerCode;
  String peerOnlineStatus;

  final TextEditingController textEditingController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  TextEditingController reviewCode = TextEditingController();
  TextEditingController reviewText = TextEditingController();
  bool isInView = false;
  File _path;
  String filename;
  List<Contact> _contacts;
  var check = [];
  var toSendname = [];
  var toSendphone = [];

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
    onChange: (value) => print(''),
    onChangeRawSecond: (value) => print(''),
    onChangeRawMinute: (value) => print(''),
  );

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  //VIDEO UPLOADING
  var videoSize = '';
  double _progress = 0;
  double percentage = 0;
  bool videoloader = false;
  String videoStatus = '';

  @override
  void initState() {
    // refreshContacts();
    print(userID);
    _init();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {});
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {});
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {});
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        peerToken = "Push Messaging token: $token";
      });
      print(peerToken);
    });

    super.initState();

    groupChatId = '';
    isLoading = false;
    imageUrl = '';
    //removeBadge();
    // readMessage();
    setState(() {});
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        // ignore: deprecated_member_use
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  //New Contacts for share
  Future<void> refreshContacts() async {
    var contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
        .toList();
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          .toList();
    setState(() {
      _contacts = contacts;
      if (_contacts != null) {
        for (int i = 0; i < _contacts.length; i++) {
          Contact c = _contacts?.elementAt(i);
          // check.add(c.phones.map((e) => e.value).first);
          // print(check);
          check.add(c.phones
              .map((e) => e.value)
              .first
              .replaceAll(new RegExp(r"\s+"), ""));

          //  String formattedPhoneNumber = "(" + c.phones
          //         .map((e) => e.value)
          //         .first.substring(0,3) + ") " +
          // c.phones
          //         .map((e) => e.value)
          //         .first.substring(3,6) + "-" +c.phones
          //         .map((e) => e.value)
          //         .first.substring(6,c.phones
          //         .map((e) => e.value)
          //         .first.length);

          //         print("""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""");

          //         print(formattedPhoneNumber);

          print(check);
          //  _anotherCheck = _anotherCheck.replaceAll(new RegExp(r"\s+"), "");
          //   if(_inputPhone.contains(_anotherCheck)){
          //   print('+919998246663 and 99982 46663 are same');
          //}

        }
      }
    });

    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }
  //New Contacts for share

  void _openFileExplorer() async {
    _path = await FilePicker.getFile();

    setState(() async {
      if (_path != null) {
        setState(() {
          isLoading = true;
        });
        filename = path.basename(_path.path);
        final StorageReference postImageRef =
            FirebaseStorage.instance.ref().child("User Document");
        var timeKey = new DateTime.now();
        final StorageUploadTask uploadTask =
            postImageRef.child(timeKey.toString()).putFile(_path);
        var fileUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
        createMessage(fileUrl, 5, '');

        setState(() {
          isLoading = false;
        });
      }
    });
  }

  addFile(BuildContext context) async {
    if (videoFile != null) {
      setState(() {
        isLoading = true;
      });

      var timeKey = new DateTime.now();
      final StorageReference ref =
          FirebaseStorage.instance.ref().child("Video" + timeKey.toString());

      StorageUploadTask uploadTask = ref.putFile(
          videoFile, StorageMetadata(contentType: timeKey.toString() + '.mp4'));

      await uploadTask.onComplete;
      String downloadUrl = await ref.getDownloadURL();
      createMessage(downloadUrl, 4, '');

      setState(() {
        isLoading = false;
        _videoPlayerController.dispose();
      });
    } else {}
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _pickVideo() async {
    setState(() {
      videoFile = null;
      Navigator.pop(context);
    });

    final picker = ImagePicker();
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        videoFile = File(pickedFile.path);
        addVideo(context);
      } else {
        print('No video selected.');
      }
    });

    _videoPlayerController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        //  _videoPlayerController.play();
      });
  }

  addVideo(BuildContext context) async {
    if (videoFile != null) {
      await VideoCompress.setLogLevel(0);
      setState(() {
        _progress = 0;
        percentage = 0;
        videoloader = true;
        videoStatus = 'Compressing..';
      });
      final videoInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (videoInfo != null) {
        setState(() {
          videoStatus = 'Uploading..';
          final bytes = File(videoInfo.path).readAsBytesSync().lengthInBytes;
          final kb = bytes / 1024;
          final mb = kb / 1024;
          videoSize = mb.toStringAsFixed(2).toString() + "MB";
        });

        var timeKey = new DateTime.now();
        final StorageReference ref = FirebaseStorage.instance
            .ref()
            .child("ChatVideoMedia")
            .child("Video" + timeKey.toString());

        StorageUploadTask uploadTask = ref.putFile(File(videoInfo.path),
            StorageMetadata(contentType: timeKey.toString() + '.mp4'));
        uploadTask.events.listen((event) {
          setState(() {
            _progress = event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble();
            percentage = _progress;
            print('Uploading ${(_progress * 100).toStringAsFixed(2)} %');
          });
        }).onError((error) {
          // do something to handle error
        });

        await uploadTask.onComplete;
        String downloadUrl = await ref.getDownloadURL();

        createMessage(downloadUrl, 4, '');
        setState(() {
          videoloader = false;
          _videoPlayerController.dispose();
          _videoPlayerController.pause();
        });
        return videoInfo;
      } else {
        setState(() {
          videoloader = false;
          _videoPlayerController.dispose();
          _videoPlayerController.pause();
        });
        print("NULLLL");
        return videoInfo;
      }
    } else {
      setState(() {
        videoloader = false;
        _videoPlayerController.dispose();
        _videoPlayerController.pause();
      });
    }
  }

  // addVideo(BuildContext context) async {
  //   if (videoFile != null) {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     var timeKey = new DateTime.now();
  //     final StorageReference ref =
  //         FirebaseStorage.instance.ref().child("Video" + timeKey.toString());

  //     StorageUploadTask uploadTask = ref.putFile(
  //         videoFile, StorageMetadata(contentType: timeKey.toString() + '.mp4'));

  //     await uploadTask.onComplete;
  //     String downloadUrl = await ref.getDownloadURL();
  //     createMessage(downloadUrl, 4, '');
  //     setState(() {
  //       isLoading = false;
  //       _videoPlayerController.dispose();
  //     });
  //   } else {}
  // }

//  Future _callUserDataFromSharedPrefs() async {
//    FutureBuilder(
//      future: FirebaseAuth.instance.currentUser(),
//      builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
//        if (snapshot.hasData) {
//          userData = snapshot.data.uid.toString();
//          return Text("");
//        } else {
//          return Text('Loading...');
//        }
//      },
//    );
//  }

  // removeBadge() async {
  //   await Firestore.instance
  //       .collection("chatList")
  //       .document(widget.currentuser)
  //       .collection(widget.currentuser)
  //       .document(peerID)
  //       .updateData({'badge': '0'});
  // }

  readMessage() async {
    await Firestore.instance
        .collection("messages")
        .document(groupChatId)
        .collection(groupChatId)
        .where("idTo", isEqualTo: widget.currentuser)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((documentSnapshot) {
        documentSnapshot.reference.updateData({'read': widget.currentuser});
      });
    });
  }

  void _scrollListener() {
    if (listScrollController.position.pixels ==
        listScrollController.position.maxScrollExtent) {
      startLoader();
    }
  }

  void startLoader() {
    setState(() {
      isLoading = true;
      fetchData();
    });
  }

  fetchData() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, onResponse);
  }

  void onResponse() {
    setState(() {
      isLoading = false;
      limit = limit + 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    listScrollController = new ScrollController()..addListener(_scrollListener);
    return Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: Material(
            elevation: 1,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: appColorWhite),
                  width: MediaQuery.of(context).size.width,
                  height: SizeConfig.blockSizeVertical * 12,
                  child: Container(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              color: appColorBlue,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                ),
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CupertinoActivityIndicator(),
                                    width: 30.0,
                                    height: 30.0,
                                    padding: EdgeInsets.all(10.0),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl:
                                      "https://www.xovi.com/wp-content/plugins/all-in-one-seo-pack/images/default-user-image.png",
                                  width: 30.0,
                                  height: 30.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      widget.castTitle,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "MontserratBold",
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Builder(
          builder: (context) => Stack(
            children: [
              Column(
                children: <Widget>[
                  buildListMessage(),
                  buildInput(),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child:
                    isLoading == true ? Center(child: loader()) : Container(),
              ),
              videoloader == true
                  ? Center(
                      child: Container(
                        height: 120,
                        width: 150,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularPercentIndicator(
                                radius: 60.0,
                                lineWidth: 5.0,
                                percent: percentage.roundToDouble(),
                                center: new Text(
                                    "${(_progress * 100).toStringAsFixed(0)}%"),
                                progressColor: Colors.green,
                              ),
                              Container(
                                height: 5,
                              ),
                              Text(
                                videoStatus,
                                style: TextStyle(fontSize: 14),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ));
  }

  Widget buildListMessage() {
    return Flexible(
      child:

          //  groupChatId == ''
          //     ? Center(
          //         child: CircularProgressIndicator(
          //             valueColor: AlwaysStoppedAnimation<Color>(appColorGreen)))
          //     :
          StreamBuilder(
        stream: Firestore.instance
            .collection('broadcast')
            .document(widget.castId)
            .collection(widget.currentuser)
            .orderBy('timestamp', descending: true)
            .limit(limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appColorGreen)));
          } else {
            listMessage = snapshot.data.documents;
            return Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1.0, 1.0), //(x,y)
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) =>
                      buildItem(index, snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                  reverse: true,
                  controller: listScrollController,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Future getImage() async {
  //   File _image;
  //   final picker = ImagePicker();
  //   final imageFile = await picker.getImage(source: ImageSource.gallery);

  //   if (imageFile != null) {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     setState(() {
  //       if (imageFile != null) {
  //         _image = File(imageFile.path);
  //       } else {
  //         print('No image selected.');
  //       }
  //     });

  //     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //     StorageReference reference =
  //         FirebaseStorage.instance.ref().child("ChatMedia").child(fileName);

  //     StorageUploadTask uploadTask = reference.putFile(_image);
  //     StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  //     storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
  //       imageUrl = downloadUrl;
  //       setState(() {
  //         isLoading = false;
  //         createMessage(imageUrl, 1, '');
  //       });
  //     }, onError: (err) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       // Fluttertoast.showToast(msg: 'This file is not an image');
  //     });
  //   }
  // }

  Future getImage() async {
    File _image;

    final picker = ImagePicker();
    final imageFile = await picker.getImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _image = File(imageFile.path);
      setState(() {
        isLoading = true;
      });
      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        _image.absolute.path,
        targetPath,
        quality: 20,
      ).then((value) async {
        print("Compressed");
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        StorageReference reference = FirebaseStorage.instance
            .ref()
            .child("ChatImageMedia")
            .child(fileName);

        StorageUploadTask uploadTask = reference.putFile(value);
        StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          imageUrl = downloadUrl;
          createMessage(imageUrl, 1, '');

          setState(() {
            isLoading = false;
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          // Fluttertoast.showToast(msg: 'This file is not an image');
        });
      });
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == widget.currentuser) {
      // Right (my message)
//       for (int i = 0; i < index; i++) {
//      readMessage();
// }

      return document['delete'].contains(widget.currentuser)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Text(
                        "you deleted this message",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 12),
                      )),
                      Row(
                        children: [
                          Text(
                            format(
                                DateTime.fromMillisecondsSinceEpoch(int.parse(
                                  document['timestamp'],
                                )),
                                locale: 'en_short'),
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal),
                          ),
                          Container(width: 3),
                          document['read'] == widget.peerID
                              ? Icon(
                                  Icons.done_all,
                                  size: 17,
                                  color: Colors.blue,
                                )
                              : Icon(
                                  Icons.done_all,
                                  size: 17,
                                  color: Colors.grey,
                                ),
                        ],
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 10.0),
                  width: 230.0,
                  decoration: BoxDecoration(
                      color: chatRightColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 10.0 : 10.0,
                      right: 10.0),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                InkWell(
                  onLongPress: () {},
                  child: Row(
                    children: <Widget>[
                      document['type'] == 0
                          // Text
                          ? Column(
                              children: [
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          document['content'],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            DateFormat('hh:mm a').format(
                                              DateTime.parse(
                                                converTime(
                                                    document['timestamp']),
                                              ),
                                            ),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0,
                                                fontStyle: FontStyle.normal),
                                          ),
                                          Container(width: 3),
                                          document['read'] == widget.peerID
                                              ? Icon(
                                                  Icons.done_all,
                                                  size: 17,
                                                  color: Colors.blue,
                                                )
                                              : Icon(
                                                  Icons.done_all,
                                                  size: 17,
                                                  color: Colors.grey,
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 15.0, 10.0),
                                  width: 230.0,
                                  decoration: BoxDecoration(
                                      color: chatRightColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  margin: EdgeInsets.only(
                                      bottom: isLastMessageRight(index)
                                          ? 10.0
                                          : 10.0,
                                      right: 10.0),
                                ),
                              ],
                            )
                          : document['type'] == 4
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: chatRightColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10, left: 10),
                                    // ignore: deprecated_member_use
                                    child: FlatButton(
                                      child: Material(
                                        color: chatRightColor,
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Container(
                                                height: 70,
                                                width: 70,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: VideoView(
                                                        url:
                                                            document['content'],
                                                        play: isInView,
                                                        // id: _orderList[index].key
                                                      )),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 5,
                                            ),
                                            Container(
                                              height: 70,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(height: 10),
                                                  Expanded(
                                                    child: Container(
                                                      width: 120,
                                                      child: Center(
                                                        child: Text(
                                                          "VIDEO_",
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .green[700],
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        DateFormat('hh:mm a')
                                                            .format(
                                                          DateTime.parse(
                                                            converTime(document[
                                                                'timestamp']),
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12.0,
                                                            fontStyle: FontStyle
                                                                .normal),
                                                      ),
                                                      Container(width: 3),
                                                      document['read'] ==
                                                              widget.peerID
                                                          ? Icon(
                                                              Icons.done_all,
                                                              size: 17,
                                                              color:
                                                                  Colors.blue,
                                                            )
                                                          : Icon(
                                                              Icons.done_all,
                                                              size: 17,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      Container(width: 5),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SamplePlayer(
                                                      url:
                                                          document['content'])),
                                        );
                                      },
                                      padding: EdgeInsets.all(0),
                                    ),
                                  ),
                                  margin: EdgeInsets.only(
                                      bottom: isLastMessageRight(index)
                                          ? 20.0
                                          : 10.0,
                                      right: 10.0),
                                )
                              : document['type'] == 5
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: chatRightColor,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                              topRight: Radius.circular(20))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10, left: 10),
                                        // ignore: deprecated_member_use
                                        child: FlatButton(
                                          child: Material(
                                            color: chatRightColor,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child:
                                                              Icon(Icons.note)),
                                                      Container(
                                                        width: 5,
                                                      ),
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          "FILE_",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .green[700],
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        DateFormat('hh:mm a')
                                                            .format(
                                                          DateTime.parse(
                                                            converTime(document[
                                                                'timestamp']),
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12.0,
                                                            fontStyle: FontStyle
                                                                .normal),
                                                      ),
                                                      Container(width: 3),
                                                      document['read'] ==
                                                              widget.peerID
                                                          ? Icon(
                                                              Icons.done_all,
                                                              size: 17,
                                                              color:
                                                                  Colors.blue,
                                                            )
                                                          : Icon(
                                                              Icons.done_all,
                                                              size: 17,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          onPressed: () {
                                            _launchURL(
                                              document['content'],
                                            );
                                          },
                                          padding: EdgeInsets.all(0),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: isLastMessageRight(index)
                                              ? 20.0
                                              : 10.0,
                                          right: 10.0),
                                    )
                                  : document['type'] == 6
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: chatRightColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    20),
                                                            topRight:
                                                                Radius.circular(
                                                                    20))),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: PlayerWidget(
                                                          url: document[
                                                              'content']),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5,
                                                              bottom: 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            DateFormat(
                                                                    'hh:mm a')
                                                                .format(
                                                              DateTime.parse(
                                                                converTime(document[
                                                                    'timestamp']),
                                                              ),
                                                            ),
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12.0,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal),
                                                          ),
                                                          Container(width: 3),
                                                          document['read'] ==
                                                                  widget.peerID
                                                              ? Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  size: 17,
                                                                  color: Colors
                                                                      .blue,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  size: 17,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        )
                                      : document['type'] == 7
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: chatRightColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    bottom: 5,
                                                    left: 10),
                                                // ignore: deprecated_member_use
                                                child: FlatButton(
                                                  child: Material(
                                                    color: chatRightColor,
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[300],
                                                            child: Text(
                                                              document[
                                                                  'content'][0],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                        Container(
                                                          width: 10,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width: 120,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    document[
                                                                        'content'],
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        color: Colors.green[
                                                                            700],
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  Container(
                                                                    height: 3,
                                                                  ),
                                                                  Text(
                                                                    document[
                                                                        'contact'],
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    DateFormat(
                                                                            'hh:mm a')
                                                                        .format(
                                                                      DateTime
                                                                          .parse(
                                                                        converTime(
                                                                            document['timestamp']),
                                                                      ),
                                                                    ),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12.0,
                                                                        fontStyle:
                                                                            FontStyle.normal),
                                                                  ),
                                                                  Container(
                                                                      width: 3),
                                                                  document['read'] ==
                                                                          widget
                                                                              .peerID
                                                                      ? Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          size:
                                                                              17,
                                                                          color:
                                                                              Colors.blue,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          size:
                                                                              17,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                                  onPressed: () {},
                                                  padding: EdgeInsets.all(0),
                                                ),
                                              ),
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      isLastMessageRight(index)
                                                          ? 20.0
                                                          : 10.0,
                                                  right: 10.0),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                  color: chatRightColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    bottom: 10,
                                                    left: 10),
                                                // ignore: deprecated_member_use
                                                child: FlatButton(
                                                  child: Material(
                                                    color: chatRightColor,
                                                    child: Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child:
                                                              CachedNetworkImage(
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Container(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        appColorGreen),
                                                              ),
                                                              width: 70.0,
                                                              height: 70.0,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          70.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xffE8E8E8),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          8.0),
                                                                ),
                                                              ),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Material(
                                                              child: Text(
                                                                  "Not Avilable"),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    8.0),
                                                              ),
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                            ),
                                                            imageUrl: document[
                                                                'content'],
                                                            width: 70.0,
                                                            height: 70.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          height: 70,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                  height: 10),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 10),
                                                                  child:
                                                                      Container(
                                                                    width: 120,
                                                                    child: Text(
                                                                      "IMG_",
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          color: Colors.green[
                                                                              700],
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    DateFormat(
                                                                            'hh:mm a')
                                                                        .format(
                                                                      DateTime
                                                                          .parse(
                                                                        converTime(
                                                                            document['timestamp']),
                                                                      ),
                                                                    ),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12.0,
                                                                        fontStyle:
                                                                            FontStyle.normal),
                                                                  ),
                                                                  Container(
                                                                      width: 3),
                                                                  document['read'] ==
                                                                          widget
                                                                              .peerID
                                                                      ? Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          size:
                                                                              17,
                                                                          color:
                                                                              Colors.blue,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          size:
                                                                              17,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                  Container(
                                                                      width: 5),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                                  onPressed: () {
                                                    imagePreview(
                                                      document['content'],
                                                    );
                                                  },
                                                  padding: EdgeInsets.all(0),
                                                ),
                                              ),
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      isLastMessageRight(index)
                                                          ? 20.0
                                                          : 10.0,
                                                  right: 10.0),
                                            ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                ),
                // isLastMessageRight(index)
                //     ? Container(
                //         alignment: Alignment.centerRight,
                //         child: Text(
                //           format(
                //               DateTime.fromMillisecondsSinceEpoch(int.parse(
                //                 document['timestamp'],
                //               )),
                //               locale: 'en_short'),
                //           // DateFormat('dd MMM kk:mm').format(
                //           //     DateTime.fromMillisecondsSinceEpoch(
                //           //         int.parse(document['timestamp']))),
                //           style: TextStyle(
                //               color: Colors.black,
                //               fontSize: 12.0,
                //               fontStyle: FontStyle.normal),
                //         ),
                //         margin: EdgeInsets.only(right: 10.0),
                //       )
                //     : Container()
              ],
            );
    } else {
      return Container();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == widget.currentuser) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != widget.currentuser) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> onSendMessage(
    peerID2,
    peerName2,
    peerUrl2,
    String content,
    int type,
    String contact,
  ) async {
    // 0 = text
    // 1 = image
    // 2 = sticker
    // 4 = video
    // 5 = file
    // 6 = audio
    // 7 = contact
    int badgeCount = 0;
    print(content);
    print(content.trim());
    if (content.trim() != '') {
      textEditingController.clear();

      if (widget.currentuser.hashCode <= peerID2.hashCode) {
        groupChatId = widget.currentuser + "-" + peerID2;
      } else {
        groupChatId = peerID2 + "-" + widget.currentuser;
      }

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': widget.currentuser,
            'idTo': peerID2,
            'timestamp': FieldValue.serverTimestamp(),
            'content': content,
            'contact': contact,
            'type': type,
            "read": false,
            "delete": []
          },
        );
      }).then((onValue) async {
        await Firestore.instance
            .collection("chatList")
            .document(widget.currentuser)
            .collection(widget.currentuser)
            .document(peerID2)
            .setData({
          'id': peerID2,
          'name': peerName2,
          'timestamp': widget.pin != null && widget.pin.length > 0
              ? widget.pin
              : DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'badge': '0',
          'profileImage': peerUrl2,
          'type': type,
          'archive': false,
        }, merge: true).then((onValue) async {
          try {
            await Firestore.instance
                .collection("chatList")
                .document(peerID2)
                .collection(peerID2)
                .document(widget.currentuser)
                .get()
                .then((doc) async {
              debugPrint(doc.data["badge"]);
              if (doc.data["badge"] != null) {
                badgeCount = int.parse(doc.data["badge"]);
                await Firestore.instance
                    .collection("chatList")
                    .document(peerID2)
                    .collection(peerID2)
                    .document(widget.currentuser)
                    .setData({
                  'id': widget.currentuser,
                  'name': "${widget.currentusername}",
                  'timestamp': widget.pin != null && widget.pin.length > 0
                      ? widget.pin
                      : DateTime.now().millisecondsSinceEpoch.toString(),
                  'content': content,
                  'badge': '${badgeCount + 1}',
                  'profileImage': widget.currentuserimage,
                  'type': type,
                  'archive': false,
                }, merge: true);
              }
            });
          } catch (e) {
            await Firestore.instance
                .collection("chatList")
                .document(peerID2)
                .collection(peerID2)
                .document(widget.currentuser)
                .setData({
              'id': widget.currentuser,
              'name': "${widget.currentusername}",
              'timestamp': widget.pin != null && widget.pin.length > 0
                  ? widget.pin
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              'content': content,
              'badge': '${badgeCount + 1}',
              'profileImage': widget.currentuserimage,
              'type': type,
              'archive': false,
            }, merge: true);
            print(e);
          }
        });
      });

      // String notificationPayload =
      //     "{\"to\":\"${peerToken}\",\"priority\":\"high\",\"data\":{\"type\":\"100\",\"user_id\":\"${widget.currentuser}\",\"user_name\":\"${widget.currentusername}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"msg\":\"${content}\",\"time\":\"${DateTime.now().millisecondsSinceEpoch}\"},\"notification\":{\"title\":\"${widget.currentusername}\",\"body\":\"$content\",\"user_id\":\"${widget.currentuser}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"sound\":\"default\"},\"priority\":\"high\"}";
      // createNotification(notificationPayload);
      // listScrollController.animateTo(0.0,
      //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    } else {}
  }

  Widget buildInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Container(
        height: 60.0,
        width: deviceHeight,
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            record == false
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      padding: EdgeInsets.all(0.0),
                      onPressed: () {
                        _settingModalBottomSheet(context);
                      },
                      icon: Icon(
                        Icons.add,
                        color: appColorBlue,
                        size: 30,
                      ),
                    ),
                  )
                : Container(),
            record == false
                ? Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 0.0,
                      ),
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: appColorWhite,
                      ),
                      child: TextField(
                        controller: textEditingController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(65536),
                        ],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          border: InputBorder.none,
                          hintText: '',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: appColorGrey, width: 0.5),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: appColorGrey, width: 0.5),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: StreamBuilder<int>(
                      stream: _stopWatchTimer.rawTime,
                      initialData: _stopWatchTimer.rawTime.value,
                      builder: (context, snap) {
                        final value = snap.data;
                        final displayTime =
                            StopWatchTimer.getDisplayTime(value, hours: false);
                        return Text(
                          displayTime,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
            record == false
                ? IconButton(
                    onPressed: () {
                      createMessage(textEditingController.text, 0, '');
                    },
                    icon: Image.asset("assets/images/send.png"),
                    iconSize: 32.0,
                  )
                : Expanded(
                    child: InkWell(
                    onTap: () {
                      _cancle();
                    },
                    child: Text(
                      "Cancle",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  )),
            button == false
                ? GestureDetector(
                    onLongPress: () {
                      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);

                      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                      _start();
                    },
                    onLongPressUp: () {
                      _stop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Image.asset(
                        "assets/images/mic.png",
                        height: 25,
                        width: 30,
                        color: appColorBlue,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: IconButton(
                      onPressed: () async {
                        if (voiceRecording != null) {
                          setState(() {
                            button = false;
                            record = false;
                            isLoading = true;
                          });
                          filename = path.basename(voiceRecording.path);
                          final StorageReference postImageRef = FirebaseStorage
                              .instance
                              .ref()
                              .child("User Document");
                          var timeKey = new DateTime.now();
                          final StorageUploadTask uploadTask = postImageRef
                              .child(timeKey.toString())
                              .putFile(voiceRecording);
                          var fileUrl = await (await uploadTask.onComplete)
                              .ref
                              .getDownloadURL();
                          createMessage(fileUrl, 6, '');

                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      icon: Image.asset("assets/images/send.png"),
                      iconSize: 32.0,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.image),
                    title: new Text('Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      getImage();
                    }),
                ListTile(
                  leading: new Icon(Icons.video_call),
                  title: new Text('video library'),
                  onTap: () {
                    _pickVideo();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.attach_file),
                  title: new Text('Documents'),
                  onTap: () {
                    Navigator.pop(context);
                    _openFileExplorer();
                  },
                ),
                // new ListTile(
                //   leading: new Icon(Icons.location_on),
                //   title: new Text('Location'),
                //   onTap: () {},
                // ),
                // new ListTile(
                //   leading: new Icon(Icons.contacts),
                //   title: new Text('Contacts'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     showModalBottomSheet(
                //         context: context,
                //         shape: RoundedRectangleBorder(),
                //         isScrollControlled: true,
                //         backgroundColor: Colors.transparent,
                //         builder: (context) {
                //           return StatefulBuilder(builder:
                //               (BuildContext context, StateSetter setState1) {
                //             return DraggableScrollableSheet(
                //               initialChildSize: 0.6,
                //               builder: (BuildContext context,
                //                   ScrollController scrollController) {
                //                 return SingleChildScrollView(
                //                   controller: scrollController,
                //                   child: Container(
                //                     height: 1200,
                //                     decoration: BoxDecoration(
                //                       borderRadius: BorderRadius.only(
                //                         topLeft: Radius.circular(20.0),
                //                         topRight: Radius.circular(20.0),
                //                       ),
                //                       color: Colors.white,
                //                     ),
                //                     child: Column(
                //                       children: <Widget>[
                //                         Container(
                //                           decoration: BoxDecoration(
                //                             borderRadius: BorderRadius.only(
                //                               topLeft: Radius.circular(20.0),
                //                               topRight: Radius.circular(20.0),
                //                             ),
                //                           ),
                //                           height: 60,
                //                           child: Padding(
                //                             padding: const EdgeInsets.only(
                //                                 left: 15, right: 15, top: 5),
                //                             child: Row(
                //                               mainAxisAlignment:
                //                                   MainAxisAlignment
                //                                       .spaceBetween,
                //                               children: [
                //                                 InkWell(
                //                                     onTap: () {
                //                                       Navigator.pop(context);
                //                                     },
                //                                     child: Text(
                //                                       "Cancel",
                //                                       textAlign:
                //                                           TextAlign.start,
                //                                       style: TextStyle(
                //                                           color: Colors.green),
                //                                     )),
                //                                 Text(
                //                                   "Share Contacts",
                //                                   maxLines: 1,
                //                                   overflow:
                //                                       TextOverflow.ellipsis,
                //                                   textAlign: TextAlign.center,
                //                                   style: TextStyle(
                //                                       fontSize: 18,
                //                                       fontWeight:
                //                                           FontWeight.normal,
                //                                       fontStyle:
                //                                           FontStyle.normal,
                //                                       color: Colors.black),
                //                                 ),
                //                                 toSendname.length > 0
                //                                     ? InkWell(
                //                                         onTap: () {
                //                                           Navigator.pop(
                //                                               context);
                //                                           print(toSendname);
                //                                           print(toSendphone);
                //                                           for (var i = 0;
                //                                               i <=
                //                                                   toSendphone
                //                                                       .length;
                //                                               i++) {
                //                                             createMessage(
                //                                                 toSendname[i],
                //                                                 7,
                //                                                 toSendphone[i]);
                //                                           }
                //                                           setState1(() {
                //                                             toSendname.clear();
                //                                             toSendphone.clear();
                //                                           });
                //                                         },
                //                                         child: Text(
                //                                           "Send",
                //                                           textAlign:
                //                                               TextAlign.start,
                //                                           style: TextStyle(
                //                                               color:
                //                                                   Colors.green),
                //                                         ))
                //                                     : Padding(
                //                                         padding:
                //                                             const EdgeInsets
                //                                                     .only(
                //                                                 right: 15),
                //                                         child: Text("   "),
                //                                       ),
                //                               ],
                //                             ),
                //                           ),
                //                         ),
                //                         Expanded(
                //                             child: ListView.builder(
                //                           itemCount: _contacts.length,
                //                           itemBuilder: (BuildContext context,
                //                               int index) {
                //                             return _contacts != null
                //                                 ? Column(
                //                                     children: <Widget>[
                //                                       new Divider(
                //                                         height: 1,
                //                                       ),
                //                                       Row(
                //                                         children: [
                //                                           Expanded(
                //                                             child: new ListTile(
                //                                               onTap: () {},
                //                                               leading:
                //                                                   new Stack(
                //                                                 children: <
                //                                                     Widget>[
                //                                                   CircleAvatar(
                //                                                       backgroundColor:
                //                                                           Colors.grey[
                //                                                               300],
                //                                                       child:
                //                                                           Text(
                //                                                         _contacts[index]
                //                                                             .displayName[0],
                //                                                         style: TextStyle(
                //                                                             color: Colors
                //                                                                 .green,
                //                                                             fontSize:
                //                                                                 20,
                //                                                             fontWeight:
                //                                                                 FontWeight.bold),
                //                                                       )),
                //                                                 ],
                //                                               ),
                //                                               title: new Row(
                //                                                 mainAxisAlignment:
                //                                                     MainAxisAlignment
                //                                                         .spaceBetween,
                //                                                 children: <
                //                                                     Widget>[
                //                                                   new Text(
                //                                                     _contacts[index]
                //                                                             .displayName ??
                //                                                         "",
                //                                                     style: new TextStyle(
                //                                                         fontWeight:
                //                                                             FontWeight.bold),
                //                                                   ),
                //                                                 ],
                //                                               ),
                //                                               subtitle:
                //                                                   new Container(
                //                                                 padding:
                //                                                     const EdgeInsets
                //                                                             .only(
                //                                                         top:
                //                                                             5.0),
                //                                                 child: new Row(
                //                                                   children: [
                //                                                     Text(check[
                //                                                             index] ??
                //                                                         "")
                //                                                   ],
                //                                                 ),
                //                                               ),
                //                                             ),
                //                                           ),
                //                                           toSendphone.contains(
                //                                                   check[index])
                //                                               ? Padding(
                //                                                   padding: const EdgeInsets
                //                                                           .only(
                //                                                       right:
                //                                                           20),
                //                                                   child: InkWell(
                //                                                       onTap: () {
                //                                                         setState1(
                //                                                             () {
                //                                                           toSendphone
                //                                                               .remove(check[index]);
                //                                                           toSendname
                //                                                               .remove(_contacts[index].displayName);
                //                                                         });
                //                                                       },
                //                                                       child: Icon(Icons.check_circle)),
                //                                                 )
                //                                               : Padding(
                //                                                   padding: const EdgeInsets
                //                                                           .only(
                //                                                       right:
                //                                                           20),
                //                                                   child: InkWell(
                //                                                       onTap: () {
                //                                                         setState1(
                //                                                             () {
                //                                                           toSendphone
                //                                                               .add(check[index]);
                //                                                           toSendname
                //                                                               .add(_contacts[index].displayName);
                //                                                         });
                //                                                       },
                //                                                       child: Icon(Icons.radio_button_unchecked)),
                //                                                 )
                //                                         ],
                //                                       ),
                //                                     ],
                //                                   )
                //                                 : Container;
                //                           },
                //                         )),
                //                       ],
                //                     ),
                //                   ),
                //                 );
                //               },
                //             );
                //           });
                //         });
                //   },
                // ),
              ],
            ),
          );
        });
  }

  imagePreview(String url) {
    return showDialog(
      context: context,
      builder: (_) => Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 10, right: 10, bottom: 100),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                child: PhotoView(
                  imageProvider: NetworkImage(url),
                ),
              ),
            ),
          ),
          //buildFilterCloseButton(context),
        ],
      ),
    );
  }

  Widget buildFilterCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.black.withOpacity(0.0),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void createMessage(content, realType, realContact) {
    var documentReference1 = Firestore.instance
        .collection('broadcast')
        .document(widget.castId)
        .collection(widget.currentuser)
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference1,
        {
          'idFrom': widget.currentuser,
          'idTo': peerID,
          'timestamp': FieldValue.serverTimestamp(),
          'content': content,
          'contact': realContact,
          'type': realType,
          "read": false,
          "delete": []
        },
      );
    }).then((onValue) async {
      var msg = [];
      var type = [];
      var contact = [];

      for (var i = 0; i <= peerName.length; i++) {
        msg.add(content);
        type.add(realType);
        contact.add(realContact);
      }

      for (var i = 0; i <= peerName.length; i++) {
        onSendMessage(
            peerID[i], peerName[i], peerUrl[i], msg[i], type[i], contact[i]);
      }
    });
  }

  Future<http.Response> createNotification(String sendNotification) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
//          HttpHeaders.authorizationHeader:
//              "key=AAAAdlUezOQ:APA91bH9mRwxoUQujG3NGnkAmV0XFGW8zYGseKjPmLQOZqX9pcl4Zzm32qoNgBacwPvVPkRrH7auS6VGEDti558GpYAmiksVI0mPZf9N-ltZrKQQlh6TnTL5_tz3HdtRCso1hK1dqH2v"
      },
      body: sendNotification,
    );
    return response;
  }

  _start() async {
    try {
      if (running == false) {
        running = true;
      }
    } on Exception {}

    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          record = true;
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {}
  }

  _cancle() async {
    record = false;
    setState(() {
      button = false;
      record = false;
      record = false;
      // stopTimer();
    });
  }

  _stop() async {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    var result = await _recorder.stop();

    File file = widget.localFileSystem.file(result.path);

    voiceRecording = file;
    if (running == true)
      setState(() {
        running = false;
        button = true;
      });
  }

  // ignore: unused_element
  _resume() async {
    await _recorder.resume();
    setState(() {
      voiceRecording = null;
    });
  }

  // ignore: unused_element
  _pause() async {
    await _recorder.pause();
    setState(() {});
  }
}

// ignore: must_be_immutable
class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value * 60);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${(clockTimer.inSeconds.remainder(60) % 60).toString().padLeft(2, '0')}';

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: 110,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
