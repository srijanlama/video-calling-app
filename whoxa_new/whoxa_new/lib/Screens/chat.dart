import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:firebase_database/firebase_database.dart' as firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';
import 'package:flutterwhatsappclone/Screens/contactinfo.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call_utilities.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/pickup_layout.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/user.dart';
import 'package:flutterwhatsappclone/Screens/videoPlayerScreen.dart';
import 'package:flutterwhatsappclone/Screens/videoView.dart';
import 'package:flutterwhatsappclone/Screens/widgets/player_widget.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/starModel.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:file/local.dart';
import 'dart:math' as math;
import 'package:toast/toast.dart';
import 'package:flutterwhatsappclone/Screens/saveContact.dart';
import 'package:flutterwhatsappclone/Screens/viewImages.dart';
import 'package:linkable/linkable.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterwhatsappclone/Screens/widgets/thumbnailImage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:swipeable/swipeable.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../story/editor.dart';

// ignore: must_be_immutable
class Chat extends StatefulWidget {
  LocalFileSystem localFileSystem;
  String searchText;
  String searchTime;
  String peerID;
  bool archive;
  String pin;
  String chatListTime;

  Chat(
      {this.searchText,
      this.searchTime,
      this.peerID,
      this.archive,
      this.pin,
      this.chatListTime,
      localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _ChatState createState() => _ChatState(peerID: peerID);
}

class _ChatState extends State<Chat> {
  String peerID;
  String peerUrl = '';
  String peerName = '';
  String peerMobile = '';
  String peerToken = '';
  String peerChatIn = '';
  String peerOnlineStatus = '';

  _ChatState({@required this.peerID});
  // ignore: unused_field
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dataKey = new GlobalKey();
//RECORDER ----------------------------------------------------------------
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  bool record = false;
  bool running = false;
  bool button = false;
  File voiceRecording;
//RECORDER ----------------------------------------------------------------

  String groupChatId;
  var listMessage;
  File videoFile;
  VideoPlayerController _videoPlayerController;
  bool isLoading;
  String imageUrl;
  int limit = 20;

  final TextEditingController textEditingController = TextEditingController();

  TextEditingController reviewCode = TextEditingController();
  TextEditingController reviewText = TextEditingController();
  bool isInView = false;
  File _path;
  String filename;

  var toSendname = [];
  var toSendphone = [];
  // ignore: non_constant_identifier_names
  double HEIGHT = 96;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  String banner;
  var backImage = '';
  var blocksId = [];
  var peerblocksId = [];
  // ignore: unused_field
  firebase.DatabaseReference _messagesRef;
  // ignore: unused_field
  String _messageText = "";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool searchData = false;
  TextEditingController controller = new TextEditingController();
  TextEditingController forwardController = new TextEditingController();
  List chatMsgList;
  firebase.FirebaseDatabase database = new firebase.FirebaseDatabase();
  bool deleteButton = false;
  var deleteMsgTime = [];
  var deleteMsgID = [];
  var deleteMsgContent = [];
  //LocationResult _pickedLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
    onChange: (value) => print(''),
    onChangeRawSecond: (value) => print(''),
    onChangeRawMinute: (value) => print(''),
  );
  bool replyButton = false;
  String replyMsg = '';
  var replyTime;
  int replyType = 0;
  String replyName = '';
  var imageMedia = [];
  List newList = [];
  var videoMedia = [];
  var docsMedia = [];
  bool offline = false;

  User sender = User();
  User receiver = User();
  bool internet = false;

  var getContacts = [];
  var newgetContacts = [];
  // ignore: unused_field
  GiphyGif _gif;
  final textFieldFocusNode = FocusNode();
  final FocusNode focusNode = FocusNode();
//FORWARD

//FOR PERSON TO PERSON

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

  //FOR GROUP
  var groupMsgId = [];
  var groupMsgUserId = [];
  var groupMsgContent = [];
  var groupMsgContact = [];
  var groupMsgPeerName = [];
  var groupMsgPeerImage = [];
  var groupMsgType = [];
  //FORWARD

  bool isButtonEnabled = false;

  String profilrPrivacy = '';
  String lastSeenPrivacy = '';
  bool loadPage = true;

  //EDIT IMAGE
  bool editImage = false;
  int _currentImage = 0;

  //Blink

  Timer _timerBlink;
  String contentBlink = '';

  Timer searchOnStoppedTyping;

  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
            2000); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() {
        typingFunction("typing");
        searchOnStoppedTyping.cancel();
      }); // clear timer
    }
    setState(() {
      searchOnStoppedTyping = new Timer(duration, () {
        search(value);
        typingFunction("Online");
      });
    });
  }

  search(value) {
    print('hello world from search . the value is $value');
  }

  typingFunction(status) {
    database.reference().child("user").child(userID).update({
      "status": status,
    });
  }

  //VIDEO UPLOADING
  var videoSize = '';
  double _progress = 0;
  double percentage = 0;
  bool videoloader = false;
  String videoStatus = '';

  @override
  void initState() {
    getPeerUser();
    listScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    listScrollController.addListener(hideKeyboard);
    getUserOnlineStatus();
    _initVoiceRecorder();
    checkInternet();

    chatInCall();
    // refreshContacts();

    getContactsFromGloble();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          print("onMessage");
          _messageText = "Push Messaging message: $message";
          // onSelectNotification(message.toString());
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          print("onLaunch");
          _messageText = "Push Messaging message: $message";
          //  onSelectNotification(message.toString());
        });
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          print("onResume");
          _messageText = "Push Messaging message: $message";

          // onSelectNotification(message.toString());
        });
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});

    checkprofilrPrivacy();
    checklastSeenPrivacy();

    getBlockId();

    super.initState();

    groupChatId = '';
    isLoading = false;
    imageUrl = '';
    readLocal();
    removeBadge();

    const oneSec = const Duration(seconds: 10);
    new Timer.periodic(oneSec, (Timer t) {
      getUserOnlineStatus();
    });
    // readMessage();

    setState(() {
      // _scrollToIndex(gotoindex);
    });
  }

  getPeerUser() async {
    database.reference().child('user').child(peerID).once().then((peerData) {
      peerUrl = peerData.value['img'];
      peerName = peerData.value['name'];
      peerMobile = peerData.value['mobile'];
      peerToken = peerData.value['token'];
      peerChatIn = peerData.value['inChat'];
      peerOnlineStatus = peerData.value['status'];

      sender.uid = userID;
      sender.name = globalName;
      sender.profilePhoto = globalImage;

      receiver.uid = peerID;
      receiver.name = getContactName(peerMobile);
      receiver.profilePhoto = peerUrl;
    });
    setState(() {
      loadPage = false;
    });
  }

  //SCROLL TO SPECIFIC INDEX
  bool isScroll = true;
  final scrollDirection = Axis.vertical;
  int gotoindex;
  AutoScrollController listScrollController;
  List<List<int>> randomList;

  _scrollToIndex(index) async {
    print("👉" + widget.searchText.toString());
    print("👉" + widget.searchTime.toString());
    await listScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
  }
  //SCROLL TO SPECIFIC INDEX

  _initVoiceRecorder() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        Directory appDocDirectory;
        if (Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;

        var current = await _recorder.current(channel: 0);
        print(current);

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
    _timerBlink?.cancel();
    super.dispose();
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
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

  chatInCall() {
    firebase.DatabaseReference _userRef = database.reference().child('user');
    _userRef.child(userID).update({
      "inChat": peerID,
    }).then((_) {
      setState(() {});
    });
  }

  chatOutCall() {
    firebase.DatabaseReference _userRef = database.reference().child('user');
    _userRef.child(userID).update({
      "inChat": "",
    }).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  goBackFunctionCall() {
    // setState(() {
    //     _scrollToIndex();
    // });
    // print(widget.searchTime);
    // Scrollable.ensureVisible(dataKey.currentContext);
    chatOutCall();
    Navigator.pop(context);
  }

  readMessage(time) async {
    CollectionReference col1 = Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId);
    final snapshots = col1.snapshots().map((snapshot) => snapshot.documents
        .where((doc) => doc["idTo"] == userID && doc["timestamp"] == time));

    snapshots.first.then((value) {
      value.forEach((document) {
        document.reference.updateData({'read': true});
      });
    });
  }

  // await Firestore.instance
  //     .collection("messages")
  //     .document(groupChatId)
  //     .collection(groupChatId)
  //     .where("idTo", isEqualTo: userID)
  //     .getDocuments()
  //     .then((querySnapshot) {
  //   querySnapshot.documents.forEach((documentSnapshot) {
  //     documentSnapshot.reference.updateData({'read': true});
  //     // print("True");
  //   });
  // });
  getUserOnlineStatus() async {
    final firebase.FirebaseDatabase database = new firebase.FirebaseDatabase();

    database
        .reference()
        .child('user')
        .child(peerID)
        .orderByChild("status")
        .once()
        .then((peerData) {
      if (mounted) {
        setState(() {
          peerOnlineStatus = peerData.value['status'];
        });
      }
    });

    database
        .reference()
        .child('user')
        .child(userID)
        .orderByChild("bio")
        .once()
        .then((data) {
      backImage = data.value['bio'];
    });
  }
  //List<Contact> _contacts;
  //var check = [];
  //New Contacts for share
//   Future<void> refreshContacts() async {
//     var contacts = (await ContactsService.getContacts(
//             withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
//         .toList();
// //      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
// //          .toList();
//     setState(() {
//       _contacts = contacts;
//       if (_contacts != null) {
//         for (int i = 0; i < _contacts.length; i++) {
//           Contact c = _contacts?.elementAt(i);
//           check.add(c.phones.map((e) => e.value));
//           //print(check);
//         }
//       }
//     });

//     for (final contact in contacts) {
//       ContactsService.getAvatar(contact).then((avatar) {
//         if (avatar == null) return;
//         if (this.mounted) {
//           setState(() => contact.avatar = avatar);
//         } // Don't redraw if no change.
//       });
//     }
//   }
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
        if (replyButton == true) {
          onSendMessage(fileUrl, 9, '', replyName, replyMsg, replyTime, 5);
          setState(() {
            replyButton = false;
          });
        } else {
          onSendMessage(fileUrl, 5, '', '', '', '', 5);
        }

        setState(() {
          isLoading = false;
        });
      }
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<File> allImages = [];

  Future<void> getImage() async {
    List<Asset> images = <Asset>[];
    images = [];

    String error = 'No Error Detected';

    try {
      allImages = [];
      // ignore: unused_field
      await MultiImagePicker.pickImages(
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
      ).then((value) {
        setState(() {
          images = value;
          images.forEach((imageAsset) async {
            await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier)
                .then((filePath) {
              File tempFile = File(filePath);
              if (tempFile.existsSync()) {
                if (allImages.contains(tempFile)) {
                } else {
                  allImages.add(tempFile);
                }
              }
            }).then((value) {
              if (allImages.length > 0) {
                _currentImage = 0;
                editImage = true;
              }
            });
          });

          print(error);
        });
        return value;
      });
    } on Exception catch (e) {
      error = e.toString();
    }

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => ViewImages(
    //             images: allImages,
    //             number: 0,
    //           )),
    // );
    if (!mounted) return;
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
    setState(() {
      _progress = 0;
      percentage = 0;
      videoloader = true;
      videoStatus = 'Compressing..';
    });
    final dir = await getTemporaryDirectory();
    final targetPath = dir.absolute.path +
        "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

    await FlutterImageCompress.compressAndGetFile(
      _image.absolute.path,
      targetPath,
      quality: 20,
    ).then((value) async {
      setState(() {
        videoStatus = 'Uploading..';
        final bytes = File(value.path).readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        final mb = kb / 1024;
        videoSize = mb.toStringAsFixed(2).toString() + "MB";
      });
      print("Compressed");
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference reference = FirebaseStorage.instance
          .ref()
          .child("ChatImageMedia")
          .child(fileName);

      StorageUploadTask uploadTask = reference.putFile(value);
      uploadTask.events.listen((event) {
        setState(() {
          _progress = event.snapshot.bytesTransferred.toDouble() /
              event.snapshot.totalByteCount.toDouble();
          percentage = _progress;
          print('Uploading ${(_progress * 100).toStringAsFixed(2)} %');
        });
      }).onError((error) {
        setState(() {
          videoloader = false;
        });
      });

      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;
        if (replyButton == true) {
          onSendMessage(imageUrl, 9, '', replyName, replyMsg, replyTime, 1);
          setState(() {
            videoloader = false;
            replyButton = false;
          });
        } else {
          onSendMessage(imageUrl, 1, '', '', '', '', 1);
          setState(() {
            videoloader = false;
          });
        }

        setState(() {
          videoloader = false;
        });
      }, onError: (err) {
        setState(() {
          videoloader = false;
        });
        // Fluttertoast.showToast(msg: 'This file is not an image');
      });
    });
    //  }
  }

  Future getImageFromCam() async {
    File _image;

    final picker = ImagePicker();
    final imageFile = await picker.getImage(source: ImageSource.camera);

    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
        _progress = 0;
        percentage = 0;
        videoloader = true;
        videoStatus = 'Compressing..';
      });
      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        _image.absolute.path,
        targetPath,
        quality: 20,
      ).then((value) async {
        setState(() {
          videoStatus = 'Uploading..';
          final bytes = File(value.path).readAsBytesSync().lengthInBytes;
          final kb = bytes / 1024;
          final mb = kb / 1024;
          videoSize = mb.toStringAsFixed(2).toString() + "MB";
        });
        print("Compressed");
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        StorageReference reference = FirebaseStorage.instance
            .ref()
            .child("ChatImageMedia")
            .child(fileName);

        StorageUploadTask uploadTask = reference.putFile(value);
        uploadTask.events.listen((event) {
          setState(() {
            _progress = event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble();
            percentage = _progress;
            print('Uploading ${(_progress * 100).toStringAsFixed(2)} %');
          });
        }).onError((error) {
          setState(() {
            videoloader = false;
          });
        });
        StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          imageUrl = downloadUrl;
          setState(() {
            if (replyButton == true) {
              onSendMessage(imageUrl, 9, '', replyName, replyMsg, replyTime, 1);
              setState(() {
                replyButton = false;
                videoloader = false;
              });
            } else {
              onSendMessage(imageUrl, 1, '', '', '', '', 1);
              setState(() {
                videoloader = false;
              });
            }
          });
        }, onError: (err) {
          setState(() {
            videoloader = false;
          });
          // Fluttertoast.showToast(msg: 'This file is not an image');
        });
      });
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
          setState(() {
            videoloader = false;
          });
        });

        await uploadTask.onComplete;
        String downloadUrl = await ref.getDownloadURL();

        onSendMessage(downloadUrl, 4, '', '', '', '', 4);
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

  removeBadge() async {
    await Firestore.instance
        .collection("chatList")
        .document(userID)
        .collection(userID)
        .document(peerID)
        .updateData({'badge': '0'});
  }

  // ignore: unused_element
  void _scrollListener() {
    if (listScrollController.position.pixels ==
        listScrollController.position.maxScrollExtent) {
      startLoader();
    }
  }

  hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
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

  readLocal() {
    if (userID.hashCode <= peerID.hashCode) {
      groupChatId = '$userID-$peerID';
    } else {
      groupChatId = '$peerID-$userID';
    }
  }

  // _animateToIndex(i) => listScrollController.animateTo(100,
  //     duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);

  @override
  Widget build(BuildContext context) {
    //getUserStatus();
    // listScrollController = new ScrollController()..addListener(_scrollListener);
    return WillPopScope(
      onWillPop: () async {
        goBackFunctionCall();
        return false;
      },
      child: PickupLayout(
        scaffold: Scaffold(
            backgroundColor: appColorWhite,
            // key: _scaffoldKey,
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
                            for (var i = 0; i < allImages.length; i++) {
                              sendImage(allImages[i]);
                            }

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
                        title: searchTextField(),
                        centerTitle: false,
                        elevation: 0,
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
                                  builder: (context) => ContactInfo(
                                      id: widget.peerID,
                                      imageMedia: imageMedia,
                                      videoMedia: videoMedia,
                                      docsMedia: docsMedia,
                                      blocksId: blocksId)),
                            );
                          },
                          child: Container(
                            // height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    goBackFunctionCall();
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
                                imageWidget(),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          getContactName(peerMobile),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "MontserratBold",
                                              color: Colors.black),
                                        ),
                                        peerOnline()
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        automaticallyImplyLeading: false,
                        // leading: false,
                        actions: <Widget>[
                          Container(
                            width: 30,
                            child: IconButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: () {
                                  sendCallNotification(
                                      peerToken, "$appName Video Calling....");
                                  CallUtils.dial(
                                      from: sender,
                                      to: receiver,
                                      context: context,
                                      status: "videocall");
                                },
                                icon: Icon(CupertinoIcons.videocam_fill,
                                    color: appColorBlue, size: 30)),
                          ),
                          Container(width: 10),
                          Container(
                            width: 30,
                            child: IconButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: () {
                                  sendCallNotification(
                                      peerToken, "$appName Voice Calling....");
                                  CallUtils.dial(
                                      from: sender,
                                      to: receiver,
                                      context: context,
                                      status: "voicecall");
                                },
                                icon: Icon(CupertinoIcons.phone_fill,
                                    color: appColorBlue, size: 24)),
                          ),
                          Container(width: 10),
                          searchData == false
                              ? Container(
                                  width: 30,
                                  child: IconButton(
                                      padding: const EdgeInsets.all(0),
                                      onPressed: () {
                                        setState(() {
                                          searchData = true;
                                        });
                                      },
                                      icon: Icon(CupertinoIcons.search,
                                          color: appColorBlue, size: 24)),
                                )
                              : Container(),
                          Container(
                            width: 15,
                          ),
                        ],
                      ),
            body: peerblocksId.contains(userID)
                ? Center(
                    child: Text(
                    "You already blocked so once opposite \nperson unblocked then you can chat.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45),
                  ))
                : editImage == true
                    ? editImageWidget()
                    : Builder(
                        builder: (context) => Stack(
                          children: [
                            Container(
                              child: Column(
                                children: <Widget>[
                                  // List of messages
                                  buildListMessage(),

                                  deleteButton == true
                                      ? buildDeleteInput()
                                      : forwardButton == true
                                          ? buildForwardInput()
                                          : buildInput(),
                                ],
                              ),
                            ),
                            internet == true
                                ? Align(
                                    alignment: Alignment.center,
                                    child: isLoading == true
                                        ? Center(child: loader())
                                        : Container(),
                                  )
                                : Container(),
                            videoloader == true
                                ? uploadWidget(
                                    percentage, _progress, videoStatus)
                                : Container(),
                          ],
                        ),
                      )),
      ),
    );
  }

  Widget peerOnline() {
    return StreamBuilder(
      stream: firebase.FirebaseDatabase.instance
          .reference()
          .child('user')
          .child(peerID)
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //  chatInCall();
          peerChatIn = snapshot.data.snapshot.value['inChat'];
          return snapshot.data.snapshot.value["status"].length > 0 &&
                  snapshot.data.snapshot.value["profileseen"] != "nobody"
              ? snapshot.data.snapshot.value["status"] == "typing" &&
                      snapshot.data.snapshot.value["inChat"] == userID
                  ? CustomText(
                      text: 'typing..',
                      alignment: Alignment.centerLeft,
                      fontSize: 13,
                      color: appColorBlue,
                    )
                  : snapshot.data.snapshot.value["status"] == "typing" ||
                          snapshot.data.snapshot.value["status"] == "Online"
                      ? CustomText(
                          text: 'Online',
                          alignment: Alignment.centerLeft,
                          fontSize: 13,
                          color: appColorBlue,
                        )
                      : CustomText(
                          text: "Last Seen at " +
                              readTimestamp(int.parse(
                                snapshot.data.snapshot.value["status"],
                              )),
                          alignment: Alignment.centerLeft,
                          fontSize: 10,
                          color: appColorGrey,
                        )
              : Text(
                  '',
                  style: TextStyle(color: Colors.green),
                );
        }
        return Container();
      },
    );
  }

  Widget searchTextField() {
    return Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Row(
          children: [
            Container(width: 10),
            Expanded(
              child: Container(
                height: 40,
                child: Center(
                  child: TextField(
                    controller: controller,
                    onChanged: onSearchTextChanged,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    decoration: new InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[400]),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[400]),
                      ),
                      filled: false,
                      hintStyle:
                          new TextStyle(color: Colors.grey[600], fontSize: 14),
                      hintText: "SEARCH",
                      contentPadding: EdgeInsets.only(top: 8, left: 5),
                      fillColor: Colors.grey[200],
                      suffixIcon: Icon(
                        CupertinoIcons.search,
                        color: appColorBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appColorGreen)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  // .limit(limit)
                  .snapshots()
                  .asBroadcastStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(appColorGreen)));
                } else {
                  listMessage = snapshot.data.documents;
                  return Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: backImage.length > 0
                            ? DecorationImage(
                                image: NetworkImage(backImage),
                                fit: BoxFit.cover,
                              )
                            : null,
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

                                      return buildItem(
                                          index, _searchResult[index]);
                                    })
                                : ListView.builder(
                                    // key: dataKey,
                                    padding: EdgeInsets.all(10.0),
                                    itemCount: snapshot.data.documents.length,
                                    reverse: true,
                                    controller: listScrollController,
                                    itemBuilder: (context, index) {
                                      if (snapshot.hasData)
                                        chatMsgList = snapshot.data.documents;

                                      for (int i = 0;
                                          i < chatMsgList.length;
                                          i++) {
                                        if (chatMsgList[i]["timestamp"] ==
                                                widget.searchTime.toString() &&
                                            isScroll == true) {
                                          gotoindex = i;
                                          _scrollToIndex(gotoindex);
                                          isScroll = false;
                                        }
                                      }

                                      return AutoScrollTag(
                                        key: ValueKey(index),
                                        controller: listScrollController,
                                        index: index,
                                        child: offline == true
                                            ? buildItem(index, msgList[index])
                                            : buildItem(
                                                index, chatMsgList[index]),
                                      );
                                    }),
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
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      child: Text(
                                                        DateFormat(
                                                                'EEEE, d MMM')
                                                            .format(
                                                          DateTime.parse(
                                                              banner),
                                                        ),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                return Transform.translate(
                                    offset: Offset(0, 0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 0, right: 0),
                                      child: value < 1
                                          ? Container()
                                          : Align(
                                              alignment: Alignment.bottomRight,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft: Radius
                                                                .circular(10),
                                                            topLeft:
                                                                Radius.circular(
                                                                    10))),
                                                height: 40,
                                                width: 40,
                                                child: IconButton(
                                                  onPressed: () {
                                                    // _animateToIndex(20);

                                                    listScrollController
                                                        .animateTo(
                                                      listScrollController
                                                          .position
                                                          .minScrollExtent,
                                                      duration:
                                                          Duration(seconds: 1),
                                                      curve:
                                                          Curves.fastOutSlowIn,
                                                    );
                                                    setState(() {
                                                      //  icon = false;
                                                    });
                                                  },
                                                  icon: Icon(
                                                      Icons.arrow_circle_down),
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

    if (document['idFrom'] == userID) {
      return document['delete'].contains(userID)
          ? Column(
              children: [
                myDeleteMessage(
                    ChatBubbleClipper4(type: BubbleType.sendBubble),
                    chatRightColor,
                    chatRightTextColor,
                    document['star'],
                    document['timestamp'],
                    document['read'],
                    index,
                    document['idFrom']),
              ],
            )
          : Swipeable(
              threshold: 60.0,
              onSwipeRight: () {
                setState(() {
                  replyType = document['type'];
                  replyMsg = replyType == 1
                      ? "📷 Photo"
                      : replyType == 4
                          ? "🎥 Video"
                          : replyType == 5
                              ? "📄 Document"
                              : replyType == 6
                                  ? "🔊 Audio"
                                  : document['content'];

                  replyTime = document['timestamp'];
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
                                      deleteMsgContent
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
                                      deleteMsgTime.add(document['timestamp']);
                                      deleteMsgID.add(document['idFrom']);
                                      deleteMsgContent.add(document['content']);
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
                          onTap: () {
                            setState(() {
                              textFieldFocusNode.unfocus();
                              textFieldFocusNode.canRequestFocus = false;
                            });
                          },
                          onLongPress: () {
                            replyType = document['type'];
                            replyMsg = replyType == 1
                                ? "📷 Photo"
                                : replyType == 4
                                    ? "🎥 Video"
                                    : replyType == 5
                                        ? "📄 Document"
                                        : replyType == 6
                                            ? "🔊 Audio"
                                            : document['content'];

                            replyTime = document['timestamp'];
                            replyName = "You";

                            openMessageBox(
                                document['star'] != null &&
                                        document['star'].length > 0
                                    ? document['star']
                                    : [],
                                document['timestamp'],
                                groupChatId,
                                document['idFrom'],
                                document['content'],
                                document['idTo'],
                                document['type'],
                                document['contact']);
                          },
                          child: Row(
                            children: <Widget>[
                              document['type'] == 0
                                  // Text
                                  ? myTextMessage(
                                      ChatBubbleClipper4(
                                          type: BubbleType.sendBubble),
                                      chatRightColor,
                                      chatRightTextColor,
                                      document['content'],
                                      document['star'],
                                      document['timestamp'],
                                      document['read'],
                                      index,
                                      document['idFrom'])
                                  : document['type'] == 1
                                      // Image/GIF
                                      ? myImageWidget(
                                          ChatBubbleClipper4(
                                              type: BubbleType.sendBubble),
                                          chatRightColor,
                                          chatRightTextColor,
                                          document['content'],
                                          document['star'],
                                          document['timestamp'],
                                          document['read'],
                                          index,
                                          document['idFrom'])
                                      : document['type'] == 4
                                          //Video
                                          ? myVideoWidget(
                                              ChatBubbleClipper4(
                                                  type: BubbleType.sendBubble),
                                              chatRightColor,
                                              chatRightTextColor,
                                              document['content'],
                                              document['star'],
                                              document['timestamp'],
                                              document['read'],
                                              index,
                                              document['idFrom'])
                                          : document['type'] == 5
                                              //File
                                              ? myFileWidget(
                                                  ChatBubbleClipper4(
                                                      type: BubbleType
                                                          .sendBubble),
                                                  chatRightColor,
                                                  chatRightTextColor,
                                                  document['content'],
                                                  document['star'],
                                                  document['timestamp'],
                                                  document['read'],
                                                  index,
                                                  document['idFrom'])
                                              : document['type'] == 6
                                                  //Audio
                                                  ? myVoiceWidget(
                                                      ChatBubbleClipper4(
                                                          type: BubbleType
                                                              .sendBubble),
                                                      chatRightColor,
                                                      chatRightTextColor,
                                                      document['content'],
                                                      document['star'],
                                                      document['timestamp'],
                                                      document['read'],
                                                      index,
                                                      document['idFrom'])
                                                  : document['type'] == 7
                                                      //contact
                                                      ? myContactWidget(
                                                          ChatBubbleClipper4(
                                                              type: BubbleType
                                                                  .sendBubble),
                                                          chatRightColor,
                                                          chatRightTextColor,
                                                          document['content'],
                                                          document['star'],
                                                          document['timestamp'],
                                                          document['read'],
                                                          index,
                                                          document['contact'],
                                                          document['idFrom'])
                                                      : document['type'] == 8
                                                          //location
                                                          ? myLocationWidget(
                                                              ChatBubbleClipper4(
                                                                  type: BubbleType
                                                                      .sendBubble),
                                                              chatRightColor,
                                                              chatRightTextColor,
                                                              document[
                                                                  'content'],
                                                              document['star'],
                                                              document[
                                                                  'timestamp'],
                                                              document['read'],
                                                              index,
                                                              document['lat'],
                                                              document['long'],
                                                              document[
                                                                  'idFrom'])
                                                          : document['type'] ==
                                                                  9 // Reply
                                                              ? myReplyWidget(
                                                                  ChatBubbleClipper4(
                                                                      type: BubbleType
                                                                          .sendBubble),
                                                                  chatRightColor,
                                                                  chatRightTextColor,
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
                                                                      'lat'],
                                                                  document[
                                                                      'long'],
                                                                  document[
                                                                      'contact'],
                                                                  document[
                                                                      'replyTime'],
                                                                  document[
                                                                      'contentType'],
                                                                  document[
                                                                      'idFrom'])
                                                              : Container()
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
      return VisibilityDetector(
        key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
        onVisibilityChanged: (VisibilityInfo info) {
          debugPrint("${info.visibleFraction} of my widget is visible");
          if (info.visibleFraction == 0) {
          } else {
            if (document['read'] == false &&
                document['idTo'] == userID &&
                groupChatId != null) readMessage(document['timestamp']);
          }
        },
        child: Container(
          child: document['delete'].contains(userID)
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: peerDeleteMessage(
                      ChatBubbleClipper4(type: BubbleType.receiverBubble),
                      chatLeftColor,
                      chatLeftTextColor,
                      document['star'],
                      document['timestamp'],
                      document['read'],
                      index,
                      document['idFrom']),
                )
              : Swipeable(
                  threshold: 60.0,
                  onSwipeRight: () {
                    setState(() {
                      replyType = document['type'];
                      replyMsg = replyType == 1
                          ? "📷 Photo"
                          : replyType == 4
                              ? "🎥 Video"
                              : replyType == 5
                                  ? "📄 Document"
                                  : replyType == 6
                                      ? "🔊 Audio"
                                      : document['content'];

                      replyTime = document['timestamp'];
                      replyName = peerName;
                      replyButton = true;
                    });
                  },
                  background: Container(),
                  child: Row(
                    children: [
                      deleteButton == true
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: deleteMsgTime
                                      .contains(document['timestamp'])
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          deleteMsgTime
                                              .remove(document['timestamp']);
                                          deleteMsgContent
                                              .remove(document['content']);
                                          deleteMsgID
                                              .remove(document['idFrom']);
                                        });
                                      },
                                      child: Icon(Icons.check_circle))
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          deleteMsgTime
                                              .add(document['timestamp']);
                                          deleteMsgID.add(document['idFrom']);
                                          deleteMsgContent
                                              .add(document['content']);
                                        });
                                      },
                                      child:
                                          Icon(Icons.radio_button_unchecked)),
                            )
                          : forwardButton == true
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: forwardTime
                                          .contains(document['timestamp'])
                                      ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              forwardTime.remove(
                                                  document['timestamp']);
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
                                              forwardTypes
                                                  .add(document['type']);
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
                              onTap: () {
                                setState(() {
                                  textFieldFocusNode.unfocus();
                                  textFieldFocusNode.canRequestFocus = false;
                                });
                              },
                              onLongPress: () {
                                replyType = document['type'];
                                replyMsg = replyType == 1
                                    ? "📷 Photo"
                                    : replyType == 4
                                        ? "🎥 Video"
                                        : replyType == 5
                                            ? "📄 Document"
                                            : replyType == 6
                                                ? "🔊 Audio"
                                                : document['content'];

                                replyTime = document['timestamp'];
                                replyName = peerName;
                                openMessageBox(
                                    document['star'] != null &&
                                            document['star'].length > 0
                                        ? document['star']
                                        : [],
                                    document['timestamp'],
                                    groupChatId,
                                    document['idFrom'],
                                    document['content'],
                                    document['idTo'],
                                    document['type'],
                                    document['contact']);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: <Widget>[
                                    document['type'] == 0
                                        // Text
                                        ? myTextMessage(
                                            ChatBubbleClipper4(
                                                type:
                                                    BubbleType.receiverBubble),
                                            chatLeftColor,
                                            chatLeftTextColor,
                                            document['content'],
                                            document['star'],
                                            document['timestamp'],
                                            document['read'],
                                            index,
                                            document['idFrom'])
                                        : document['type'] == 1
                                            // Image/GIF
                                            ? myImageWidget(
                                                ChatBubbleClipper4(
                                                    type: BubbleType
                                                        .receiverBubble),
                                                chatLeftColor,
                                                chatLeftTextColor,
                                                document['content'],
                                                document['star'],
                                                document['timestamp'],
                                                document['read'],
                                                index,
                                                document['idFrom'])
                                            : document['type'] == 4
                                                //Video
                                                ? myVideoWidget(
                                                    ChatBubbleClipper4(
                                                        type: BubbleType
                                                            .receiverBubble),
                                                    chatLeftColor,
                                                    chatLeftTextColor,
                                                    document['content'],
                                                    document['star'],
                                                    document['timestamp'],
                                                    document['read'],
                                                    index,
                                                    document['idFrom'])
                                                : document['type'] == 5
                                                    //File
                                                    ? myFileWidget(
                                                        ChatBubbleClipper4(
                                                            type: BubbleType
                                                                .receiverBubble),
                                                        chatLeftColor,
                                                        chatLeftTextColor,
                                                        document['content'],
                                                        document['star'],
                                                        document['timestamp'],
                                                        document['read'],
                                                        index,
                                                        document['idFrom'])
                                                    : document['type'] == 6
                                                        //Audio
                                                        ? myVoiceWidget(
                                                            ChatBubbleClipper4(
                                                                type: BubbleType
                                                                    .receiverBubble),
                                                            chatLeftColor,
                                                            chatLeftTextColor,
                                                            document['content'],
                                                            document['star'],
                                                            document[
                                                                'timestamp'],
                                                            document['read'],
                                                            index,
                                                            document['idFrom'])
                                                        : document['type'] == 7
                                                            //contact
                                                            ? myContactWidget(
                                                                ChatBubbleClipper4(
                                                                    type: BubbleType
                                                                        .receiverBubble),
                                                                chatLeftColor,
                                                                chatLeftTextColor,
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
                                                                    'contact'],
                                                                document[
                                                                    'idFrom'])
                                                            : document['type'] ==
                                                                    8
                                                                //location
                                                                ? myLocationWidget(
                                                                    ChatBubbleClipper4(
                                                                        type: BubbleType
                                                                            .receiverBubble),
                                                                    chatLeftColor,
                                                                    chatLeftTextColor,
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
                                                                        'lat'],
                                                                    document[
                                                                        'long'],
                                                                    document[
                                                                        'idFrom'])
                                                                : document['type'] ==
                                                                        9 // Reply
                                                                    ? myReplyWidget(
                                                                        ChatBubbleClipper4(
                                                                            type: BubbleType
                                                                                .receiverBubble),
                                                                        chatLeftColor,
                                                                        chatLeftTextColor,
                                                                        document[
                                                                            'content'],
                                                                        document[
                                                                            'star'],
                                                                        document['timestamp'],
                                                                        document['read'],
                                                                        index,
                                                                        document['lat'],
                                                                        document['long'],
                                                                        document['contact'],
                                                                        document['replyTime'],
                                                                        document['contentType'],
                                                                        document['idFrom'])
                                                                    : Container()
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
        ),
      );
    }
  }

  Widget myDeleteMessage(CustomClipper clipper, chatRightColor,
      chatRightTextColor, star, timestamp, read, index, id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(top: 5, bottom: 12, left: 5, right: 12),
      backGroundColor: chatRightColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  Text(
                    "you deleted this message",
                    style: TextStyle(
                        color: chatRightTextColor,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 13),
                  ),
                  Container(
                    width: 100,
                    height: 15,
                  ),
                ],
              ),
            ),
            timeWidget(star, timestamp, read, chatRightTextColor, id),
          ],
        ),
      ),
    );
  }

  Widget peerDeleteMessage(CustomClipper clipper, chatRightColor,
      chatRightTextColor, star, timestamp, read, index, id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(top: 5, bottom: 12, left: 12, right: 5),
      backGroundColor: chatRightColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  Text(
                    "This message was deleted",
                    style: TextStyle(
                        color: chatRightTextColor,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 13),
                  ),
                  Container(
                    width: 100,
                    height: 15,
                  ),
                ],
              ),
            ),
            timeWidget(star, timestamp, read, chatRightTextColor, id),
          ],
        ),
      ),
    );
  }

  Widget myTextMessage(CustomClipper clipper, chatRightColor,
      chatRightTextColor, content, star, timestamp, read, index, id) {
    RegExp _numeric = RegExp(r'^-?[0-9]+$');

    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      backGroundColor: chatRightColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
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
                          style: TextStyle(
                              color: chatRightTextColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: normalStyle,
                              fontSize: 14),
                          text: content,
                          textColor: chatRightTextColor,
                        ),
                  Container(
                    width: 100,
                    height: 15,
                  ),
                ],
              ),
            ),
            timeWidget(star, timestamp, read, chatRightTextColor, id),
          ],
        ),
      ),
    );
  }

  myImageWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, star, timeStamp, read, index, id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 10),
      backGroundColor: chatRightColor,
      padding: id == userID
          ? EdgeInsets.only(top: 5, bottom: 12, left: 5, right: 12)
          : EdgeInsets.only(top: 5, bottom: 12, left: 12, right: 5),
      child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.width * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Stack(
            children: [
              Stack(
                children: [
                  localImage.contains(content)
                      ? InkWell(
                          onTap: () {
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
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.width * 0.7,
                              width: MediaQuery.of(context).size.width * 0.7,
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: ProgressiveImage(
                            placeholder:
                                AssetImage("assets/images/loading.gif"),
                            thumbnail: NetworkImage(content),
                            height: MediaQuery.of(context).size.width * 0.7,
                            width: MediaQuery.of(context).size.width * 0.7,
                            fit: BoxFit.cover,
                          ),
                        ),
                  timeWidget(star, timeStamp, read, chatRightTextColor, id),
                ],
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
          )),
    );
  }

  myVideoWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, star, timeStamp, read, index, id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      padding: id == userID
          ? EdgeInsets.only(top: 5, bottom: 12, left: 5, right: 12)
          : EdgeInsets.only(top: 5, bottom: 12, left: 12, right: 5),
      backGroundColor: chatRightColor,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        // ignore: deprecated_member_use
        child: FlatButton(
          child: Material(
            color: chatRightColor,
            child: Stack(
              children: [
                Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FittedBox(
                        fit: BoxFit.cover,
                        child: VideoView(
                          url: content,
                          play: isInView,
                        )),
                  ),
                ),
                timeWidget(star, timeStamp, read, chatRightTextColor, id)
              ],
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SamplePlayer(url: content)),
            );
          },
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  Widget myFileWidget(CustomClipper clipper, chatRightColor, chatRightTextColor,
      content, star, timeStamp, read, index, id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      backGroundColor: chatRightColor,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          // ignore: deprecated_member_use
          child: FlatButton(
            child: Stack(
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Icon(
                          Icons.note,
                          color: chatRightTextColor,
                        )),
                    Container(
                      width: 5,
                    ),
                    Container(
                      width: 120,
                      child: Text(
                        "FILE",
                        maxLines: 1,
                        style: TextStyle(
                            color: chatRightTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
                timeWidget(star, timeStamp, read, chatRightTextColor, id)
              ],
            ),
            onPressed: () {
              _launchURL(
                content,
              );
            },
            padding: EdgeInsets.all(0),
          )),
    );
  }

  Widget myVoiceWidget(CustomClipper clipper, chatRightColor,
      chatRightTextColor, content, star, timeStamp, read, index, id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(top: 10, bottom: 12, left: 5, right: 12),
      backGroundColor: chatRightColor,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: PlayerWidget(url: content),
              ),
              timeWidget(star, timeStamp, read, chatRightTextColor, id)
            ],
          )),
    );
  }

  Widget myLocationWidget(
      CustomClipper clipper,
      chatRightColor,
      chatRightTextColor,
      content,
      star,
      timeStamp,
      read,
      index,
      lat,
      long,
      id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      padding: id == userID
          ? EdgeInsets.only(top: 5, bottom: 12, left: 5, right: 12)
          : EdgeInsets.only(top: 5, bottom: 12, left: 12, right: 5),
      backGroundColor: chatRightColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        // ignore: deprecated_member_use
        child: FlatButton(
          child: Stack(
            children: [
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(appColorBlue),
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
                      imageUrl:
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSX2G4R17Q2SpAVqRDQNcRmHw_8y0uCk2PW4A&usqp=CAU",
                      width: 70.0,
                      height: 70.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: chatRightTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                ],
              ),
              timeWidget(star, timeStamp, read, chatRightTextColor, id)
            ],
          ),
          onPressed: () {
            MapsLauncher.launchCoordinates(
                double.parse(lat), double.parse(long), 'Location');
          },
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  Widget myContactWidget(CustomClipper clipper, chatRightColor,
      chatRightTextColor, content, star, timeStamp, read, index, contact, id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      padding: id == userID
          ? EdgeInsets.only(top: 5, bottom: 12, left: 5, right: 12)
          : EdgeInsets.only(top: 5, bottom: 12, left: 12, right: 5),
      backGroundColor: chatRightColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        // ignore: deprecated_member_use
        child: FlatButton(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Row(
                  children: [
                    Container(width: 5),
                    CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          content[0],
                          style: TextStyle(
                              color: chatRightColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content,
                          maxLines: 1,
                          style: TextStyle(
                              color: chatRightTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 3,
                        ),
                        Text(
                          contact,
                          maxLines: 1,
                          style: TextStyle(
                              color: chatRightTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              timeWidget(star, timeStamp, read, chatRightTextColor, id)
            ],
          ),
          onPressed: () {},
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  Widget myReplyWidget(
      CustomClipper clipper,
      chatRightColor,
      chatRightTextColor,
      content,
      star,
      timeStamp,
      read,
      index,
      lat,
      long,
      contact,
      replyTime,
      contentType,
      id) {
    return ChatBubble(
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      padding: id == userID
          ? EdgeInsets.only(top: 5, bottom: 12, left: 5, right: 12)
          : EdgeInsets.only(top: 5, bottom: 12, left: 12, right: 5),
      backGroundColor: chatRightColor,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  if (replyTime != null) {
                    for (int i = 0; i < chatMsgList.length; i++) {
                      if (chatMsgList[i]["timestamp"] == replyTime) {
                        gotoindex = i;
                        _scrollToIndex(gotoindex);
                      }
                    }
                  }
                },
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: id == userID
                                      ? appColorWhite
                                      : Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, top: 8, bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lat,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    replyTime == 1
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, right: 15, bottom: 5),
                                            child: InkWell(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    width: 30.0,
                                                    height: 30.0,
                                                    padding: EdgeInsets.all(0),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE8E8E8),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                appColorBlue),
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Material(
                                                    child: Text("Not Avilable"),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                                  imageUrl: long,
                                                  height: 200.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            replyTime != null
                                                ? replyTime == 1
                                                    ? "📷 Photo"
                                                    : replyTime == 4
                                                        ? "🎥 Video"
                                                        : replyTime == 5
                                                            ? "📄 Document"
                                                            : replyTime == 6
                                                                ? "🔊 Audio"
                                                                : long
                                                : long,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: contentType != null && contentType == 1
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewImages(
                                                          images: [contentType],
                                                          number: index)),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 30.0,
                                                height: 30.0,
                                                padding: EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE8E8E8),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                ),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            appColorBlue),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Material(
                                                child: Text("Not Avilable"),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                              ),
                                              imageUrl: content,
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : contentType != null && contentType == 5
                                          ? InkWell(
                                              onTap: () {
                                                _launchURL(
                                                  content,
                                                );
                                              },
                                              child: Text(
                                                "FILE_" +
                                                    converTime(timeStamp)
                                                        .substring(converTime(
                                                                    timeStamp)
                                                                .length -
                                                            5)
                                                        .split('')
                                                        .reversed
                                                        .join(''),
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: appColorBlack,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ))
                                          : contentType != null &&
                                                  contentType == 6
                                              ? Container(
                                                  child: PlayerWidget(
                                                      url: content),
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      content,
                                                      style: TextStyle(
                                                          color:
                                                              chatRightTextColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                      width: 300.0,
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
                ),
              ),
              timeWidget(star, timeStamp, read, chatRightTextColor, id)
            ],
          )),
    );
  }

  Widget timeWidget(star, timeStamp, read, chatRightTextColor, id) {
    return Positioned(
      right: 4,
      bottom: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          star != null && star.contains(userID)
              ? Icon(
                  Icons.star,
                  size: 17,
                )
              : Container(),
          Text(
            readTimestamp(
              DateTime.parse(
                converTime(timeStamp),
              ).millisecondsSinceEpoch,
            ),
            style: TextStyle(
                color: chatRightTextColor,
                fontSize: 12.0,
                fontStyle: FontStyle.normal),
          ),
          Container(width: 3),
          id == userID
              ? read == true
                  ? Icon(
                      Icons.done_all,
                      size: 17,
                      color: Colors.blue,
                    )
                  : Icon(
                      Icons.done_all,
                      size: 17,
                      color: chatRightTextColor,
                    )
              : Container(),
          Container(width: 5),
        ],
      ),
    );
  }

  Widget imageWidget() {
    return StreamBuilder(
      stream: firebase.FirebaseDatabase.instance
          .reference()
          .child('user')
          .child(widget.peerID)
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          peerUrl = snapshot.data.snapshot.value["img"];
          return snapshot.data.snapshot.value["img"].length > 0 &&
                  snapshot.data.snapshot.value["profileseen"] != "nobody"
              ? Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: customImage(snapshot.data.snapshot.value["img"]),
                  ))
              : Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      "assets/images/user.png",
                      height: 10,
                      color: Colors.white,
                    ),
                  ));
        }
        return CupertinoActivityIndicator();
      },
    );
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != userID) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> onSendMessage(String content, int type, String contact,
      String lat, String long, var replyTime, int contentType) async {
    // 0 = text
    // 1 = image
    // 2 = sticker
    // 4 = video
    // 5 = file
    // 6 = audio
    // 7 = contact
    // 8 = location
    // 9 = reply
    if (internet == true) {
      var timeStamp;
      if (blocksId.contains(peerID)) {
        unBlockMenu(context);
      } else {
        setState(() {
          isButtonEnabled = false;
          if (type == 1) {
            localImage.add(content);
            preferences.setStringList("localImage", localImage);
          }
        });
        int badgeCount = 0;
        print(content);
        if (content.trim() != '') {
          textEditingController.clear();
          setState(() {
            timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
          });

          await Firestore.instance
              .collection('messages')
              .document(groupChatId)
              .collection(groupChatId)
              .document(timeStamp)
              .setData(
            {
              'idFrom': userID,
              'idTo': peerID,
              'fromName': globalName,
              'toName': peerName,
              'fromMob': mobNo,
              'toMob': peerMobile,
              'timestamp': FieldValue.serverTimestamp(),
              'content': content,
              'contact': contact,
              'type': type,
              "read": false,
              "delete": [],
              "lat": lat,
              "long": long,
              "replyType": replyType,
              "replyTime": replyTime,
              "contentType": contentType
            },
          ).then((onValue) async {
            await Firestore.instance
                .collection("chatList")
                .document(userID)
                .collection(userID)
                .document(peerID)
                .setData({
              'id': peerID,
              'name': peerName,
              'timestamp': widget.pin != null && widget.pin.length > 0
                  ? widget.pin
                  : timeStamp,
              'pin':
                  widget.pin != null && widget.pin.length > 0 ? timeStamp : '',
              'content': content,
              'badge': '0',
              'profileImage': peerUrl,
              'type': type,
              'archive': widget.archive != null ? widget.archive : false,
            }, merge: true).then((onValue) async {
              try {
                await Firestore.instance
                    .collection("chatList")
                    .document(peerID)
                    .collection(peerID)
                    .document(userID)
                    .get()
                    .then((doc) async {
                  if (doc.data["mute"] != null && doc.data["mute"] != true) {
                    if (type == 1) {
                      sendImageNotification(peerToken, content);
                    } else if (type == 4) {
                      sendVideoNotification(peerToken, content);
                    } else if (type == 5) {
                      sendFileNotification(peerToken, content);
                    } else if (type == 6) {
                      sendAudioNotification(peerToken, content);
                    } else {
                      sendNotification(peerToken, content);
                    }
                  }
                  if (doc.data["badge"] != null) {
                    badgeCount = int.parse(doc.data["badge"]);
                    await Firestore.instance
                        .collection("chatList")
                        .document(peerID)
                        .collection(peerID)
                        .document(userID)
                        .setData({
                      'id': userID,
                      'name': globalName,
                      'timestamp': widget.pin != null && widget.pin.length > 0
                          ? widget.pin
                          : timeStamp,
                      'pin': widget.pin != null && widget.pin.length > 0
                          ? timeStamp
                          : '',
                      'content': content,
                      'badge': '${badgeCount + 1}',
                      'profileImage': globalImage,
                      'type': type,
                      'archive':
                          widget.archive != null ? widget.archive : false,
                    }, merge: true);
                  }
                });
              } catch (e) {
                await Firestore.instance
                    .collection("chatList")
                    .document(peerID)
                    .collection(peerID)
                    .document(userID)
                    .setData({
                  'id': userID,
                  'name': globalName,
                  'timestamp': widget.pin != null && widget.pin.length > 0
                      ? widget.pin
                      : timeStamp,
                  'pin': widget.pin != null && widget.pin.length > 0
                      ? timeStamp
                      : '',
                  'content': content,
                  'badge': '${badgeCount + 1}',
                  'profileImage': globalImage,
                  'type': type,
                  'archive': widget.archive != null ? widget.archive : false,
                }, merge: true);
              }
            });
          });

          // if (widget.mute == false) {
          //   String notificationPayload =
          //       "{\"to\":\"${peerToken}\",\"priority\":\"high\",\"data\":{\"type\":\"100\",\"user_id\":\"${widget.currentuser}\",\"user_name\":\"${widget.currentusername}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"msg\":\"${content}\",\"time\":\"${DateTime.now().millisecondsSinceEpoch}\"},\"notification\":{\"title\":\"${widget.currentusername}\",\"body\":\"$content\",\"user_id\":\"${widget.currentuser}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"sound\":\"default\"},\"priority\":\"high\"}";
          //   createNotification(notificationPayload);
          //   // listScrollController.animateTo(0.0,
          //   //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          // }

        } else {}
      }
    }
  }

  Widget buildInput() {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: deviceHeight,
          decoration: BoxDecoration(
            color: replyButton == true ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                replyButton == true
                    ? Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 5, top: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
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
                                    child: Text(replyMsg,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                  Container(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                CupertinoIcons.clear_circled,
                                color: Colors.black45,
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() {
                                  replyButton = false;
                                });
                              },
                            ),
                            // Container(width: 20),
                          ],
                        ),
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    record == false
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: IconButton(
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                _settingModalBottomSheet(context);
                              },
                              icon: Transform.rotate(
                                angle: 180 * math.pi / 110,
                                child: Icon(
                                  Icons.attachment,
                                  color: appColorGrey,
                                  size: 30,
                                ),
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
                              // height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: appColorWhite,
                              ),
                              child: TextField(
                                focusNode: textFieldFocusNode,
                                controller: textEditingController,
                                minLines: 1,
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                onChanged: (val) {
                                  _onChangeHandler(val);
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
                                      vertical: 10, horizontal: 10),
                                  border: InputBorder.none,
                                  hintText: 'Type a Message',
                                  hintStyle: TextStyle(
                                      color: appColorGrey, fontSize: 12),
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
                                    StopWatchTimer.getDisplayTime(value,
                                        hours: false,
                                        second: true,
                                        milliSecond: false,
                                        minute: true);
                                return Text(
                                  displayTime,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                    record == false && isButtonEnabled == false
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: IconButton(
                              padding: EdgeInsets.all(0.0),
                              onPressed: () async {
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
                                    if (replyButton == true) {
                                      onSendMessage(
                                          gif.images.original.url,
                                          9,
                                          '',
                                          replyName,
                                          replyMsg,
                                          replyTime,
                                          1);
                                      setState(() {
                                        replyButton = false;
                                      });
                                    } else {
                                      onSendMessage(gif.images.original.url, 1,
                                          '', '', '', '', 1);
                                    }

                                    print(gif.images.original.url);
                                  });
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.smiley,
                                color: appColorGrey,
                                size: 28,
                              ),
                            ),
                          )
                        : Container(),
                    record == false
                        ? isButtonEnabled == true
                            ? IconButton(
                                onPressed: () {
                                  if (replyButton == true) {
                                    onSendMessage(textEditingController.text, 9,
                                        '', replyName, replyMsg, replyTime, 0);
                                    setState(() {
                                      replyButton = false;
                                    });
                                  } else {
                                    onSendMessage(textEditingController.text, 0,
                                        '', '', '', '', 0);
                                  }
                                },
                                icon: Icon(
                                  CupertinoIcons.paperplane_fill,
                                  size: 27,
                                  color: appColorGrey,
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  getImageFromCam();
                                },
                                icon: Icon(
                                  CupertinoIcons.camera,
                                  color: appColorGrey,
                                  size: 25,
                                ),
                              )
                        : Expanded(
                            child: InkWell(
                            onTap: () {
                              _cancle();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 14, bottom: 13),
                              child: Text(
                                "Cancel",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                    button == false
                        ? isButtonEnabled == false
                            ? GestureDetector(
                                onLongPress: () {
                                  // _init();
                                  _stopWatchTimer.onExecute
                                      .add(StopWatchExecute.reset);

                                  _stopWatchTimer.onExecute
                                      .add(StopWatchExecute.start);
                                  _start();
                                },
                                onLongPressUp: () {
                                  _stop();
                                },
                                onTap: () {
                                  Toast.show("Hold to record", context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, left: 4),
                                    child: Icon(CupertinoIcons.mic,
                                        color: appColorGrey, size: 26)),
                              )
                            : Container()
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
                                  if (replyButton == true) {
                                    onSendMessage(fileUrl, 9, '', replyName,
                                        replyMsg, replyTime, 6);
                                    setState(() {
                                      replyButton = false;
                                    });
                                  } else {
                                    onSendMessage(
                                        fileUrl, 6, '', '', '', '', 6);
                                  }

                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              icon: Icon(CupertinoIcons.paperplane_fill,
                                  size: 27, color: appColorGrey),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        builder: (BuildContext context) {
          return Container(
            height: 120,
            child: Column(
              children: <Widget>[
                Container(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        getImage();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.image,
                            color: appColorGrey,
                          ),
                          Text(
                            ' Photo',
                            maxLines: 1,
                            style: TextStyle(
                                color: appColorGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        _pickVideo();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.video_call,
                            color: appColorGrey,
                          ),
                          Text(
                            ' Video',
                            maxLines: 1,
                            style: TextStyle(
                                color: appColorGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _openFileExplorer();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: appColorGrey,
                          ),
                          Text(
                            'Documents',
                            maxLines: 1,
                            style: TextStyle(
                                color: appColorGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                    Container(
                      width: 30,
                    ),
                  ],
                ),
                Container(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
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
                            if (replyButton == true) {
                              onSendMessage(gif.images.original.url, 9, '',
                                  replyName, replyMsg, replyTime, 1);
                              setState(() {
                                replyButton = false;
                              });
                            } else {
                              onSendMessage(gif.images.original.url, 1, '', '',
                                  '', '', 1);
                            }

                            print(gif.images.original.url);
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.sticky_note_2_rounded,
                            color: appColorGrey,
                          ),
                          Text(
                            ' GIF',
                            maxLines: 1,
                            style: TextStyle(
                                color: appColorGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                    Expanded(
                        child: InkWell(
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
                          if (replyButton == true) {
                            onSendMessage(
                              result.formattedAddress.toString(),
                              9,
                              '',
                              replyName,
                              replyMsg,
                              replyTime,
                              8,
                            );
                            setState(() {
                              replyButton = false;
                            });
                          } else {
                            onSendMessage(
                              result.formattedAddress.toString(),
                              8,
                              '',
                              result.latLng.latitude.toString(),
                              result.latLng.longitude.toString(),
                              '',
                              8,
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: appColorGrey,
                          ),
                          Text(
                            ' Location',
                            maxLines: 1,
                            style: TextStyle(
                                color: appColorGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return StatefulBuilder(builder:
                                  (BuildContext context,
                                      StateSetter setState1) {
                                return DraggableScrollableSheet(
                                  initialChildSize: 0.8,
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Cancel",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color:
                                                                appColorBlue),
                                                      )),
                                                  Text(
                                                    "Share Contacts",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        color: Colors.black),
                                                  ),
                                                  toSendname.length > 0
                                                      ? InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);

                                                            for (var i = 0;
                                                                i <
                                                                    toSendphone
                                                                        .length;
                                                                i++) {
                                                              if (replyButton ==
                                                                  true) {
                                                                onSendMessage(
                                                                  toSendname[i],
                                                                  9,
                                                                  toSendphone[
                                                                      i],
                                                                  replyName,
                                                                  replyMsg,
                                                                  replyTime,
                                                                  7,
                                                                );
                                                                setState(() {
                                                                  replyButton =
                                                                      false;
                                                                });
                                                              } else {
                                                                onSendMessage(
                                                                    toSendname[
                                                                        i],
                                                                    7,
                                                                    toSendphone[
                                                                        i],
                                                                    '',
                                                                    '',
                                                                    '',
                                                                    7);
                                                              }
                                                            }
                                                            setState1(() {
                                                              toSendname
                                                                  .clear();
                                                              toSendphone
                                                                  .clear();
                                                            });
                                                          },
                                                          child: Text(
                                                            "Send",
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                color:
                                                                    appColorBlue),
                                                          ))
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 15),
                                                          child: Text("   "),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: ListView.builder(
                                            itemCount: allcontacts.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return allcontacts != null
                                                  ? Column(
                                                      children: <Widget>[
                                                        new Divider(
                                                          height: 1,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  new ListTile(
                                                                onTap: () {},
                                                                leading:
                                                                    new Stack(
                                                                  children: <
                                                                      Widget>[
                                                                    CircleAvatar(
                                                                        backgroundColor:
                                                                            Colors.grey[
                                                                                300],
                                                                        child:
                                                                            Text(
                                                                          allcontacts[index].displayName != null
                                                                              ? allcontacts[index].displayName[0]
                                                                              : "?",
                                                                          style: TextStyle(
                                                                              color: Colors.green,
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold),
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
                                                                      allcontacts[index]
                                                                              .displayName ??
                                                                          "",
                                                                      style: new TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                                subtitle:
                                                                    new Container(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 5.0),
                                                                  child:
                                                                      new Row(
                                                                    children: [
                                                                      Text(
                                                                        allcontacts[index]
                                                                            .phones
                                                                            .map((e) =>
                                                                                e.value)
                                                                            .toString(),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            toSendphone.contains(allcontacts[
                                                                        index]
                                                                    .phones
                                                                    .map((e) =>
                                                                        e.value)
                                                                    .toString())
                                                                ? Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            20),
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          setState1(
                                                                              () {
                                                                            toSendphone.remove(allcontacts[index].phones.map((e) => e.value).toString());
                                                                            toSendname.remove(allcontacts[index].displayName);
                                                                          });
                                                                        },
                                                                        child: Icon(Icons.check_circle)),
                                                                  )
                                                                : Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            20),
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          setState1(
                                                                              () {
                                                                            toSendphone.add(allcontacts[index].phones.map((e) => e.value).toString());
                                                                            toSendname.add(allcontacts[index].displayName);
                                                                          });
                                                                        },
                                                                        child: Icon(Icons.radio_button_unchecked)),
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
                      child: Row(
                        children: [
                          Icon(
                            Icons.contacts,
                            color: appColorGrey,
                          ),
                          Text(
                            ' Contacts',
                            maxLines: 1,
                            style: TextStyle(
                                color: appColorGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                    Container(
                      width: 30,
                    ),
                  ],
                ),
                Container(height: 20),
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

  // Widget buildFilterCloseButton(BuildContext context) {
  //   return Align(
  //     alignment: Alignment.topLeft,
  //     child: Material(
  //       color: Colors.black.withOpacity(0.0),
  //       child: Padding(
  //         padding: const EdgeInsets.all(18.0),
  //         child: IconButton(
  //           icon: Icon(
  //             Icons.close,
  //             color: Colors.white,
  //           ),
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                  star.contains(userID)
                      ? InkWell(
                          onTap: () {
                            var data = [];
                            data.addAll(star);
                            data.remove(userID);

                            Firestore.instance
                                .collection('messages')
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
                                      .child(time.toString() + userID)
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
                            setState(() {
                              star.add(userID);
                            });
                            Firestore.instance
                                .collection('messages')
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
                                        userID,
                                        peerData.value['name'],
                                        idFrom,
                                        idTo,
                                        peerData.value['img'],
                                        content,
                                        time.toString(),
                                        type.toString());

                                    var orderRef = database
                                        .reference()
                                        .child("star")
                                        .child(time.toString() + userID);
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
                  SizedBox(
                    height: 5.0,
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
                        deleteMsgID.clear();
                        deleteMsgContent.clear();
                        deleteButton = true;
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

  unBlockMenu(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Unblock",
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              unBlockCall();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
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

  unBlockCall() {
    blocksId.remove(peerID);
    firebase.DatabaseReference _userRef = database.reference().child('block');
    _userRef.child(userID).update({
      "id": blocksId,
    }).then((_) {
      setState(() {});
    });
  }

  getBlockId() {
    database.reference().child('block').child(userID).once().then((userData) {
      if (userData.value != null) {
        var data = userData.value['id'];
        setState(() {
          blocksId.addAll(data);
        });
      }
    });

    database.reference().child('block').child(peerID).once().then((userData) {
      if (userData.value != null) {
        var data = userData.value['id'];
        setState(() {
          peerblocksId.addAll(data);
        });
      }
    });
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

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    chatMsgList.forEach((userDetail) {
      if (userDetail['content'].toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }

  checkprofilrPrivacy() {
    database
        .reference()
        .child('user')
        .child(widget.peerID)
        .once()
        .then((peerData) {
      setState(() {
        profilrPrivacy = peerData.value['profileseen'];
      });
    });
  }

  checklastSeenPrivacy() {
    database
        .reference()
        .child('user')
        .child(widget.peerID)
        .once()
        .then((peerData) {
      setState(() {
        lastSeenPrivacy = peerData.value['lastseen'];
      });
    });
  }

  // setdata() async {
  //   print(groupChatId);
  //   await Firestore.instance
  //       .collection('messages')
  //       .document(groupChatId)
  //       .collection(groupChatId)
  //       .orderBy('timestamp', descending: true)
  //       .getDocuments(source: Source.cache);
  // }

  // getSaved() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   if (preferences.containsKey("chat")) {
  //     List<dynamic> userMap = jsonDecode(preferences.getString("chat"));
  //     msgList.clear();
  //     msgList.addAll(userMap);
  //     print(msgList);
  //     setState(() {
  //       offline = true;
  //     });
  //   }
  // }

  openDeleteDialog(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          deleteMsgID.contains(peerID)
              ? Container()
              : CupertinoActionSheetAction(
                  child: Text(
                    "Delete For Everyone",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontFamily: "MontserratBold"),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop("Discard");
                    setState(() {
                      deleteButton = false;
                    });

                    for (var i = 0; i < deleteMsgTime.length; i++) {
                      Firestore.instance
                          .collection('messages')
                          .document(groupChatId)
                          .collection(groupChatId)
                          .where("timestamp", isEqualTo: deleteMsgTime[i])
                          .getDocuments()
                          .then((querySnapshot) async {
                        querySnapshot.documents.forEach((documentSnapshot) {
                          documentSnapshot.reference.updateData({
                            "delete": FieldValue.arrayUnion([userID, peerID])
                          });
                        });

                        await Firestore.instance
                            .collection("chatList")
                            .document(userID)
                            .collection(userID)
                            .document(peerID)
                            .get()
                            .then((doc) async {
                          if (deleteMsgTime[i] == doc.data["timestamp"]) {
                            await Firestore.instance
                                .collection("chatList")
                                .document(userID)
                                .collection(userID)
                                .document(peerID)
                                .updateData(
                                    {'content': "you deleted this message"});
                          }
                        }).then((value) async {
                          await Firestore.instance
                              .collection("chatList")
                              .document(peerID)
                              .collection(peerID)
                              .document(userID)
                              .updateData(
                                  {'content': "This message was deleted"});
                        });

                        // StorageReference photoRef = await FirebaseStorage
                        //     .instance
                        //     .getReferenceFromUrl(deleteMsgContent[i]);

                        // await photoRef.delete();
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

              setState(() {
                deleteButton = false;
              });

              for (var i = 0; i <= deleteMsgTime.length; i++) {
                Firestore.instance
                    .collection('messages')
                    .document(groupChatId)
                    .collection(groupChatId)
                    .where("timestamp", isEqualTo: deleteMsgTime[i])
                    .getDocuments()
                    .then((querySnapshot) async {
                  querySnapshot.documents.forEach((documentSnapshot) {
                    documentSnapshot.reference.updateData({
                      "delete": FieldValue.arrayUnion([userID])
                    });
                  });

                  if (deleteMsgTime[i] == widget.chatListTime) {
                    await Firestore.instance
                        .collection("chatList")
                        .document(userID)
                        .collection(userID)
                        .document(peerID)
                        .updateData({'content': "you deleted this message"});
                  }

                  // StorageReference photoRef = await FirebaseStorage.instance
                  //     .getReferenceFromUrl(deleteMsgContent[i]);

                  // await photoRef.delete();
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

                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      "Send",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(color: appColorBlue),
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
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 10, left: 10),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(15.0),
                                            )),
                                        height: 40,
                                        child: Center(
                                          child: TextField(
                                            controller: forwardController,
                                            onChanged: (val) {
                                              setState1(() {});
                                            },
                                            style:
                                                TextStyle(color: Colors.grey),
                                            decoration: new InputDecoration(
                                              border: new OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.grey[200]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                              ),
                                              filled: true,
                                              hintStyle: new TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14),
                                              hintText: "Search",
                                              contentPadding:
                                                  EdgeInsets.only(top: 10.0),
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

  forwardUsersWidget(setState1) {
    return FutureBuilder(
      future:
          firebase.FirebaseDatabase.instance.reference().child("user").once(),
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
                      userID != lists[index]["userId"]
                  ? lists[index]["name"].contains(new RegExp(
                          forwardController.text,
                          caseSensitive: false))
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
                                                backgroundImage:
                                                    new NetworkImage(
                                                        lists[index]["img"]),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                      ],
                                    ),
                                    title: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          getContactName(
                                              lists[index]["mobile"]),
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
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
                                        forwardMsgId
                                            .add(lists[index]["userId"]);
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
                      : forwardController.text.isEmpty
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
                                                    lists[index]["img"].length >
                                                        0)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    backgroundImage:
                                                        new NetworkImage(
                                                            lists[index]
                                                                ["img"]),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: Text(
                                                      "",
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                          ],
                                        ),
                                        title: Text(
                                          getContactName(
                                              lists[index]["mobile"]),
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: new Container(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
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
                                              forwardMsgId.remove(
                                                  lists[index]["userId"]);
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
                                            forwardMsgId
                                                .add(lists[index]["userId"]);
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
                          : Container()
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
      future:
          firebase.FirebaseDatabase.instance.reference().child("group").once(),
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
              return lists[index]["userId"].contains(userID)
                  ? lists[index]["castName"].contains(new RegExp(
                          forwardController.text,
                          caseSensitive: false))
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
                                                lists[index]["castImage"]
                                                        .length >
                                                    0)
                                            ? CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                backgroundImage:
                                                    new NetworkImage(
                                                        lists[index]
                                                            ["castImage"]),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                          groupMsgUserId.remove(jsonEncode(
                                              lists[index]["userId"]));
                                          groupMsgPeerName
                                              .remove(lists[index]["castName"]);
                                          groupMsgPeerImage.remove(
                                              lists[index]["castImage"]);
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
                      : forwardController.text.isEmpty
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
                                            (lists[index]["castImage"] !=
                                                        null &&
                                                    lists[index]["castImage"]
                                                            .length >
                                                        0)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    backgroundImage:
                                                        new NetworkImage(
                                                            lists[index]
                                                                ["castImage"]),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: Text(
                                                      "",
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
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
                                              groupMsgUserId.remove(jsonEncode(
                                                  lists[index]["userId"]));
                                              groupMsgPeerName.remove(
                                                  lists[index]["castName"]);
                                              groupMsgPeerImage.remove(
                                                  lists[index]["castImage"]);
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
                                            groupMsgUserId.add(jsonEncode(
                                                lists[index]["userId"]));
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
                          : Container()
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

      if (userID.hashCode <= peerID2.hashCode) {
        groupChatId = userID + "-" + peerID2;
      } else {
        groupChatId = peerID2 + "-" + userID;
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
            'idFrom': userID,
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
            .document(userID)
            .collection(userID)
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
                .document(userID)
                .get()
                .then((doc) async {
              debugPrint(doc.data["badge"]);
              if (doc.data["badge"] != null) {
                badgeCount = int.parse(doc.data["badge"]);
                await Firestore.instance
                    .collection("chatList")
                    .document(peerID2)
                    .collection(peerID2)
                    .document(userID)
                    .setData({
                  'id': userID,
                  'name': globalName,
                  'timestamp': widget.pin != null && widget.pin.length > 0
                      ? widget.pin
                      : DateTime.now().millisecondsSinceEpoch.toString(),
                  'content': content,
                  'badge': '${badgeCount + 1}',
                  'profileImage': globalImage,
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
                .document(userID)
                .setData({
              'id': userID,
              'name': globalName,
              'timestamp': widget.pin != null && widget.pin.length > 0
                  ? widget.pin
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              'content': content,
              'badge': '${badgeCount + 1}',
              'profileImage': globalImage,
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
          'idFrom': userID,
          'fromName': globalName,
          'idTo': groupMsgId,
          'timestamp': FieldValue.serverTimestamp(),
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

    print(localImage);
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

//    String path = await ExtStorage.getExternalStoragePublicDirectory(
//     ExtStorage.DIRECTORY_DOWNLOADS);
// print(path);
      var time = DateTime.now().millisecondsSinceEpoch.toString();
      await dio.download(url, "/sdcard/download/" + "$time." + "$testrt",
          onReceiveProgress: (rec, total) {
        // setState(() {
        //   int percentage = ((rec / total) * 100).floor();
        //   totalData = percentage.toString();
        //   print(percentage);
        // });
      }).then((value) {
        print("👉🏿👉🏿👉🏿👉🏿👉🏿👉🏿👉🏿👉🏿");
        // setState(() {
        //   //isDownloading = false;
        //   Toast.show("Download successfully", context,
        //       duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        // });
      });
    } catch (e) {
      setState(() {
        //isDownloading = false;
        Toast.show("Download Failed!", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      });
    }
  }
}

List _searchResult = [];

List msgList = [];
