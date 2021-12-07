import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutterwhatsappclone/Screens/groupChat/groupinfo.dart';
import 'package:flutterwhatsappclone/Screens/videoPlayerScreen.dart';
import 'package:flutterwhatsappclone/Screens/videoView.dart';
import 'package:flutterwhatsappclone/Screens/widgets/player_widget.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/main.dart';
import 'package:flutterwhatsappclone/models/starModel.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_cropper/image_cropper.dart';
// import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:linkable/linkable.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutterwhatsappclone/Screens/viewImages.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:swipeable/swipeable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:file/local.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;
// import 'package:toast/toast.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutterwhatsappclone/Screens/saveContact.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterwhatsappclone/Screens/widgets/thumbnailImage.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';

import '../../story/editor.dart';

// ignore: must_be_immutable
class GroupChat extends StatefulWidget {
  LocalFileSystem localFileSystem;
  String peerID;
  String peerUrl;
  String peerName;
  String peerToken;
  String currentusername;
  String currentuserimage;
  String currentuser;
  bool archive;
  String pin;
  bool mute;

  GroupChat(
      {this.peerID,
      this.peerUrl,
      this.peerName,
      this.currentusername,
      this.currentuserimage,
      this.currentuser,
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

class _ChatState extends State<GroupChat> {
  final String peerID;
  final String peerUrl;
  final String peerName;

  _ChatState({@required this.peerID, this.peerUrl, @required this.peerName});
  final _scaffoldKey = GlobalKey<ScaffoldState>();
//RECORDER
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  // ignore: unused_field
  // Recording _recording = new Recording();
  // ignore: unused_field
  bool _isRecording = false;
  // ignore: unused_field
  TextEditingController _controller = new TextEditingController();

  bool record = false;
  bool running = false;
  bool button = false;
  File voiceRecording;
  int replyType = 0;

  // bool isDownloading = false;
  // String totalData = "0";

  //RECORDER

  // String groupChatId;
  var listMessage;
  File videoFile;
  VideoPlayerController _videoPlayerController;
  bool isLoading;
  String imageUrl;
  int limit = 20;
  String peerToken;
  String peerCode;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
    onChange: (value) => print(''),
    onChangeRawSecond: (value) => print(''),
    onChangeRawMinute: (value) => print(''),
  );

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

  var groupUsersId = [];

  bool isButtonEnabled = false;

  // ignore: unused_field
  DatabaseReference _messagesRef;

  // ignore: unused_field
  String _messageText = "Hello Message";

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool searchData = false;
  TextEditingController controller = new TextEditingController();
  List chatMsgList;
  // ignore: non_constant_identifier_names
  double HEIGHT = 96;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  String banner;
  var backImage = '';
  bool deleteButton = false;
  var deleteMsgTime = [];
  var deleteMsgID = [];
  FirebaseDatabase database = new FirebaseDatabase();
  // LocationResult _pickedLocation;
  bool replyButton = false;
  String replyMsg = '';
  String replyName = '';

  var imageMedia = [];
  var videoMedia = [];
  var docsMedia = [];

  bool internet = false;

  //Forward Message
  bool forwardButton = false;
  var forwardContent = [];
  var forwardTime = [];
  var forwardTypes = [];

  var forwardMsgId = [];
  var forwardMsgContent = [];
  var forwardMsgContact = [];
  var forwardMsgPeerName = [];
  var forwardMsgPeerImage = [];
  var forwardMsgType = [];
  //Forward Message

  //FOR GROUP
  var groupMsgId = [];
  var groupMsgUserId = [];
  var groupMsgContent = [];
  var groupMsgContact = [];
  var groupMsgPeerName = [];
  var groupMsgPeerImage = [];
  var groupMsgType = [];
  //FORWARD

  //VIDEO UPLOADING
  var videoSize = '';
  double _progress = 0;
  double percentage = 0;
  bool videoloader = false;
  String videoStatus = '';
  // ignore: unused_field
  GiphyGif _gif;
  final textFieldFocusNode = FocusNode();

  @override
  void initState() {
    _init();
    checkInternet();
    refreshContacts();
    print(userID);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
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

//    FirebaseAuth.instance.currentUser().then((user) {
//      print(user.uid);
//
//
//      userData = user.uid;
//
//
//    });

    // _callUserDataFromSharedPrefs();
    // getPeerToken();
    getIds();
    super.initState();

    // groupChatId = '';
    isLoading = false;

    imageUrl = '';

    // readLocal();
    removeBadge();
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

  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      internet = true;
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      internet = true;
      return true;
    } else {
      internet = false;
    }
    return false;
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
          check.add(c.phones.map((e) => e.value));
          print(check);
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
        createMessage(fileUrl, 5, '', '', '');
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

      createMessage(downloadUrl, 4, '', '', '');
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

  //EDIT IMAGE
  bool editImage = false;
  int _currentImage = 0;

  List<Asset> images = <Asset>[];
  List<File> allImages = [];

  Future<void> getImage() async {
    images = [];

    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      images.forEach((imageAsset) async {
        final filePath =
            await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);

        File tempFile = File(filePath);
        if (tempFile.existsSync()) {
          // sendImage(tempFile);
          if (allImages.contains(tempFile)) {
          } else {
            allImages.add(tempFile);
          }

          if (allImages.length > 0) {
            _currentImage = 0;
            editImage = true;
          }

          // allImages = [];
          // allImages.add(tempFile);
          // print(allImages);
          // print(allImages.length);
        }
      });

      print(error);
    });
  }

  getimageditor() {
    // ignore: unused_local_variable
    final geteditimage =
        Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditorPro(
        appBarColor: Colors.white,
        bottomBarColor: Colors.white,
        image: allImages[_currentImage],
      );
    })).then((geteditimage) {
      if (geteditimage != null) {
        setState(() {
          allImages[_currentImage] = geteditimage;
          if (allImages[_currentImage] != null) {
            // addPost(context, globalName, globalImage, _image);
          }
        });
      }
    }).catchError((er) {
      print(er);
    });
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: allImages[_currentImage].path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.grey,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      allImages[_currentImage] = croppedFile;
      setState(() {
        // state = AppState.cropped;
      });
    }
  }

  Widget editImageWidget() {
    final double height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
              initialPage: 0,
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImage = index;
                  print(_currentImage);
                });
              }
              // autoPlay: false,
              ),
          items: allImages
              .map((item) =>
                  Container(color: appColorWhite, child: Image.file(item)))
              .toList(),
        ),
        allImages.length > 1
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: allImages.map((url) {
                    int index = allImages.indexOf(url);

                    return Container(
                      width: 15.0,
                      height: 15.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImage == index
                            ? appColorBlue
                            : Colors.grey[500],
                      ),
                    );
                  }).toList(),
                ),
              )
            : Container(),
      ],
    );
  }

  Future sendImage(_image) async {
    // File _image;

    // final picker = ImagePicker();
    // final imageFile = await picker.getImage(source: ImageSource.gallery);

    // if (imageFile != null) {
    setState(() {
      isLoading = true;
      //  _image = File(imageFile.path);
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
        setState(() {
          isLoading = false;
          createMessage(imageUrl, 1, '', '', '');
        });
      }, onError: (err) {
        setState(() {
          isLoading = false;
        });
      });
    });
    //}
  }

  _pickVideo() async {
    setState(() {
      Navigator.pop(context);
    });

    final picker = ImagePicker();
    final imageFile = await picker.getVideo(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        if (imageFile != null) {
          videoFile = File(imageFile.path);
          addVideo(context);
        } else {
          print('No video selected.');
        }
      });
    }

    _videoPlayerController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        // _videoPlayerController.play();
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

        createMessage(downloadUrl, 4, '', '', '');
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

  removeBadge() async {
    await Firestore.instance
        .collection("chatList")
        .document(widget.currentuser)
        .collection(widget.currentuser)
        .document(peerID)
        .updateData({'badge': '0'});
  }

  // readMessage() async {
  //   await Firestore.instance
  //       .collection("messages")
  //       .document(widget.peerID)
  //       .collection(widget.peerID)
  //       .where("idTo", isEqualTo: widget.currentuser)
  //       .getDocuments()
  //       .then((querySnapshot) {
  //     querySnapshot.documents.forEach((documentSnapshot) {
  //       documentSnapshot.reference.updateData({'read': widget.currentuser});
  //     });
  //   });
  // }

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
    if (mounted)
      setState(() {
        isLoading = false;
        limit = limit + 20;
      });
  }

  // readLocal() {
  //   if (widget.currentuser.hashCode <= peerID.hashCode) {
  //     groupChatId = '${widget.currentuser}-$peerID';
  //   } else {
  //     groupChatId = '$peerID-${widget.currentuser}';
  //   }

  //   // Firestore.instance
  //   //     .collection('users')
  //   //     .document(widget.currentuser)
  //   //     .updateData({'chattingWith': peerID});

  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    listScrollController = new ScrollController()..addListener(_scrollListener);
    return Scaffold(
        key: _scaffoldKey,
        appBar: editImage == true
            ? AppBar(
                backgroundColor: Colors.white,
                title: Text(
                  "",
                  style: TextStyle(
                      fontFamily: "MontserratBold",
                      fontSize: 17,
                      color: Colors.black),
                ),
                centerTitle: true,
                leading: IconButton(
                    onPressed: () {
                      setState(() {
                        editImage = false;
                        allImages = [];
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                    )),
                actions: [
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        _cropImage();
                      },
                      icon: Icon(
                        Icons.crop,
                        color: Colors.black,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          getimageditor();
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.black,
                        )),
                  ),
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        allImages.forEach((send) async {
                          sendImage(send);
                        });
                        setState(() {
                          editImage = false;
                        });
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.black,
                      )),
                ],
              )
            : searchData == true
                ? AppBar(
                    title: Padding(
                        padding:
                            const EdgeInsets.only(top: 10, right: 0, left: 0),
                        child: Container(
                          decoration: new BoxDecoration(
                              color: Colors.green,
                              borderRadius: new BorderRadius.all(
                                Radius.circular(15.0),
                              )),
                          height: 40,
                          child: Center(
                            child: TextField(
                              controller: controller,
                              onChanged: onSearchTextChanged,
                              style: TextStyle(color: Colors.grey),
                              decoration: new InputDecoration(
                                border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.grey[200]),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(15.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.grey[200]),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(15.0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.grey[200]),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(15.0),
                                  ),
                                ),
                                filled: true,
                                hintStyle: new TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                                hintText: "Search",
                                contentPadding: EdgeInsets.only(top: 10.0),
                                fillColor: Colors.grey[200],
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[600],
                                  size: 25.0,
                                ),
                              ),
                            ),
                          ),
                        )),
                    centerTitle: false,
                    elevation: 1,
                    backgroundColor: appColorWhite,
                    automaticallyImplyLeading: false,
                    leading: null,
                    actions: <Widget>[
                      Container(
                        width: 50,
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: CustomText(
                            alignment: Alignment.center,
                            text: "Cancel",
                            color: appColorBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          onPressed: () {
                            setState(() {
                              controller.clear();
                              onSearchTextChanged("");
                              searchData = false;
                            });
                          },
                        ),
                      ),
                      Container(width: 15),
                    ],
                  )
                : AppBar(
                    centerTitle: false,
                    elevation: 1,
                    backgroundColor: appColorWhite,
                    title: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupInfo(
                                  groupName: widget.peerName,
                                  groupKey: widget.peerID,
                                  ids: groupUsersId,
                                  imageMedia: imageMedia,
                                  videoMedia: videoMedia,
                                  docsMedia: docsMedia)),
                        );
                      },
                      child: Container(
                        // height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10, top: 5, bottom: 5, left: 5),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: appColorBlue,
                                ),
                              ),
                            ),
                            peerUrl.length > 0
                                ? Container(
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
                                        placeholder: (context, url) =>
                                            Container(
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
                                        imageUrl: peerUrl,
                                        width: 30.0,
                                        height: 30.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ))
                                : Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        shape: BoxShape.circle),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Image.asset(
                                        "assets/images/groupuser.png",
                                        height: 10,
                                        color: Colors.white,
                                      ),
                                    )),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    peerName,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: appColorBlack,
                                        fontSize: 16.0,
                                        fontFamily: "MontserratBold"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    automaticallyImplyLeading: false,
                    // leading: false,
                    actions: <Widget>[
                      searchData == false
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      searchData = true;
                                    });
                                  },
                                  child: Image.asset(
                                    'assets/images/search.png',
                                    height: 25,
                                    width: 25,
                                    color: appColorBlue,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Container(
                        width: 15,
                      ),
                    ],
                  ),
        body: editImage == true
            ? editImageWidget()
            : Builder(
                builder: (context) => Stack(
                  children: [
                    Column(
                      children: <Widget>[
                        // List of messages

                        buildListMessage(),

                        // isDownloading == true
                        //     ? Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Padding(
                        //             padding: EdgeInsets.all(8),
                        //             child: new LinearPercentIndicator(
                        //               width: 300,
                        //               lineHeight: 20,
                        //               percent: double.parse(totalData) / 100,
                        //               center: Text(
                        //                 "${double.parse(totalData)}" + "%",
                        //                 style: new TextStyle(fontSize: 12.0),
                        //               ),
                        //               //trailing: Icon(Icons.mood),
                        //               linearStrokeCap: LinearStrokeCap.roundAll,
                        //               backgroundColor: Colors.grey[400],
                        //               progressColor: appColorBlue,
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     : Container(),

                        // Input content
                        // groupUsersId.contains(widget.currentuser)
                        //     ?
                        deleteButton == true
                            ? buildDeleteInput()
                            : forwardButton == true
                                ? buildForwardInput()
                                : buildInput()
                        //    : Container(),
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: isLoading == true
                          ? Center(child: loader())
                          : Container(),
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
            .collection('groupMessages')
            .document(widget.peerID)
            .collection(widget.peerID)
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
                  image: backImage.length > 0
                      ? DecorationImage(
                          image: NetworkImage(backImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1.0, 1.0), //(x,y)
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels <= HEIGHT) {
                          notifier.value = n.metrics.pixels;
                        }
                        return false;
                      },
                      child: _searchResult.length != 0 ||
                              controller.text.toLowerCase().isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.all(10.0),
                              itemCount: _searchResult.length,
                              reverse: true,
                              controller: listScrollController,
                              itemBuilder: (context, index) {
                                chatMsgList = snapshot.data.documents;

                                return buildItem(index, _searchResult[index]);
                              })
                          : ListView.builder(
                              padding: EdgeInsets.all(10.0),
                              itemCount: snapshot.data.documents.length,
                              reverse: true,
                              controller: listScrollController,
                              itemBuilder: (context, index) {
                                chatMsgList = snapshot.data.documents;
                                return buildItem(
                                    index, snapshot.data.documents[index]);
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ValueListenableBuilder<double>(
                        valueListenable: notifier,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, value - HEIGHT),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                banner != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        height: 35,
                                        // width: 120,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: Text(
                                                  DateFormat('EEEE, d MMM')
                                                      .format(DateTime.parse(
                                                          banner)),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ValueListenableBuilder<double>(
                        valueListenable: notifier,
                        builder: (context, value, child) {
                          // print("value" + value.toString());
                          return Transform.translate(
                              offset: Offset(0, 0),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 0, right: 0),
                                child: value < 1
                                    ? Container()
                                    : Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  topLeft:
                                                      Radius.circular(10))),
                                          height: 40,
                                          width: 40,
                                          child: IconButton(
                                            onPressed: () {
                                              listScrollController.animateTo(
                                                listScrollController
                                                    .position.minScrollExtent,
                                                duration: Duration(seconds: 1),
                                                curve: Curves.fastOutSlowIn,
                                              );
                                              setState(() {
                                                //  icon = false;
                                              });
                                            },
                                            icon: Icon(Icons.arrow_circle_down),
                                          ),
                                        ),
                                      ),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildDeleteInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Container(
        height: 50.0,
        width: deviceHeight,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          children: <Widget>[
            Container(width: 20),
            InkWell(
              onTap: () {
                openDeleteDialog(context);
              },
              child: Icon(
                Icons.delete,
                color: Colors.red,
                size: 25,
              ),
            ),
            Expanded(
                child: Text(
              deleteMsgTime.length.toString() + " " + "Selected",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )),
            InkWell(
              onTap: () {
                setState(() {
                  deleteButton = false;
                });
              },
              child: Text(
                "Done",
                style:
                    TextStyle(color: appColorBlue, fontWeight: FontWeight.bold),
              ),
            ),
            Container(width: 20),
          ],
        ),
      ),
    );
  }

  Widget buildForwardInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Container(
        height: 50.0,
        width: deviceHeight,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          children: <Widget>[
            Container(width: 20),
            InkWell(
                onTap: () {
                  setState(() {
                    forwardButton = false;
                  });
                  forwardMsg();
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(
                    Icons.reply,
                    color: Colors.black,
                    size: 25,
                  ),
                )),
            Expanded(
                child: Text(
              forwardContent.length.toString() + " " + "Selected",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )),
            InkWell(
              onTap: () {
                setState(() {
                  forwardButton = false;
                });
              },
              child: Text(
                "Done",
                style:
                    TextStyle(color: appColorBlue, fontWeight: FontWeight.bold),
              ),
            ),
            Container(width: 20),
          ],
        ),
      ),
    );
  }

  Future getImageFromCam() async {
    File _image;

    final picker = ImagePicker();
    final imageFile = await picker.getImage(source: ImageSource.camera);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
        _image = File(imageFile.path);
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
          setState(() {
            isLoading = false;
            createMessage(imageUrl, 1, '', '', '');
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
        });
      });
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['type'] == 1) {
      if (imageMedia.contains(document['content'])) {
      } else {
        imageMedia.add(document['content']);
      }
    }
    if (document['type'] == 4) {
      if (videoMedia.contains(document['content'])) {
      } else {
        videoMedia.add(document['content']);
      }
    }
    if (document['type'] == 5) {
      if (docsMedia.contains(document['content'])) {
      } else {
        docsMedia.add(document['content']);
      }
    }
    banner = converTime(document['timestamp']);
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
                            DateFormat('hh:mm a').format(
                              DateTime.parse(
                                converTime(document['timestamp']),
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
          : Swipeable(
              threshold: 60.0,
              onSwipeRight: () {
                setState(() {
                  replyMsg = document['content'];
                  replyType = document['type'];
                  replyName = "You";
                  replyButton = true;
                });
              },
              background: Container(),
              child: Row(
                children: [
                  deleteButton == true
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: deleteMsgTime.contains(document['timestamp'])
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      deleteMsgTime
                                          .remove(document['timestamp']);
                                      deleteMsgID.remove(document['idFrom']);
                                    });
                                  },
                                  child: Icon(
                                    Icons.check_circle,
                                    color: appColorBlue,
                                  ))
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      deleteMsgTime.add(document['timestamp']);
                                      deleteMsgID.add(document['idFrom']);
                                    });
                                  },
                                  child: Icon(
                                    Icons.radio_button_unchecked,
                                    color: appColorGrey,
                                  )),
                        )
                      : forwardButton == true
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: forwardTime.contains(document['timestamp'])
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          forwardTime
                                              .remove(document['timestamp']);
                                          forwardTypes.remove(document['type']);
                                          forwardContent
                                              .remove(document['content']);
                                        });
                                      },
                                      child: Icon(
                                        Icons.check_circle,
                                        color: appColorBlue,
                                      ))
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          forwardTime
                                              .add(document['timestamp']);
                                          forwardTypes.add(document['type']);
                                          forwardContent
                                              .add(document['content']);
                                        });
                                      },
                                      child: Icon(
                                        Icons.radio_button_unchecked,
                                        color: appColorGrey,
                                      )),
                            )
                          : Container(),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onLongPress: () {
                            replyMsg = document['content'];
                            replyType = document['type'];
                            replyName = "You";
                            openMessageBox(
                                document['star'] != null &&
                                        document['star'].length > 0
                                    ? document['star']
                                    : [],
                                document['timestamp'],
                                widget.peerID,
                                document['idFrom'],
                                document['content'],
                                document['idTo'],
                                document['type'],
                                document['contact']);
                          },
                          child: Row(
                            children: <Widget>[
                              // Text
                              document['type'] == 0
                                  ? myTextMessage(
                                      document['content'],
                                      document['star'],
                                      document['timestamp'],
                                      document['read'],
                                      index)
                                  : document['type'] == 9
                                      ? Column(
                                          children: [
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              chatReplyRightColor,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 15,
                                                                top: 8,
                                                                bottom: 8),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              document['lat'],
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                            ),
                                                            Text(
                                                              document['replyType'] !=
                                                                      null
                                                                  ? document['replyType'] ==
                                                                          1
                                                                      ? "📷 Photo"
                                                                      : document['replyType'] ==
                                                                              4
                                                                          ? "🎥 Video"
                                                                          : document['replyType'] == 5
                                                                              ? "📄 Document"
                                                                              : document['replyType'] == 6
                                                                                  ? "🔊 Audio"
                                                                                  : document['long']
                                                                  : document['long'],
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      700],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: Text(
                                                            document['content'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13),
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          document['star'] !=
                                                                      null &&
                                                                  document[
                                                                          'star']
                                                                      .contains(
                                                                          widget
                                                                              .currentuser)
                                                              ? Icon(
                                                                  Icons.star,
                                                                  size: 17,
                                                                )
                                                              : Container(),
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
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  10.0, 10.0, 15.0, 10.0),
                                              width: 230.0,
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
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      isLastMessageRight(index)
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
                                                          child: Container(
                                                            height: 70,
                                                            width: 70,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: FittedBox(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  child:
                                                                      VideoView(
                                                                    url: document[
                                                                        'content'],
                                                                    play:
                                                                        isInView,
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
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                  height: 10),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  width: 120,
                                                                  child: Center(
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "VIDEO_" +
                                                                              converTime(document['timestamp']).substring(converTime(document['timestamp']).length - 5).split('').reversed.join(''),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              color: Colors.green[700],
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        document['videoSize'] != null &&
                                                                                document['videoSize'].length > 0
                                                                            ? Text(
                                                                                "Size: " + document['videoSize'].toString(),
                                                                                textAlign: TextAlign.start,
                                                                                maxLines: 1,
                                                                                style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                                                                              )
                                                                            : Container(),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  document['star'] !=
                                                                              null &&
                                                                          document['star']
                                                                              .contains(widget.currentuser)
                                                                      ? Icon(
                                                                          Icons
                                                                              .star,
                                                                          size:
                                                                              17,
                                                                        )
                                                                      : Container(),
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
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SamplePlayer(
                                                                  url: document[
                                                                      'content'])),
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
                                            )
                                          : document['type'] == 5
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      color: chatRightColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              bottomLeft: Radius
                                                                  .circular(20),
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 10,
                                                            left: 10),
                                                    // ignore: deprecated_member_use
                                                    child: FlatButton(
                                                      child: Material(
                                                        color: chatRightColor,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10),
                                                              child: Row(
                                                                children: [
                                                                  ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                      child: Icon(
                                                                          Icons
                                                                              .note)),
                                                                  Container(
                                                                    width: 5,
                                                                  ),
                                                                  Container(
                                                                    width: 120,
                                                                    child: Text(
                                                                      "FILE_" +
                                                                          converTime(document['timestamp'])
                                                                              .substring(converTime(document['timestamp']).length - 5)
                                                                              .split('')
                                                                              .reversed
                                                                              .join(''),
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
                                                                  )
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
                                                                  document['star'] !=
                                                                              null &&
                                                                          document['star']
                                                                              .contains(widget.currentuser)
                                                                      ? Icon(
                                                                          Icons
                                                                              .star,
                                                                          size:
                                                                              17,
                                                                        )
                                                                      : Container(),
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
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8.0)),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                      ),
                                                      onPressed: () {
                                                        _launchURL(
                                                          document['content'],
                                                        );
                                                      },
                                                      padding:
                                                          EdgeInsets.all(0),
                                                    ),
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      bottom:
                                                          isLastMessageRight(
                                                                  index)
                                                              ? 20.0
                                                              : 10.0,
                                                      right: 10.0),
                                                )
                                              : document['type'] == 6
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10),
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    chatRightColor,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            20),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            20),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            20))),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 10),
                                                                  child: PlayerWidget(
                                                                      url: document[
                                                                          'content']),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right: 5,
                                                                      bottom:
                                                                          4),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      document['star'] != null &&
                                                                              document['star'].contains(widget.currentuser)
                                                                          ? Icon(
                                                                              Icons.star,
                                                                              size: 17,
                                                                            )
                                                                          : Container(),
                                                                      Text(
                                                                        DateFormat('hh:mm a')
                                                                            .format(
                                                                          DateTime
                                                                              .parse(
                                                                            converTime(document['timestamp']),
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
                                                                          width:
                                                                              3),
                                                                      document['read'] ==
                                                                              widget.peerID
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
                                                                ),
                                                              ],
                                                            )),
                                                      ),
                                                    )
                                                  : document['type'] == 7
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  chatRightColor,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20))),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 10,
                                                                    bottom: 5,
                                                                    left: 10),
                                                            // ignore: deprecated_member_use
                                                            child: FlatButton(
                                                              child: Material(
                                                                color:
                                                                    chatRightColor,
                                                                child: Row(
                                                                  children: [
                                                                    CircleAvatar(
                                                                        backgroundColor:
                                                                            Colors.grey[
                                                                                300],
                                                                        child:
                                                                            Text(
                                                                          document['content']
                                                                              [
                                                                              0],
                                                                          style: TextStyle(
                                                                              color: Colors.green,
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold),
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
                                                                          width:
                                                                              120,
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                document['content'],
                                                                                maxLines: 1,
                                                                                style: TextStyle(color: Colors.green[700], fontSize: 15, fontWeight: FontWeight.w500),
                                                                              ),
                                                                              Container(
                                                                                height: 3,
                                                                              ),
                                                                              Text(
                                                                                document['contact'],
                                                                                maxLines: 1,
                                                                                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(right: 5),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              document['star'] != null && document['star'].contains(widget.currentuser)
                                                                                  ? Icon(
                                                                                      Icons.star,
                                                                                      size: 17,
                                                                                    )
                                                                                  : Container(),
                                                                              Text(
                                                                                DateFormat('hh:mm a').format(
                                                                                  DateTime.parse(
                                                                                    converTime(document['timestamp']),
                                                                                  ),
                                                                                ),
                                                                                style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
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
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                                clipBehavior:
                                                                    Clip.hardEdge,
                                                              ),
                                                              onPressed: () {},
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                            ),
                                                          ),
                                                          margin: EdgeInsets.only(
                                                              bottom:
                                                                  isLastMessageRight(
                                                                          index)
                                                                      ? 20.0
                                                                      : 10.0,
                                                              right: 10.0),
                                                        )
                                                      : document['type'] == 8
                                                          ? Container(
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      chatRightColor,
                                                                  borderRadius: BorderRadius.only(
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
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            10),
                                                                // ignore: deprecated_member_use
                                                                child:
                                                                    // ignore: deprecated_member_use
                                                                    FlatButton(
                                                                  child:
                                                                      Material(
                                                                    color:
                                                                        chatRightColor,
                                                                    child: Row(
                                                                      children: [
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            placeholder: (context, url) =>
                                                                                Container(
                                                                              width: 30.0,
                                                                              height: 30.0,
                                                                              padding: EdgeInsets.all(0),
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0xffE8E8E8),
                                                                                borderRadius: BorderRadius.all(
                                                                                  Radius.circular(8.0),
                                                                                ),
                                                                              ),
                                                                              child: Center(
                                                                                child: CircularProgressIndicator(
                                                                                  valueColor: AlwaysStoppedAnimation<Color>(appColorBlue),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                Material(
                                                                              child: Text("Not Avilable"),
                                                                              borderRadius: BorderRadius.all(
                                                                                Radius.circular(8.0),
                                                                              ),
                                                                              clipBehavior: Clip.hardEdge,
                                                                            ),
                                                                            imageUrl:
                                                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSX2G4R17Q2SpAVqRDQNcRmHw_8y0uCk2PW4A&usqp=CAU",
                                                                            width:
                                                                                70.0,
                                                                            height:
                                                                                70.0,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              70,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              Container(height: 10),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(top: 10),
                                                                                  child: Container(
                                                                                    width: 120,
                                                                                    child: Text(
                                                                                      document['content'],
                                                                                      maxLines: 2,
                                                                                      style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w500),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  document['star'] != null && document['star'].contains(widget.currentuser)
                                                                                      ? Icon(
                                                                                          Icons.star,
                                                                                          size: 17,
                                                                                        )
                                                                                      : Container(),
                                                                                  Text(
                                                                                    DateFormat('hh:mm a').format(
                                                                                      DateTime.parse(
                                                                                        converTime(document['timestamp']),
                                                                                      ),
                                                                                    ),
                                                                                    style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
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
                                                                                  Container(width: 5),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8.0)),
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    MapsLauncher.launchCoordinates(
                                                                        double.parse(document[
                                                                            'lat']),
                                                                        double.parse(
                                                                            document['long']),
                                                                        'Location');
                                                                  },
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                ),
                                                              ),
                                                              margin: EdgeInsets.only(
                                                                  bottom: isLastMessageRight(
                                                                          index)
                                                                      ? 20.0
                                                                      : 10.0,
                                                                  right: 10.0),
                                                            )
                                                          : myImageMessage(
                                                              document[
                                                                  'content'],
                                                              document['star'],
                                                              document[
                                                                  'timestamp'],
                                                              document['read'],
                                                              index,
                                                              document[
                                                                  'fromName'])
                            ],
                            mainAxisAlignment: MainAxisAlignment.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
    } else {
      // Left (peer message)
      return Container(
        child: document['delete'].contains(widget.currentuser)
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                  child: Text(
                                "This message was deleted.",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12),
                              )),
                              Row(
                                children: [
                                  Text(
                                    DateFormat('hh:mm a').format(
                                      DateTime.parse(
                                        converTime(document['timestamp']),
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
                          padding: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 10.0),
                          width: 230.0,
                          decoration: BoxDecoration(
                              color: chatLeftColor,
                              //Color(0XFFc4d1ec),
                              // border: Border.all(color: Color(0xffE8E8E8)),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          margin: EdgeInsets.only(left: 10.0),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Swipeable(
                threshold: 60.0,
                onSwipeRight: () {
                  setState(() {
                    replyMsg = document['content'];
                    replyType = document['type'];
                    replyName = document['fromName'];
                    replyButton = true;
                  });
                },
                background: Container(),
                child: Row(
                  children: [
                    deleteButton == true
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: deleteMsgTime.contains(document['timestamp'])
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        deleteMsgTime
                                            .remove(document['timestamp']);
                                        deleteMsgID.remove(document['idFrom']);
                                      });
                                    },
                                    child: Icon(Icons.check_circle))
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        deleteMsgTime
                                            .add(document['timestamp']);
                                        deleteMsgID.add(document['idFrom']);
                                      });
                                    },
                                    child: Icon(Icons.radio_button_unchecked)),
                          )
                        : forwardButton == true
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: forwardTime
                                        .contains(document['timestamp'])
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            forwardTime
                                                .remove(document['timestamp']);
                                            forwardTypes
                                                .remove(document['type']);
                                            forwardContent
                                                .remove(document['content']);
                                          });
                                        },
                                        child: Icon(
                                          Icons.check_circle,
                                          color: appColorBlue,
                                        ))
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            forwardTime
                                                .add(document['timestamp']);
                                            forwardTypes.add(document['type']);
                                            forwardContent
                                                .add(document['content']);
                                          });
                                        },
                                        child: Icon(
                                          Icons.radio_button_unchecked,
                                          color: appColorGrey,
                                        )),
                              )
                            : Container(),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: InkWell(
                              onLongPress: () {
                                replyMsg = document['content'];
                                replyType = document['type'];
                                replyName = document['fromName'];
                                openMessageBox(
                                    document['star'] != null &&
                                            document['star'].length > 0
                                        ? document['star']
                                        : [],
                                    document['timestamp'],
                                    widget.peerID,
                                    document['idFrom'],
                                    document['content'],
                                    document['idTo'],
                                    document['type'],
                                    document['contact']);
                              },
                              child: Row(
                                children: <Widget>[
                                  document['type'] == 0
                                      ? peerTextMessage(
                                          document['content'],
                                          document['star'],
                                          document['timestamp'],
                                          document['read'],
                                          index,
                                          document['fromName'],
                                          document['fromContact'],
                                        )
                                      : document['type'] == 9
                                          ? Column(
                                              children: [
                                                Container(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          contactName(
                                                              document[
                                                                  'fromContact'],
                                                              document[
                                                                  'fromName']),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 5),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      300],
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            15,
                                                                        top: 8,
                                                                        bottom:
                                                                            8),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      document[
                                                                          'lat'],
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                    Text(
                                                                      document['replyType'] !=
                                                                              null
                                                                          ? document['replyType'] == 1
                                                                              ? "📷 Photo"
                                                                              : document['replyType'] == 4
                                                                                  ? "🎥 Video"
                                                                                  : document['replyType'] == 5
                                                                                      ? "📄 Document"
                                                                                      : document['replyType'] == 6
                                                                                          ? "🔊 Audio"
                                                                                          : document['long']
                                                                          : document['long'],
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          color: Colors.grey[
                                                                              700],
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                                  child: Text(
                                                                    document[
                                                                        'content'],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  document['star'] !=
                                                                              null &&
                                                                          document['star']
                                                                              .contains(widget.currentuser)
                                                                      ? Icon(
                                                                          Icons
                                                                              .star,
                                                                          size:
                                                                              17,
                                                                        )
                                                                      : Container(),
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
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  padding: EdgeInsets.fromLTRB(
                                                      10.0, 10.0, 15.0, 10.0),
                                                  width: 230.0,
                                                  decoration: BoxDecoration(
                                                      color: chatLeftColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20),
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  margin:
                                                      EdgeInsets.only(left: 0),
                                                ),
                                              ],
                                            )
                                          : document['type'] == 4
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      color: chatLeftColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20),
                                                              topRight: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 10,
                                                            left: 10),
                                                    // ignore: deprecated_member_use
                                                    child: FlatButton(
                                                      child: Material(
                                                        color: chatLeftColor,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                contactName(
                                                                    document[
                                                                        'fromContact'],
                                                                    document[
                                                                        'fromName']),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  child:
                                                                      Container(
                                                                    height: 70,
                                                                    width: 70,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      child: FittedBox(
                                                                          fit: BoxFit.cover,
                                                                          child: VideoView(
                                                                            url:
                                                                                document['content'],
                                                                            play:
                                                                                isInView,
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
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                          height:
                                                                              10),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                5,
                                                                            right:
                                                                                20),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Center(
                                                                              child: Text(
                                                                                "VIDEO_" + converTime(document['timestamp']).substring(converTime(document['timestamp']).length - 5).split('').reversed.join(''),
                                                                                textAlign: TextAlign.start,
                                                                                maxLines: 1,
                                                                                style: TextStyle(color: appColorBlue, fontSize: 12, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ),
                                                                            document['videoSize'] != null && document['videoSize'].length > 0
                                                                                ? Text(
                                                                                    "Size: " + document['videoSize'].toString(),
                                                                                    textAlign: TextAlign.start,
                                                                                    maxLines: 1,
                                                                                    style: TextStyle(color: appColorBlue, fontSize: 12, fontWeight: FontWeight.bold),
                                                                                  )
                                                                                : Container(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          document['star'] != null && document['star'].contains(widget.currentuser)
                                                                              ? Icon(
                                                                                  Icons.star,
                                                                                  size: 17,
                                                                                )
                                                                              : Container(),
                                                                          Text(
                                                                            DateFormat('hh:mm a').format(
                                                                              DateTime.parse(
                                                                                converTime(document['timestamp']),
                                                                              ),
                                                                            ),
                                                                            style: TextStyle(
                                                                                color: Colors.grey,
                                                                                fontSize: 12.0,
                                                                                fontStyle: FontStyle.normal),
                                                                          ),
                                                                          Container(
                                                                              width: 3),
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
                                                                          Container(
                                                                              width: 5),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8.0)),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SamplePlayer(
                                                                      url: document[
                                                                          'content'])),
                                                        );
                                                      },
                                                      padding:
                                                          EdgeInsets.all(0),
                                                    ),
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      bottom:
                                                          isLastMessageRight(
                                                                  index)
                                                              ? 5.0
                                                              : 10.0,
                                                      right: 10.0),
                                                )
                                              : document['type'] == 5
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                          color: chatLeftColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 10,
                                                                bottom: 10,
                                                                left: 10),
                                                        // ignore: deprecated_member_use
                                                        child: FlatButton(
                                                          child: Material(
                                                            color:
                                                                chatLeftColor,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    contactName(
                                                                        document[
                                                                            'fromContact'],
                                                                        document[
                                                                            'fromName']),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          ClipRRect(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              child: Icon(Icons.note)),
                                                                          Container(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                                120,
                                                                            child:
                                                                                Text(
                                                                              "FILE_" + converTime(document['timestamp']).substring(converTime(document['timestamp']).length - 5).split('').reversed.join(''),
                                                                              maxLines: 1,
                                                                              style: TextStyle(color: Colors.green[700], fontSize: 15, fontWeight: FontWeight.w500),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          right:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          document['star'] != null && document['star'].contains(widget.currentuser)
                                                                              ? Icon(
                                                                                  Icons.star,
                                                                                  size: 17,
                                                                                )
                                                                              : Container(),
                                                                          Text(
                                                                            DateFormat('hh:mm a').format(
                                                                              DateTime.parse(
                                                                                converTime(document['timestamp']),
                                                                              ),
                                                                            ),
                                                                            style: TextStyle(
                                                                                color: Colors.grey,
                                                                                fontSize: 12.0,
                                                                                fontStyle: FontStyle.normal),
                                                                          ),
                                                                          Container(
                                                                              width: 3),
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
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                            clipBehavior:
                                                                Clip.hardEdge,
                                                          ),
                                                          onPressed: () {
                                                            _launchURL(
                                                              document[
                                                                  'content'],
                                                            );
                                                          },
                                                          padding:
                                                              EdgeInsets.all(0),
                                                        ),
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          bottom:
                                                              isLastMessageRight(
                                                                      index)
                                                                  ? 0.0
                                                                  : 10.0,
                                                          right: 10.0),
                                                    )
                                                  : document['type'] == 6
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 0,
                                                                  bottom: 5),
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      chatLeftColor,
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              20),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              20),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              20))),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      contactName(
                                                                          document[
                                                                              'fromContact'],
                                                                          document[
                                                                              'fromName']),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 10),
                                                                        child: PlayerWidget(
                                                                            url:
                                                                                document['content']),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            right:
                                                                                5,
                                                                            bottom:
                                                                                4),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            document['star'] != null && document['star'].contains(widget.currentuser)
                                                                                ? Icon(
                                                                                    Icons.star,
                                                                                    size: 17,
                                                                                  )
                                                                                : Container(),
                                                                            Text(
                                                                              DateFormat('hh:mm a').format(
                                                                                DateTime.parse(
                                                                                  converTime(document['timestamp']),
                                                                                ),
                                                                              ),
                                                                              style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
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
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )),
                                                        )
                                                      : document['type'] == 7
                                                          ? Container(
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      chatLeftColor,
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              20),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              20),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              20))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            10),
                                                                // ignore: deprecated_member_use
                                                                child:
                                                                    // ignore: deprecated_member_use
                                                                    FlatButton(
                                                                  child:
                                                                      Material(
                                                                    color:
                                                                        chatLeftColor,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            contactName(document['fromContact'],
                                                                                document['fromName']),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            CircleAvatar(
                                                                                backgroundColor: Colors.grey[300],
                                                                                child: Text(
                                                                                  document['content'][0],
                                                                                  style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
                                                                                )),
                                                                            Container(
                                                                              width: 10,
                                                                            ),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Container(
                                                                                  width: 120,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        document['content'],
                                                                                        maxLines: 1,
                                                                                        style: TextStyle(color: Colors.green[700], fontSize: 15, fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                      Container(
                                                                                        height: 3,
                                                                                      ),
                                                                                      Text(
                                                                                        document['contact'],
                                                                                        maxLines: 1,
                                                                                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 5),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      document['star'] != null && document['star'].contains(widget.currentuser)
                                                                                          ? Icon(
                                                                                              Icons.star,
                                                                                              size: 17,
                                                                                            )
                                                                                          : Container(),
                                                                                      Text(
                                                                                        DateFormat('hh:mm a').format(
                                                                                          DateTime.parse(
                                                                                            converTime(document['timestamp']),
                                                                                          ),
                                                                                        ),
                                                                                        style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
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
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8.0)),
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                  ),
                                                                  onPressed:
                                                                      () {},
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                ),
                                                              ),
                                                              margin: EdgeInsets.only(
                                                                  bottom: isLastMessageRight(
                                                                          index)
                                                                      ? 0.0
                                                                      : 10.0,
                                                                  right: 10.0),
                                                            )
                                                          : document['type'] ==
                                                                  8
                                                              ? Container(
                                                                  decoration: BoxDecoration(
                                                                      color:
                                                                          chatLeftColor,
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              20),
                                                                          bottomRight: Radius.circular(
                                                                              20),
                                                                          topRight:
                                                                              Radius.circular(20))),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            15),
                                                                    child:
                                                                        // ignore: deprecated_member_use
                                                                        FlatButton(
                                                                      child:
                                                                          Material(
                                                                        color:
                                                                            chatLeftColor,
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                contactName(document['fromContact'], document['fromName']),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                  child: CachedNetworkImage(
                                                                                    placeholder: (context, url) => Container(
                                                                                      width: 30.0,
                                                                                      height: 30.0,
                                                                                      padding: EdgeInsets.all(0),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color(0xffE8E8E8),
                                                                                        borderRadius: BorderRadius.all(
                                                                                          Radius.circular(8.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: CircularProgressIndicator(
                                                                                          valueColor: AlwaysStoppedAnimation<Color>(appColorBlue),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    errorWidget: (context, url, error) => Material(
                                                                                      child: Text("Not Avilable"),
                                                                                      borderRadius: BorderRadius.all(
                                                                                        Radius.circular(8.0),
                                                                                      ),
                                                                                      clipBehavior: Clip.hardEdge,
                                                                                    ),
                                                                                    imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSX2G4R17Q2SpAVqRDQNcRmHw_8y0uCk2PW4A&usqp=CAU",
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
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    children: [
                                                                                      Container(height: 10),
                                                                                      Expanded(
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.only(top: 10),
                                                                                          child: Container(
                                                                                            width: 120,
                                                                                            child: Text(
                                                                                              document['content'],
                                                                                              maxLines: 2,
                                                                                              style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w500),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          document['star'] != null && document['star'].contains(widget.currentuser)
                                                                                              ? Icon(
                                                                                                  Icons.star,
                                                                                                  size: 17,
                                                                                                )
                                                                                              : Container(),
                                                                                          Text(
                                                                                            DateFormat('hh:mm a').format(
                                                                                              DateTime.parse(
                                                                                                converTime(document['timestamp']),
                                                                                              ),
                                                                                            ),
                                                                                            style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.normal),
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
                                                                                          Container(width: 5),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(8.0)),
                                                                        clipBehavior:
                                                                            Clip.hardEdge,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        MapsLauncher.launchCoordinates(
                                                                            double.parse(document['lat']),
                                                                            double.parse(document['long']),
                                                                            'Location');
                                                                      },
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                    ),
                                                                  ),
                                                                  margin: EdgeInsets.only(
                                                                      bottom: isLastMessageRight(
                                                                              index)
                                                                          ? 0.0
                                                                          : 10.0,
                                                                      right:
                                                                          10.0,
                                                                      left: 0),
                                                                )
                                                              : peerImageMessage(
                                                                  document[
                                                                      'content'],
                                                                  document[
                                                                      'star'],
                                                                  document[
                                                                      'timestamp'],
                                                                  document[
                                                                      'read'],
                                                                  index,
                                                                  document[
                                                                      'fromName'],
                                                                  document[
                                                                      'fromContact'],
                                                                )
                                ],
                              ),
                            ),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),
                  ],
                ),
              ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
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

  Widget myTextMessage(content, star, timestamp, read, index) {
    RegExp _numeric = RegExp(r'^-?[0-9]+$');
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        decoration: BoxDecoration(
            color: chatRightColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(20))),
        margin: EdgeInsets.only(
            bottom: isLastMessageRight(index) ? 10.0 : 10.0, right: 10.0),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  _numeric.hasMatch(content) && content.length >= 10
                      ? InkWell(
                          onTap: () {
                            launch('tel:$content');
                          },
                          child: Text(
                            content,
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontFamily: normalStyle,
                                fontSize: 14),
                          ),
                        )
                      : Linkable(
                          // onOpen: (link) async {
                          //   await launch(
                          //     link.url,
                          //   );
                          // },
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: normalStyle,
                              fontSize: 14),
                          text: content,
                        ),
                  Text(
                    converTime(timestamp),
                    style: TextStyle(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Row(
                children: [
                  star != null && star.contains(widget.currentuser)
                      ? Icon(
                          Icons.star,
                          size: 17,
                        )
                      : Container(),
                  Text(
                    DateFormat('hh:mm a').format(
                      DateTime.parse(
                        converTime(timestamp),
                      ),
                    ),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                        fontStyle: FontStyle.normal),
                  ),
                  Container(width: 3),
                  read == true
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
              right: 8.0,
              bottom: 4.0,
            )
          ],
        ),
      ),
    );
  }

  myImageMessage(content, star, timeStamp, read, index, fromName) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: chatRightColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
            child: Stack(
              children: [
                localImage.contains(content)
                    ? InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => ViewImages(
                          //           images: [content], number: index)),
                          // );
                          setState(() {
                            imageMedia.remove(content);
                            imageMedia.insert(0, content);
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewImages(images: imageMedia, number: 0)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              width: 30.0,
                              height: 30.0,
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      appColorBlue),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Center(child: Text("Not Avilable")),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: content,
                            width: 270.0,
                            height: 250.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: ProgressiveImage(
                          placeholder: AssetImage("assets/images/loading.gif"),
                          thumbnail: NetworkImage(content),
                          height: 250.0,
                          width: 270.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                Positioned(
                  right: 8.0,
                  bottom: 4.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      star != null && star.contains(widget.currentuser)
                          ? Icon(
                              Icons.star,
                              size: 17,
                            )
                          : Container(),
                      Text(
                        DateFormat('hh:mm a').format(
                          DateTime.parse(
                            converTime(timeStamp),
                          ),
                        ),
                        style: TextStyle(
                            color: appColorWhite,
                            fontSize: 12.0,
                            fontStyle: FontStyle.normal),
                      ),
                      Container(width: 3),
                      read == true
                          ? Icon(
                              Icons.done_all,
                              size: 17,
                              color: Colors.blue,
                            )
                          : Icon(
                              Icons.done_all,
                              size: 17,
                              color: appColorWhite,
                            ),
                      Container(width: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          margin: EdgeInsets.only(
              bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
        ),
        localImage.contains(content)
            ? Container()
            : Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[300], shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        download(content, 1);
                      },
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  peerTextMessage(
      content, star, timestamp, read, index, fromName, fromContact) {
    RegExp _numeric = RegExp(r'^-?[0-9]+$');
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        decoration: BoxDecoration(
            color: chatLeftColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20))),
        // margin: EdgeInsets.only(
        //     bottom: isLastMessageRight(index) ? 10.0 : 10.0, right: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contactName(fromContact, fromName),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     fromName,
            //     style: TextStyle(
            //         color: appColorGreen,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 13),
            //   ),
            // ),
            Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    children: <Widget>[
                      _numeric.hasMatch(content) && content.length >= 10
                          ? InkWell(
                              onTap: () {
                                launch('tel:$content');
                              },
                              child: Text(
                                content,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: normalStyle,
                                    fontSize: 14),
                              ),
                            )
                          : Linkable(
                              // onOpen: (link) async {
                              //   await launch(
                              //     link.url,
                              //   );
                              // },
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: normalStyle,
                                  fontSize: 14),
                              text: content,
                            ),
                      Text(
                        converTime(timestamp),
                        style: TextStyle(
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  child: Row(
                    children: [
                      star != null && star.contains(widget.currentuser)
                          ? Icon(
                              Icons.star,
                              size: 17,
                            )
                          : Container(),
                      Text(
                        DateFormat('hh:mm a').format(
                          DateTime.parse(
                            converTime(timestamp),
                          ),
                        ),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.normal),
                      ),
                    ],
                  ),
                  right: 8.0,
                  bottom: 4.0,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget contactName(fromContact, fromName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 20,
        alignment: Alignment.centerLeft,
        child: Text(
          fromName,
          textAlign: TextAlign.start,
          style: TextStyle(
              color: appColorBlue, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  peerImageMessage(
      content, star, timeStamp, read, index, fromName, fromContact) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: chatLeftColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                contactName(fromContact, fromName),
                Stack(
                  children: [
                    localImage.contains(content)
                        ? InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => ViewImages(
                              //           images: [content], number: index)),
                              // );
                              setState(() {
                                imageMedia.remove(content);
                                imageMedia.insert(0, content);
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewImages(
                                        images: imageMedia, number: 0)),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  width: 30.0,
                                  height: 30.0,
                                  padding: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          appColorBlue),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Center(child: Text("Not Avilable")),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: content,
                                width: 270.0,
                                height: 250.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: ProgressiveImage(
                              placeholder:
                                  AssetImage("assets/images/loading.gif"),
                              thumbnail: NetworkImage(content),
                              height: 250.0,
                              width: 270.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                    Positioned(
                      right: 8.0,
                      bottom: 4.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          star != null && star.contains(widget.currentuser)
                              ? Icon(
                                  Icons.star,
                                  size: 17,
                                )
                              : Container(),
                          Text(
                            DateFormat('hh:mm a').format(
                              DateTime.parse(
                                converTime(timeStamp),
                              ),
                            ),
                            style: TextStyle(
                                color: appColorWhite,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal),
                          ),
                          Container(width: 3),
                          read == true
                              ? Icon(
                                  Icons.done_all,
                                  size: 17,
                                  color: Colors.blue,
                                )
                              : Icon(
                                  Icons.done_all,
                                  size: 17,
                                  color: appColorWhite,
                                ),
                          Container(width: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          margin: EdgeInsets.only(
              bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
        ),
        localImage.contains(content)
            ? Container()
            : Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[300], shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        download(content, 1);
                      },
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  void createMessage(content, realType, realContact, String lat, String long) {
    // 0 = text
    // 1 = image
    // 2 = sticker
    // 4 = video
    // 5 = file
    // 6 = audio
    // 7 = contact
    // 8 = location
    if (internet == true) {
      if (content.trim() != '') {}
      textEditingController.clear();
      var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

      var documentReference = Firestore.instance
          .collection('groupMessages')
          .document(widget.peerID)
          .collection(widget.peerID)
          .document(timeStamp);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': widget.currentuser,
            'fromName': widget.currentusername,
            'fromContact': mobNo,
            'idTo': widget.peerID,
            'timestamp': FieldValue.serverTimestamp(),
            'content': content,
            'contact': realContact,
            'type': realType,
            "read": false,
            "delete": [],
            "lat": lat,
            "long": long,
            "replyType": replyType,
            "videoSize": videoSize
          },
        );
      }).then((onValue) async {
        var msg = [];
        var type = [];
        var contact = [];
        var time = [];

        for (var i = 0; i < groupUsersId.length; i++) {
          msg.add(content);
          type.add(realType);
          contact.add(realContact);
          time.add(timeStamp);
        }

        for (var i = 0; i < groupUsersId.length; i++) {
          onSendMessage(groupUsersId[i], msg[i], type[i], contact[i], time[i]);
        }
      });
    }
  }

  Future<void> onSendMessage(String groupIds, String content, int type,
      String contact, String time) async {
    setState(() {
      isButtonEnabled = false;
      if (type == 1) {
        localImage.add(content);
        preferences.setStringList("localImage", localImage);
      }
    });
    int badgeCount = 0;

    try {
      await Firestore.instance
          .collection("chatList")
          .document(groupIds)
          .collection(groupIds)
          .document(widget.peerID)
          .get()
          .then((doc) async {
        debugPrint(doc.data["badge"]);
        if (doc.data["badge"] != null) {
          badgeCount = int.parse(doc.data["badge"]);
          await Firestore.instance
              .collection("chatList")
              .document(groupIds)
              .collection(groupIds)
              .document(widget.peerID)
              .updateData({
            'timestamp':
                widget.pin != null && widget.pin.length > 0 ? widget.pin : time,
            'content': content,
            'badge': groupIds == widget.currentuser ? "0" : '${badgeCount + 1}',
            'type': type,
            'contact': contact,
          });
        }
      });
    } catch (e) {}
  }

  Widget buildInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 15),
      child: Container(
        width: deviceHeight,
        decoration: BoxDecoration(
            color: replyButton == true ? Colors.grey[300] : Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              replyButton == true
                  ? Padding(
                      padding:
                          const EdgeInsets.only(left: 30, right: 30, top: 20),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(replyName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appColorBlue)),
                              Container(
                                height: 5,
                              ),
                              SizedBox(
                                width: 250,
                                child: Text(replyMsg,
                                    maxLines: 2,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: 5,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Text(""),
                          ),
                          Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 1.3)),
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    replyButton = false;
                                  });
                                },
                              ))
                        ],
                      ),
                    )
                  : Container(),
              Row(
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
                            //height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: appColorWhite,
                            ),
                            child: TextField(
                              controller: textEditingController,
                              minLines: 1,
                              maxLines: 5,
                              focusNode: textFieldFocusNode,
                              keyboardType: TextInputType.multiline,
                              onChanged: (val) {
                                if ((val.length > 0)) {
                                  setState(() {
                                    isButtonEnabled = true;
                                  });
                                } else {
                                  setState(() {
                                    isButtonEnabled = false;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20),
                                border: InputBorder.none,
                                hintText: '',
                                hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                                // suffixIcon: GestureDetector(
                                //   onTap: () async {
                                //     setState(() {
                                //       textFieldFocusNode.unfocus();
                                //       textFieldFocusNode.canRequestFocus =
                                //           false;
                                //     });

                                //     GiphyGif gif = await GiphyGet.getGif(
                                //       context: context,
                                //       apiKey:
                                //           "QUnQNPmTehyhBAwPG7WuGCz4HLLZB0zQ", //YOUR API KEY HERE
                                //       lang: GiphyLanguage.spanish,
                                //     );

                                //     if (gif != null) {
                                //       setState(() {
                                //         // FocusScope.of(context).unfocus();
                                //         // SystemChannels.textInput.invokeMethod('TextInput.hide');
                                //         //  FocusScope.of(context).unfocus();
                                //         _gif = gif;
                                //         createMessage(gif.images.original.url,
                                //             1, '', '', '');
                                //         // onSendMessage(gif.images.original.url,
                                //         //     1, '', '', '', '');
                                //         print(gif.images.original.url);
                                //       });
                                //     }
                                //     // final gif = await GiphyPicker.pickGif(
                                //     //   context: context,
                                //     //   apiKey:
                                //     //       'QUnQNPmTehyhBAwPG7WuGCz4HLLZB0zQ',
                                //     //   fullScreenDialog: false,
                                //     //   previewType: GiphyPreviewType.previewWebp,
                                //     //   decorator: GiphyDecorator(
                                //     //     showAppBar: false,
                                //     //     searchElevation: 4,
                                //     //     giphyTheme: ThemeData.dark().copyWith(
                                //     //       inputDecorationTheme:
                                //     //           InputDecorationTheme(
                                //     //         border: InputBorder.none,
                                //     //         enabledBorder: InputBorder.none,
                                //     //         focusedBorder: InputBorder.none,
                                //     //         contentPadding: EdgeInsets.zero,
                                //     //       ),
                                //     //     ),
                                //     //   ),
                                //     // );
                                //   },
                                //   child: Container(
                                //     child: FittedBox(
                                //       alignment: Alignment.center,
                                //       fit: BoxFit.fitHeight,
                                //       child: IconTheme(
                                //         data: IconThemeData(),
                                //         child: Icon(
                                //           Icons.gif,
                                //           color: appColorBlue,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appColorGrey, width: 0.5),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appColorGrey, width: 0.5),
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
                              final displayTime = StopWatchTimer.getDisplayTime(
                                  value,
                                  hours: false,
                                  second: true,
                                  milliSecond: false,
                                  minute: true);
                              return Text(
                                displayTime,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                  record == false
                      ? isButtonEnabled == true
                          ? IconButton(
                              onPressed: () {
                                if (textEditingController.text.trim().length >
                                    0) {
                                  if (replyButton == true) {
                                    createMessage(textEditingController.text, 9,
                                        '', replyName, replyMsg);
                                    setState(() {
                                      replyButton = false;
                                    });
                                  } else {
                                    createMessage(textEditingController.text, 0,
                                        '', '', '');
                                  }
                                }
                              },
                              icon: Image.asset("assets/images/send.png"),
                              iconSize: 32.0,
                            )
                          : IconButton(
                              onPressed: () {
                                getImageFromCam();
                              },
                              icon: Image.asset("assets/images/camblue.png"),
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
                            _stopWatchTimer.onExecute
                                .add(StopWatchExecute.reset);

                            _stopWatchTimer.onExecute
                                .add(StopWatchExecute.start);
                            _start();
                          },
                          onLongPressUp: () {
                            _stop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Image.asset(
                              "assets/images/mic.png",
                              height: 26,
                              width: 26,
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
                                final StorageReference postImageRef =
                                    FirebaseStorage.instance
                                        .ref()
                                        .child("User Document");
                                var timeKey = new DateTime.now();
                                final StorageUploadTask uploadTask =
                                    postImageRef
                                        .child(timeKey.toString())
                                        .putFile(voiceRecording);
                                var fileUrl =
                                    await (await uploadTask.onComplete)
                                        .ref
                                        .getDownloadURL();
                                createMessage(fileUrl, 6, '', '', '');
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
            ],
          ),
        ),
      ),
    );
  }

  openMessageBox(
      star, time, groupChatId, idFrom, content, idTo, type, contact) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  star.contains(widget.currentuser)
                      ? InkWell(
                          onTap: () {
                            var data = [];
                            data.addAll(star);
                            data.remove(widget.currentuser);
                            print('>>>>>>>>>>');
                            print(data);
                            Firestore.instance
                                .collection('groupMessages')
                                .document(groupChatId)
                                .collection(groupChatId)
                                .where("timestamp", isEqualTo: time)
                                .getDocuments()
                                .then((querySnapshot) {
                              querySnapshot.documents
                                  .forEach((documentSnapshot) {
                                documentSnapshot.reference
                                    .updateData({"star": data}).then((value) {
                                  database
                                      .reference()
                                      .child("star")
                                      .child(time + widget.currentuser)
                                      .remove()
                                      .then((_) {});
                                });
                              });
                            });
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Unstar",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(child: Text("")),
                                Icon(
                                  Icons.star,
                                  color: Colors.black,
                                  size: 25,
                                )
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            star.add(widget.currentuser);
                            Firestore.instance
                                .collection('groupMessages')
                                .document(groupChatId)
                                .collection(groupChatId)
                                .where("timestamp", isEqualTo: time)
                                .getDocuments()
                                .then((querySnapshot) {
                              querySnapshot.documents
                                  .forEach((documentSnapshot) {
                                documentSnapshot.reference
                                    .updateData({"star": star}).then((value) {
                                  database
                                      .reference()
                                      .child('user')
                                      .child(idFrom)
                                      .once()
                                      .then((peerData) {
                                    StarModel model = new StarModel(
                                        widget.currentuser,
                                        peerData.value['name'],
                                        idFrom,
                                        idTo,
                                        peerData.value['img'],
                                        content,
                                        time,
                                        type.toString());

                                    var orderRef = database
                                        .reference()
                                        .child("star")
                                        .child(time + widget.currentuser);
                                    orderRef
                                        .set(model.toJson())
                                        .then((value) async {});
                                  });
                                });
                              });
                            });
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Star",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(child: Text("")),
                                Icon(
                                  Icons.star_outline,
                                  color: Colors.black,
                                  size: 25,
                                )
                              ],
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        replyButton = true;
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Reply",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text("")),
                          Icon(
                            Icons.reply,
                            color: Colors.black,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);

                      setState(() {
                        forwardButton = true;
                        forwardContent = [];
                        forwardTime = [];
                        forwardTypes = [];
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Forward",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text("")),
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: Icon(
                              Icons.reply,
                              color: Colors.black,
                              size: 25,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Clipboard.setData(new ClipboardData(text: content));
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Copy",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text("")),
                          Icon(
                            Icons.copy,
                            color: Colors.black,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  type == 1 || type == 4 || type == 5 || type == 7
                      ? Divider(
                          color: Colors.grey,
                          height: 4.0,
                        )
                      : Container(),
                  type == 1 || type == 4 || type == 5 || type == 7
                      ? InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            if (type == 7) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SaveContact(
                                        name: content, phone: contact)),
                              );
                            } else {
                              download(content, type);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Save",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(child: Text("")),
                                Icon(
                                  Icons.file_download,
                                  color: Colors.black,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        deleteMsgTime.clear();
                        deleteButton = true;
                        deleteMsgID.clear();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Delete",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text("")),
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
            ),
          );
        });
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
                new ListTile(
                  leading: new Icon(Icons.sticky_note_2_rounded),
                  title: new Text('GIF'),
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() {
                      textFieldFocusNode.unfocus();
                      textFieldFocusNode.canRequestFocus = false;
                    });

                    GiphyGif gif = await GiphyGet.getGif(
                      context: context,
                      apiKey:
                          "QUnQNPmTehyhBAwPG7WuGCz4HLLZB0zQ", //YOUR API KEY HERE
                      lang: GiphyLanguage.spanish,
                    );

                    if (gif != null) {
                      setState(() {
                        // FocusScope.of(context).unfocus();
                        // SystemChannels.textInput.invokeMethod('TextInput.hide');
                        //  FocusScope.of(context).unfocus();
                        _gif = gif;
                        createMessage(gif.images.original.url, 1, '', '', '');
                        // onSendMessage(gif.images.original.url,
                        //     1, '', '', '', '');
                        print(gif.images.original.url);
                      });
                    }
                    // final gif = await GiphyPicker.pickGif(
                    //   context: context,
                    //   apiKey:
                    //       'QUnQNPmTehyhBAwPG7WuGCz4HLLZB0zQ',
                    //   fullScreenDialog: false,
                    //   previewType: GiphyPreviewType.previewWebp,
                    //   decorator: GiphyDecorator(
                    //     showAppBar: false,
                    //     searchElevation: 4,
                    //     giphyTheme: ThemeData.dark().copyWith(
                    //       inputDecorationTheme:
                    //           InputDecorationTheme(
                    //         border: InputBorder.none,
                    //         enabledBorder: InputBorder.none,
                    //         focusedBorder: InputBorder.none,
                    //         contentPadding: EdgeInsets.zero,
                    //       ),
                    //     ),
                    //   ),
                    // );
                  },
                ),
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
                new ListTile(
                  leading: new Icon(Icons.location_on),
                  title: new Text('Location'),
                  onTap: () async {
                    String _pickedLocation = '';
                    Navigator.pop(context);
                    LocationResult result =
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PlacePicker(
                                  "AIzaSyCqQW9tN814NYD_MdsLIb35HRY65hHomco",
                                )));

                    setState(() {
                      _pickedLocation = result.formattedAddress.toString();
                    });
                    if (_pickedLocation.length > 0) {
                      createMessage(
                        result.formattedAddress.toString(),
                        8,
                        '',
                        result.latLng.latitude.toString(),
                        result.latLng.longitude.toString(),
                      );
                    }
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.contacts),
                  title: new Text('Contacts'),
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState1) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.6,
                              builder: (BuildContext context,
                                  ScrollController scrollController) {
                                return Container(
                                  height: SizeConfig.screenHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                        ),
                                        height: 60,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15, top: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Cancel",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                  )),
                                              Text(
                                                "Share Contacts",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle: FontStyle.normal,
                                                    color: Colors.black),
                                              ),
                                              toSendname.length > 0
                                                  ? InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        print(toSendname);
                                                        print(toSendphone);
                                                        for (var i = 0;
                                                            i <=
                                                                toSendphone
                                                                    .length;
                                                            i++) {
                                                          createMessage(
                                                              toSendname[i],
                                                              7,
                                                              toSendphone[i],
                                                              '',
                                                              '');
                                                        }
                                                        toSendname.clear();
                                                        toSendphone.clear();
                                                      },
                                                      child: Text(
                                                        "Send",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green),
                                                      ))
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 15),
                                                      child: Text("   "),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: ListView.builder(
                                        itemCount: _contacts.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return _contacts != null
                                              ? Column(
                                                  children: <Widget>[
                                                    new Divider(
                                                      height: 1,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: new ListTile(
                                                            onTap: () {},
                                                            leading: new Stack(
                                                              children: <
                                                                  Widget>[
                                                                CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors.grey[
                                                                            300],
                                                                    child: Text(
                                                                      // _contacts[index]
                                                                      //     .displayName[0],
                                                                      "?",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .green,
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )),
                                                              ],
                                                            ),
                                                            title: new Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                new Text(
                                                                  _contacts[index]
                                                                          .displayName ??
                                                                      "",
                                                                  style: new TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                            subtitle:
                                                                new Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 5.0),
                                                              child: new Row(
                                                                children: [
                                                                  Text(check[index]
                                                                          .toString() ??
                                                                      "")
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        toSendphone.contains(
                                                                check[index]
                                                                    .toString())
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            20),
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      setState1(
                                                                          () {
                                                                        toSendphone
                                                                            .remove(check[index].toString());
                                                                        toSendname
                                                                            .remove(_contacts[index].displayName);
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .check_circle)),
                                                              )
                                                            : Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            20),
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      setState1(
                                                                          () {
                                                                        toSendphone
                                                                            .add(check[index].toString());
                                                                        toSendname
                                                                            .add(_contacts[index].displayName);
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .radio_button_unchecked)),
                                                              )
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : Container;
                                        },
                                      )),
                                    ],
                                  ),
                                );
                              },
                            );
                          });
                        });
                  },
                ),
              ],
            ),
          );
        });
  }

  // imagePreview(String url) {
  //   return showDialog(
  //     context: context,
  //     builder: (_) => Stack(
  //       alignment: Alignment.topCenter,
  //       children: <Widget>[
  //         Padding(
  //           padding: const EdgeInsets.only(
  //               top: 100, left: 10, right: 10, bottom: 100),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(10),
  //             child: Container(
  //               child: PhotoView(
  //                 imageProvider: NetworkImage(url),
  //               ),
  //             ),
  //           ),
  //         ),
  //         //buildFilterCloseButton(context),
  //       ],
  //     ),
  //   );
  // }

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

  createDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Wybierz miasto'),
            content: Container(
              height: 200.0,
              width: 400.0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text("Test Dialog"),
                    onTap: () => {},
                  );
                },
              ),
            ),
          );
        });
  }

  // static String avtar =
  //     "https://firebasestorage.googleapis.com/v0/b/tinfit-primocy.appspot.com/o/profile%2F1577811368705.jpg?alt=media&token=0055056b-699e-498e-a85b-9df859ea462c";
  // static String peerDeviceToken =
  //     "fW-Nc061a9E:APA91bF7zpr0F6atTXoPXcNF7euy6yKRSkgq9RlRY3kJjcIQ4LLCOeCqTkqLgHfQ8i-Sb8W4YyVJhHPXj1dNpUdhRv1JDk_LnFjr8PyxBFqxab70UjPCAqRJVZndK2GR1WljELjs9o5Y";

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

  // Future<http.Response> sendNotification(
  //     String peerToken, String content) async {
  //   final response = await http.post(
  //     'https://fcm.googleapis.com/fcm/send',
  //     headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json',
  //       HttpHeaders.authorizationHeader:
  //           "key=AAAAqBAe6sM:APA91bFvIoDXPP3uVXlppAtsLC_nCRpPG5Xg8V2cHQCbGVBXFiBch_Kvocx-mvdq3rBknufGY1IecIQY_tRYOCNKptWMc70t90nGOaz_HS3jqux2ALLTn0LtUmt4tkiYHEThBw0VKn_m"
  //     },
  //     body:
  //     jsonEncode({
  //       "to": peerToken,
  //       "priority": "high",
  //       "data": {
  //         "type": "100",
  //         "user_id": userData['uid'],
  //         "title": content,
  //         "user_pic": userData['profileImage'],
  //         "message": userData['name'],
  //         "time": DateTime.now().millisecondsSinceEpoch,
  //         "sound": "default",
  //         "vibrate": "300",
  //       },
  //       "notification": {
  //         "vibrate": "300",
  //         "priority": "high",
  //         "body": content,
  //         "title": userData['name'],
  //         "sound": "default",
  //       }
  //     }),
  //   );
  //   return response;
  // }

  // getPeerToken() async {
  //   final FirebaseDatabase database = new FirebaseDatabase();

  //   database
  //       .reference()
  //       .child('user')
  //       .child(peerID)
  //       .orderByChild("token")
  //       .once()
  //       .then((peerData) {
  //     print('Connected to the database and read ${peerData.value["token"]}');

  //     peerToken = peerData.value['token'];
  //   });
  // }

  getIds() async {
    final FirebaseDatabase database = new FirebaseDatabase();

    database
        .reference()
        .child('user')
        .child(widget.currentuser)
        .orderByChild("bio")
        .once()
        .then((data) {
      backImage = data.value['bio'];
    });

    database
        .reference()
        .child('group')
        .child(widget.peerID)
        .orderByChild("userId")
        .once()
        .then((peerData) {
      groupUsersId = peerData.value['userId'];
      print("groupUsersId>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    chatMsgList.forEach((userDetail) {
      print(userDetail['content'].toString());
      // for (int i = 0; i < chatList.length; i++) {
      if (userDetail['content'].toLowerCase().contains(text.toLowerCase())
          // ||chatList[i]['name'].toLowerCase().contains(text.toLowerCase())
          ) _searchResult.add(userDetail);
      // }
    });

    // user.forEach((userDetail) {
    //   if (userDetail.content.contains(text.toLowerCase()))
    //     _searchResult.add(userDetail);
    // });

    setState(() {});
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

  openDeleteDialog(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Delete For Everyone",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("Discard");

              var newgroupUsersId = [];
              newgroupUsersId.addAll(groupUsersId);
              newgroupUsersId.add(widget.currentuser);
              setState(() {
                deleteButton = false;
              });

              for (var i = 0; i <= deleteMsgTime.length; i++) {
                Firestore.instance
                    .collection('groupMessages')
                    .document(widget.peerID)
                    .collection(widget.peerID)
                    .where("timestamp", isEqualTo: deleteMsgTime[i])
                    .getDocuments()
                    .then((querySnapshot) {
                  querySnapshot.documents.forEach((documentSnapshot) {
                    documentSnapshot.reference.updateData(
                        {"delete": FieldValue.arrayUnion(newgroupUsersId)});
                  });
                });

                await Firestore.instance
                    .collection("chatList")
                    .document(groupUsersId[i])
                    .collection(groupUsersId[i])
                    .document(widget.peerID)
                    .get()
                    .then((doc) async {
                  if (deleteMsgTime[i] == doc.data["timestamp"]) {
                    for (i = 0; i <= newgroupUsersId.length; i++) {
                      await Firestore.instance
                          .collection("chatList")
                          .document(newgroupUsersId[i])
                          .collection(newgroupUsersId[i])
                          .document(widget.peerID)
                          .updateData({'content': "This message was deleted"});
                    }
                  }
                }).then((value) async {
                  // await Firestore.instance
                  //     .collection("chatList")
                  //     .document(groupUsersId[i])
                  //     .collection(groupUsersId[i])
                  //     .document(widget.peerID)
                  //     .updateData({'content': "This message was deleted"});
                });
              }
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Delete For Me",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");

              var newgroupUsersId = [];
              // newgroupUsersId.addAll(groupUsersId);
              newgroupUsersId.add(widget.currentuser);
              setState(() {
                deleteButton = false;
              });

              for (var i = 0; i <= deleteMsgTime.length; i++) {
                Firestore.instance
                    .collection('groupMessages')
                    .document(widget.peerID)
                    .collection(widget.peerID)
                    .where("timestamp", isEqualTo: deleteMsgTime[i])
                    .getDocuments()
                    .then((querySnapshot) {
                  querySnapshot.documents.forEach((documentSnapshot) {
                    documentSnapshot.reference.updateData(
                        {"delete": FieldValue.arrayUnion(newgroupUsersId)});
                  });
                });
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontFamily: "MontserratBold"),
          ),
          isDefaultAction: true,
          onPressed: () {
            // Navigator.pop(context, 'Cancel');
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  forwardMsg() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState1) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  height: SizeConfig.screenHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: appColorBlue),
                                  )),
                              Text(
                                "Forward",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black),
                              ),
                              // forwardMsgId.length > 0
                              //     ?
                              InkWell(
                                  onTap: () {
                                    for (var p = 0;
                                        p < forwardTime.length;
                                        p++) {
                                      //GROUP ============================================================>
                                      print(groupMsgId);
                                      groupMsgContent = [];
                                      groupMsgType = [];
                                      groupMsgContact = [];

                                      for (var i = 0;
                                          i < groupMsgId.length;
                                          i++) {
                                        groupMsgContent.add(forwardContent[p]);
                                        groupMsgType.add(forwardTypes[p]);
                                        groupMsgContact.add("");
                                      }

                                      for (var i = 0;
                                          i < groupMsgId.length;
                                          i++) {
                                        onForwardGroup(
                                            groupMsgUserId[i],
                                            groupMsgId[i],
                                            groupMsgPeerName[i],
                                            groupMsgPeerImage[i],
                                            groupMsgContent[i],
                                            groupMsgType[i],
                                            groupMsgContact[i]);
                                      }
                                      // <======================================== GROUP

                                      forwardMsgContent = [];
                                      forwardMsgType = [];
                                      forwardMsgContact = [];
                                      Navigator.pop(context);

                                      for (var i = 0;
                                          i < forwardMsgId.length;
                                          i++) {
                                        forwardMsgContent
                                            .add(forwardContent[p]);
                                        forwardMsgType.add(forwardTypes[p]);
                                        forwardMsgContact.add("");
                                      }

                                      for (var i = 0;
                                          i < forwardMsgId.length;
                                          i++) {
                                        onForward(
                                            forwardMsgId[i],
                                            forwardMsgPeerName[i],
                                            forwardMsgPeerImage[i],
                                            forwardMsgContent[i],
                                            forwardMsgType[i],
                                            forwardMsgContact[i]);
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      "Send",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ))
                              // : Padding(
                              //     padding: const EdgeInsets.only(right: 15),
                              //     child: Text("       "),
                              //   ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomScrollView(
                          primary: true,
                          shrinkWrap: false,
                          slivers: <Widget>[
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  forwardGroupsWidget(setState1),
                                  forwardUsersWidget(setState1),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          });
        });
  }

  Widget forwardUsersWidget(setState1) {
    return FutureBuilder(
      future: FirebaseDatabase.instance.reference().child("user").once(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var lists = [];
          Map<dynamic, dynamic> values = snapshot.data.value;
          values.forEach((key, values) {
            lists.add(values);
          });
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: lists.length,
            itemBuilder: (BuildContext context, int index) {
              return mobileContacts.contains(lists[index]["mobile"]) &&
                      widget.currentuser != lists[index]["userId"]
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              new Divider(
                                height: 1,
                              ),
                              new ListTile(
                                onTap: () {},
                                leading: new Stack(
                                  children: <Widget>[
                                    (lists[index]["img"] != null &&
                                            lists[index]["img"].length > 0)
                                        ? CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            backgroundImage: new NetworkImage(
                                                lists[index]["img"]),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.grey[300],
                                            child: Text(
                                              "",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                  ],
                                ),
                                title: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    savedContactUserId.contains(
                                                lists[index]["userId"]) &&
                                            allcontacts != null
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              for (var i = 0;
                                                  i < allcontacts.length;
                                                  i++)
                                                Text(
                                                  allcontacts[i]
                                                          .phones
                                                          .map((e) => e.value)
                                                          .toString()
                                                          .replaceAll(
                                                              new RegExp(
                                                                  r"\s+\b|\b\s"),
                                                              "")
                                                          .contains(lists[index]
                                                              ["mobile"])
                                                      ? allcontacts[i]
                                                          .displayName
                                                      : "",
                                                  style: new TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                            ],
                                          )
                                        : Text(
                                            lists[index]["mobile"],
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                    // new Text(
                                    //   lists[index]["name"] ?? "",
                                    //   style: new TextStyle(
                                    //       fontWeight: FontWeight.bold),
                                    // ),
                                  ],
                                ),
                                subtitle: new Container(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: new Row(
                                    children: [
                                      Text(lists[index]["mobile"])
                                      // ItemsTile(c.phones),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        forwardMsgId.contains(lists[index]["userId"])
                            ? InkWell(
                                onTap: () {},
                                child: IconButton(
                                  onPressed: () {
                                    setState1(() {
                                      forwardMsgId
                                          .remove(lists[index]["userId"]);
                                      forwardMsgPeerName
                                          .remove(lists[index]["name"]);
                                      forwardMsgPeerImage
                                          .remove(lists[index]["img"]);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: appColorBlue,
                                    size: 28,
                                  ),
                                ))
                            : IconButton(
                                onPressed: () {
                                  setState1(() {
                                    forwardMsgId.add(lists[index]["userId"]);
                                    forwardMsgPeerName
                                        .add(lists[index]["name"]);
                                    forwardMsgPeerImage
                                        .add(lists[index]["img"]);
                                  });
                                },
                                icon: Icon(
                                  Icons.radio_button_off_outlined,
                                  color: Colors.grey,
                                  size: 28,
                                ),
                              ),
                        Container(
                          width: 20,
                        )
                      ],
                    )
                  : Container();
            },
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  forwardGroupsWidget(setState1) {
    return FutureBuilder(
      future: FirebaseDatabase.instance.reference().child("group").once(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var lists = [];
          var groupId = [];
          Map<dynamic, dynamic> values = snapshot.data.value;
          values.forEach((key, values) {
            lists.add(values);
            groupId.add(key);
          });
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: lists.length,
            itemBuilder: (BuildContext context, int index) {
              return lists[index]["userId"].contains(widget.currentuser)
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              new Divider(
                                height: 1,
                              ),
                              new ListTile(
                                onTap: () {},
                                leading: new Stack(
                                  children: <Widget>[
                                    (lists[index]["castImage"] != null &&
                                            lists[index]["castImage"].length >
                                                0)
                                        ? CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            backgroundImage: new NetworkImage(
                                                lists[index]["castImage"]),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.grey[300],
                                            child: Text(
                                              "",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                  ],
                                ),
                                title: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      lists[index]["castName"] ?? "",
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                // subtitle: new Container(
                                //   padding: const EdgeInsets.only(top: 5.0),
                                //   child: new Row(
                                //     children: [
                                //       Text(lists[index]["castDesc"])
                                //       // ItemsTile(c.phones),
                                //     ],
                                //   ),
                                // ),
                              ),
                            ],
                          ),
                        ),
                        groupMsgId.contains(groupId[index])
                            ? InkWell(
                                onTap: () {},
                                child: IconButton(
                                  onPressed: () {
                                    setState1(() {
                                      groupMsgId.remove(groupId[index]);
                                      groupMsgUserId.remove(
                                          jsonEncode(lists[index]["userId"]));
                                      groupMsgPeerName
                                          .remove(lists[index]["castName"]);
                                      groupMsgPeerImage
                                          .remove(lists[index]["castImage"]);
                                      print(groupMsgUserId);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: appColorBlue,
                                    size: 28,
                                  ),
                                ))
                            : IconButton(
                                onPressed: () {
                                  setState1(() {
                                    groupMsgId.add(groupId[index]);
                                    groupMsgUserId.add(
                                        jsonEncode(lists[index]["userId"]));
                                    // groupMsgUserId
                                    //     .add(lists[index]["userId"].toString());
                                    groupMsgPeerName
                                        .add(lists[index]["castName"]);
                                    groupMsgPeerImage
                                        .add(lists[index]["castImage"]);
                                    print(groupMsgUserId);
                                  });
                                },
                                icon: Icon(
                                  Icons.radio_button_off_outlined,
                                  color: Colors.grey,
                                  size: 28,
                                ),
                              ),
                        Container(
                          width: 20,
                        )
                      ],
                    )
                  : Container();
            },
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  Future<void> onForward(
    peerID2,
    peerName2,
    peerUrl2,
    String content,
    int type,
    String contact,
  ) async {
    var groupChatId = '';
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
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
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
    } else {}
  }

  void onForwardGroup(groupMsgUserId, groupMsgId, groupMsgPeerName,
      groupMsgPeerImage, groupMsgContent, groupMsgType, groupMsgContact) {
    // 0 = text
    // 1 = image
    // 2 = sticker
    // 4 = video
    // 5 = file
    // 6 = audio
    // 7 = contact
    // 8 = location

    var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    var documentReference = Firestore.instance
        .collection('groupMessages')
        .document(groupMsgId)
        .collection(groupMsgId)
        .document(timeStamp);

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        {
          'idFrom': widget.currentuser,
          'fromName': widget.currentusername,
          'idTo': groupMsgId,
          'timestamp': timeStamp,
          'content': groupMsgContent,
          'contact': groupMsgContact,
          'type': groupMsgType,
          "read": false,
          "delete": [],
          // "lat": lat,
          // "long": long,
          // "replyType": replyType
        },
      );
    }).then((onValue) async {
      var groupKey = [];
      var msg = [];
      var type = [];
      var contact = [];
      var time = [];

      var splitUserIds = jsonDecode(groupMsgUserId);

      for (var i = 0; i < splitUserIds.length; i++) {
        groupKey.add(groupMsgId);
        msg.add(groupMsgContent);
        type.add(groupMsgType);
        contact.add(groupMsgContact);
        time.add(timeStamp);
      }

      for (var i = 0; i < splitUserIds.length; i++) {
        onSendGroupMessage(
            groupKey[i], splitUserIds[i], msg[i], type[i], contact[i], time[i]);
      }
    });
  }

  Future<void> onSendGroupMessage(String groupKey, String groupIds,
      String content, int type, String contact, String time) async {
    int badgeCount = 0;

    try {
      await Firestore.instance
          .collection("chatList")
          .document(groupIds)
          .collection(groupIds)
          .document(groupKey)
          .get()
          .then((doc) async {
        debugPrint(doc.data["badge"]);
        if (doc.data["badge"] != null) {
          badgeCount = int.parse(doc.data["badge"]);
          await Firestore.instance
              .collection("chatList")
              .document(groupIds)
              .collection(groupIds)
              .document(groupKey)
              .updateData({
            'timestamp': time,
            'content': content,
            'badge': '${badgeCount + 1}',
            // groupIds == widget.currentuser ? "0" : '${badgeCount + 1}',
            'type': type,
            'contact': contact,
          });
        }
      });
    } catch (e) {
      print("EEEEEEEEEE: " + e.toString());
    }
  }

  download(url, type) async {
    setState(() {
      localImage.add(url);
      preferences.setStringList("localImage", localImage);
    });
    // setState(() {
    //   totalData = "0";
    //   isDownloading = true;
    // });
    String testrt = '';
    if (type == 1) {
      testrt = "jpeg";
    }
    if (type == 4) {
      testrt = "mp4";
    }
    if (type == 5) {
      testrt = "pdf";
    }

    try {
      Dio dio = Dio();

      var time = DateTime.now().millisecondsSinceEpoch.toString();
      await dio.download(url, "/sdcard/download/" + "$time." + "$testrt",
          onReceiveProgress: (rec, total) {
        // setState(() {
        //   int percentage = ((rec / total) * 100).floor();
        //   totalData = percentage.toString();
        //   print(percentage);
        // });
      }).then((value) {
        // setState(() {
        //   isDownloading = false;
        //   Toast.show("Download successfully", context,
        //       duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        // });
      });
    } catch (e) {
      // setState(() {
      //   isDownloading = false;
      //   Toast.show("Download Failed!", context,
      //       duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      // });
    }
  }
}

List _searchResult = [];
