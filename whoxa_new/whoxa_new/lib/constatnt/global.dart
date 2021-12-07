import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/main.dart';
import 'package:flutterwhatsappclone/models/callModal.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String appName = 'Whoxa';
List<CallModal> callList;
const Color appColorBlue = Color(0XFF349df9);
Color chatLeftColor2 = Colors.grey[300];
Color chatLeftColor = Colors.white;
Color chatLeftTextColor = Colors.black45;
Color chatRightColor = Color(0XFF349df9);
Color chatRightTextColor = Colors.white;

const Color appColorBlack = Color(0xFF000000);
const Color drawerBackColor = Color(0XFFfcfcfc);
const Color appColorGreen = Color(0XFF4354AE);

const Color appColor = Color(0xFF34C759);
const Color appColorWhite = Colors.white;
const Color appColorGrey = Colors.grey;

const Color chatReplyRightColor = Color(0XFFcee8ba);

String normalStyle = 'Montserrat';

String boldFamily = 'MontserratBold';

const Color settingColoryellow = Color(0xFFf6cd00);
const Color settingColorGreen = Color(0xFFf00aca6);
const Color settingColorBlue = Color(0xFF007dff);
const Color settingColorRed = Color(0xFFff3429);
const Color settingColorpink = Color(0xFFff2b54);
const Color settingColorChat = Color(0xFF47d86a);

const Color callColor1 = Color(0XFF738464);
const Color callColor2 = Color(0XFF9b7573);
SharedPreferences preferences;
String userID = '';
String mobNo = '';
String cCode = '';
String fullMob = '';
String globalName = '';
String globalImage = '';
String serverKey =
    "AAAAtz1dk74:APA91bEmx46v0mVgHxpD5yi3rGKM4kK8xMM-XpgyKUEqYOdN2TdNwHMQOi0kPulQ5b9glR36X-FRPzufkNB30bUo8PIwOWSn1-uRVm2jZ1JOgOF3ASe8bGjbUiA99fz24PZS5a6IoEcY";
String noImage =
    'https://www.searchpng.com/wp-content/uploads/2019/02/Deafult-Profile-Pitcher.png';

String videoImage =
    'https://old.dpsu.gov.ua/templates/scms_default/images/noVideo.jpg';

// List<Contact> mobContacts;
var mobileContacts = [];
List<Contact> allcontacts;
List<String> localImage = [];
var savedContactUserId = [];

class CustomText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final Alignment alignment;
  final String fontFamily;

  const CustomText(
      {Key key,
      this.text,
      this.color,
      this.fontSize,
      this.fontWeight,
      this.alignment,
      this.fontFamily})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: alignment,
        child: Text(' $text',
            style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: fontWeight,
                fontFamily: fontFamily)));
  }
}

class CustomButtom extends StatelessWidget {
  final Color color;
  final String title;
  final Function onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final BorderRadius borderRadius;
  final String fontFamily;
  CustomButtom(
      {this.color,
      this.title,
      this.onPressed,
      this.fontSize,
      this.fontWeight,
      this.textColor,
      this.borderRadius,
      this.fontFamily});
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return RaisedButton(
      color: color,
      child: Text(
        title,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
            fontFamily: fontFamily),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      onPressed: onPressed,
    );
  }
}

Widget loader() {
  return Container(
    height: 60,
    width: 60,
    padding: EdgeInsets.all(15.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), color: Colors.transparent),
    child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
  );
}

// ignore: must_be_immutable
class CustomtextField extends StatefulWidget {
  final TextInputType keyboardType;
  final Function onTap;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final Function onEditingComplate;
  final Function onSubmitted;
  final dynamic controller;
  final int maxLines;
  final dynamic onChange;
  final String errorText;
  final String hintText;
  final String labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget suffixIcon;

  final Widget prefixIcon;
  CustomtextField({
    this.keyboardType,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplate,
    this.onSubmitted,
    this.controller,
    this.maxLines,
    this.onChange,
    this.errorText,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  _CustomtextFieldState createState() => _CustomtextFieldState();
}

class _CustomtextFieldState extends State<CustomtextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: TextStyle(
          color: Colors.black, fontFamily: 'Montserrat', fontSize: 14),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
        errorStyle: TextStyle(color: Colors.black),
        errorText: widget.errorText,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        hintText: widget.hintText,
        focusColor: Colors.black,
        labelStyle: TextStyle(color: Colors.black),
        hintStyle: TextStyle(
            color: Colors.grey[600], fontFamily: "Montserrat", fontSize: 13),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: appColorGreen, width: 1.8),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.5),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomtextField3 extends StatefulWidget {
  final TextInputType keyboardType;
  final Function onTap;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final Function onEditingComplate;
  final Function onSubmitted;
  final dynamic controller;
  final int maxLines;
  final dynamic onChange;
  final String errorText;
  final String hintText;
  final String labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget suffixIcon;
  final textAlign;

  final Widget prefixIcon;
  CustomtextField3(
      {this.keyboardType,
      this.onTap,
      this.focusNode,
      this.textInputAction,
      this.onEditingComplate,
      this.onSubmitted,
      this.controller,
      this.maxLines,
      this.onChange,
      this.errorText,
      this.hintText,
      this.labelText,
      this.obscureText = false,
      this.readOnly = false,
      this.autoFocus = false,
      this.prefixIcon,
      this.suffixIcon,
      this.textAlign});

  @override
  _CustomtextFieldState3 createState() => _CustomtextFieldState3();
}

class _CustomtextFieldState3 extends State<CustomtextField3> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: widget.textAlign,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: false,
        //  fillColor: Colors.black.withOpacity(0.5),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        errorStyle: TextStyle(color: Colors.white),
        errorText: widget.errorText,

        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        hintText: widget.hintText,
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),

        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        // focusedBorder: OutlineInputBorder(
        //   borderSide: BorderSide(color: Colors.white, width: 1.8),
        //   borderRadius: BorderRadius.circular(10),
        // ),
        // enabledBorder: OutlineInputBorder(
        //   borderSide: BorderSide(color: Colors.white, width: 0.5),
        //   borderRadius: BorderRadius.circular(10),
        // ),
      ),
    );
  }
}

Future getContactsFromGloble() async {
  var getContacts = [];
  var newgetContacts = [];

  var contacts = (await ContactsService.getContacts(
          withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
      .toList();

  allcontacts = contacts;
  if (allcontacts != null) {
    print("TOTAL:>>>>>>>>>>>" + allcontacts.length.toString());
    for (int i = 0; i < allcontacts.length; i++) {
      Contact c = allcontacts?.elementAt(i);
      getContacts.add(c.phones.map(
          (e) => e.value.replaceAll(new RegExp(r"\s+\b|\b\s"), "").toString()));
    }
  }
  //print(getContacts);

  for (int i = 0; i < getContacts.length; i++) {
    newgetContacts.add(getContacts[i]
        .toString()
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("+93", "")
        .replaceAll("+358", "")
        .replaceAll("+355", "")
        .replaceAll("+213", "")
        .replaceAll("+1", "")
        .replaceAll("+376", "")
        .replaceAll("+244", "")
        .replaceAll("+1", "")
        .replaceAll("+1", "")
        .replaceAll("+54", "")
        .replaceAll("+374", "")
        .replaceAll("+297", "")
        .replaceAll("+247", "")
        .replaceAll("+61", "")
        .replaceAll("+672", "")
        .replaceAll("+43", "")
        .replaceAll("+994", "")
        .replaceAll("+1", "")
        .replaceAll("+973", "")
        .replaceAll("+880", "")
        .replaceAll("+1", "")
        .replaceAll("+375", "")
        .replaceAll("+32", "")
        .replaceAll("+501", "")
        .replaceAll("+229", "")
        .replaceAll("+93", "")
        .replaceAll("+355", "")
        .replaceAll("+213", "")
        .replaceAll("+1-684", "")
        .replaceAll("+376", "")
        .replaceAll("+244", "")
        .replaceAll("+1-264", "")
        .replaceAll("+672", "")
        .replaceAll("+1-268", "")
        .replaceAll("+54", "")
        .replaceAll("+374", "")
        .replaceAll("+297", "")
        .replaceAll("+61", "")
        .replaceAll("+43", "")
        .replaceAll("+994", "")
        .replaceAll("+1-242", "")
        .replaceAll("+973", "")
        .replaceAll("+880", "")
        .replaceAll("+1-246", "")
        .replaceAll("+375", "")
        .replaceAll("+32", "")
        .replaceAll("+501", "")
        .replaceAll("+229", "")
        .replaceAll("+1-441", "")
        .replaceAll("+975", "")
        .replaceAll("+591", "")
        .replaceAll("+387", "")
        .replaceAll("+267", "")
        .replaceAll("+55", "")
        .replaceAll("+246", "")
        .replaceAll("+1-284", "")
        .replaceAll("+673", "")
        .replaceAll("+359", "")
        .replaceAll("+226", "")
        .replaceAll("+257", "")
        .replaceAll("+855", "")
        .replaceAll("+237", "")
        .replaceAll("+1", "")
        .replaceAll("+238", "")
        .replaceAll("+1-345", "")
        .replaceAll("+236", "")
        .replaceAll("+235", "")
        .replaceAll("+56", "")
        .replaceAll("+86", "")
        .replaceAll("+61", "")
        .replaceAll("+61", "")
        .replaceAll("+57", "")
        .replaceAll("+269", "")
        .replaceAll("+682", "")
        .replaceAll("+506", "")
        .replaceAll("+385", "")
        .replaceAll("+53", "")
        .replaceAll("+599", "")
        .replaceAll("+357", "")
        .replaceAll("+420", "")
        .replaceAll("+243", "")
        .replaceAll("+45", "")
        .replaceAll("+253", "")
        .replaceAll("+1-767", "")
        .replaceAll("+1-809", "")
        .replaceAll("+1-829", "")
        .replaceAll("+1-849", "")
        .replaceAll("+670", "")
        .replaceAll("+593", "")
        .replaceAll("+20", "")
        .replaceAll("+503", "")
        .replaceAll("+240", "")
        .replaceAll("+291", "")
        .replaceAll("+372", "")
        .replaceAll("+251", "")
        .replaceAll("+500", "")
        .replaceAll("+298", "")
        .replaceAll("+679", "")
        .replaceAll("+358", "")
        .replaceAll("+33", "")
        .replaceAll("+689", "")
        .replaceAll("+241", "")
        .replaceAll("+220", "")
        .replaceAll("+995", "")
        .replaceAll("+49", "")
        .replaceAll("+233", "")
        .replaceAll("+350", "")
        .replaceAll("+30", "")
        .replaceAll("+299", "")
        .replaceAll("+1-473", "")
        .replaceAll("+1-671", "")
        .replaceAll("+502", "")
        .replaceAll("+44-1481", "")
        .replaceAll("+224", "")
        .replaceAll("+245", "")
        .replaceAll("+592", "")
        .replaceAll("+509", "")
        .replaceAll("+504", "")
        .replaceAll("+852", "")
        .replaceAll("+36", "")
        .replaceAll("+354", "")
        .replaceAll("+91", "")
        .replaceAll("+62", "")
        .replaceAll("+98", "")
        .replaceAll("+964", "")
        .replaceAll("+353", "")
        .replaceAll("+44-1624", "")
        .replaceAll("+972", "")
        .replaceAll("+39", "")
        .replaceAll("+225", "")
        .replaceAll("+1-876", "")
        .replaceAll("+81", "")
        .replaceAll("+44-1534", "")
        .replaceAll("+962", "")
        .replaceAll("+7", "")
        .replaceAll("+254", "")
        .replaceAll("+686", "")
        .replaceAll("+383", "")
        .replaceAll("+965", "")
        .replaceAll("+996", "")
        .replaceAll("+856", "")
        .replaceAll("+371", "")
        .replaceAll("+961", "")
        .replaceAll("+266", "")
        .replaceAll("+231", "")
        .replaceAll("+218", "")
        .replaceAll("+423", "")
        .replaceAll("+370", "")
        .replaceAll("+352", "")
        .replaceAll("+853", "")
        .replaceAll("+389", "")
        .replaceAll("+261", "")
        .replaceAll("+265", "")
        .replaceAll("+60", "")
        .replaceAll("+960", "")
        .replaceAll("+223", "")
        .replaceAll("+356", "")
        .replaceAll("+692", "")
        .replaceAll("+222", "")
        .replaceAll("+230", "")
        .replaceAll("+262", "")
        .replaceAll("+52", "")
        .replaceAll("+691", "")
        .replaceAll("+373", "")
        .replaceAll("+377", "")
        .replaceAll("+976", "")
        .replaceAll("+382", "")
        .replaceAll("+1-664", "")
        .replaceAll("+212", "")
        .replaceAll("+258", "")
        .replaceAll("+95", "")
        .replaceAll("+264", "")
        .replaceAll("+674", "")
        .replaceAll("+977", "")
        .replaceAll("+31", "")
        .replaceAll("+599", "")
        .replaceAll("+687", "")
        .replaceAll("+64", "")
        .replaceAll("+505", "")
        .replaceAll("+227", "")
        .replaceAll("+234", "")
        .replaceAll("+683", "")
        .replaceAll("+850", "")
        .replaceAll("+1-670", "")
        .replaceAll("+47", "")
        .replaceAll("+968", "")
        .replaceAll("+92", "")
        .replaceAll("+680", "")
        .replaceAll("+970", "")
        .replaceAll("+507", "")
        .replaceAll("+675", "")
        .replaceAll("+595", "")
        .replaceAll("+51", "")
        .replaceAll("+63", "")
        .replaceAll("+64", "")
        .replaceAll("+48", "")
        .replaceAll("+351", "")
        .replaceAll("+1-787", "")
        .replaceAll("+1-939", "")
        .replaceAll("+974", "")
        .replaceAll("+242", "")
        .replaceAll("+262", "")
        .replaceAll("+40", "")
        .replaceAll("+7", "")
        .replaceAll("+250", "")
        .replaceAll("+590", "")
        .replaceAll("+290", "")
        .replaceAll("+1-869", "")
        .replaceAll("+1-758", "")
        .replaceAll("+590", "")
        .replaceAll("+508", "")
        .replaceAll("+1-784", "")
        .replaceAll("+685", "")
        .replaceAll("+378", "")
        .replaceAll("+239", "")
        .replaceAll("+966", "")
        .replaceAll("+221", "")
        .replaceAll("+381", "")
        .replaceAll("+248", "")
        .replaceAll("+232", "")
        .replaceAll("+65", "")
        .replaceAll("+1-721", "")
        .replaceAll("+421", "")
        .replaceAll("+386", "")
        .replaceAll("+677", "")
        .replaceAll("+252", "")
        .replaceAll("+27", "")
        .replaceAll("+82", "")
        .replaceAll("+211", "")
        .replaceAll("+34", "")
        .replaceAll("+94", "")
        .replaceAll("+249", "")
        .replaceAll("+597", "")
        .replaceAll("+47", "")
        .replaceAll("+268", "")
        .replaceAll("+46", "")
        .replaceAll("+41", "")
        .replaceAll("+963", "")
        .replaceAll("+886", "")
        .replaceAll("+992", "")
        .replaceAll("+255", "")
        .replaceAll("+66", "")
        .replaceAll("+228", "")
        .replaceAll("+690", "")
        .replaceAll("+676", "")
        .replaceAll("+1-868", "")
        .replaceAll("+216", "")
        .replaceAll("+90", "")
        .replaceAll("+993", "")
        .replaceAll("+1-649", "")
        .replaceAll("+688", "")
        .replaceAll("+1-340", "")
        .replaceAll("+256", "")
        .replaceAll("+380", "")
        .replaceAll("+971", "")
        .replaceAll("+44", "")
        .replaceAll("+1", "")
        .replaceAll("+598", "")
        .replaceAll("+998", "")
        .replaceAll("+678", "")
        .replaceAll("+379", "")
        .replaceAll("+58", "")
        .replaceAll("+84", "")
        .replaceAll("+681", "")
        .replaceAll("+212", "")
        .replaceAll("+967", "")
        .replaceAll("+260", "")
        .replaceAll("+263", "")
        .replaceAll(new RegExp(r'^0+(?=.)'), '')
        .replaceFirst(new RegExp(r'^0+'), '')
        .replaceAll("-", "")
        .replaceAll(" ", "")
        .trim()
        .toString());
  }
  //splitMethod(newgetContacts);

  mobileContacts.addAll(newgetContacts);
  print('NEW>>>>>>>>>>>>>>>>>>>>>>');
  print(mobileContacts);
  print('NEW>>>>>>>>>>>>>>>>>>>>>>');

  return newgetContacts;
}

// splitMethod(contact) {
//   contact.forEach((car) {
//     if (car.indexOf(',') > -1) {
//       car.split(',');

//       for (var newData in car.split(',')) {
//         mobileContacts.add(newData);
//       }
//     }
//   });
// }

// Widget admobWidget() {
//   return StreamBuilder(
//     stream: FirebaseDatabase.instance.reference().child('admob').onValue,
//     builder: (context, snapshot) {
//       if (snapshot.hasData && snapshot.data.snapshot.value != null) {
//         return snapshot.data.snapshot.value["status"] != "off"
//             ? Container(
//                 margin: EdgeInsets.only(bottom: 0),
//                 child: AdmobBanner(
//                   adUnitId: snapshot.data.snapshot.value["id"],
//                   //adUnitId: AdmobBanner.testAdUnitId,
//                   adSize: AdmobBannerSize.BANNER,
//                   listener: (AdmobAdEvent event, Map<String, dynamic> args) {},
//                   onBannerCreated: (AdmobBannerController controller) {},
//                 ),
//               )
//             : Container();
//       }
//       return Container();
//     },
//   );
// }

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('h:mma');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0 && diff.inHours < 20) {
    time = format.format(date);
  } else if (diff.inHours >= 20 && diff.inDays < 7) {
    time = DateFormat('EEEE').format(date);
  } else {
    var format = DateFormat('dd/MM/yy');
    time = format.format(date);
  }

  return time;
}

converTime(time) {
  if (time != null) {
    final DateTime dateTimeFromServerTimeStamp = (time as Timestamp).toDate();
    return dateTimeFromServerTimeStamp.toString();
  } else {
    return DateTime.now().toString();
  }
}

Widget customImage(String url) {
  return CachedNetworkImage(
    placeholder: (context, url) => Center(child: CupertinoActivityIndicator()),
    errorWidget: (context, url, error) => Material(
      child: Center(
          child: Icon(
        CupertinoIcons.photo,
        color: Colors.grey,
      )),
      clipBehavior: Clip.hardEdge,
    ),
    imageUrl: url,
    fit: BoxFit.cover,
  );
}

getContactName(mobile) {
  if (allcontacts != null && mobile != null) {
    var name = mobile;
    for (var i = 0; i < allcontacts.length; i++) {
      if (allcontacts[i]
          .phones
          .map((e) => e.value)
          .toString()
          .replaceAll(new RegExp(r"\s+\b|\b\s"), "")
          .contains(mobile)) {
        name = allcontacts[i].displayName;
      }
    }
    return name;
  } else {
    return mobile;
  }
}

Future<http.Response> sendCallNotification(
    String peerToken, String content) async {
  final response = await http.post(
    'https://fcm.googleapis.com/fcm/send',
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "key=$serverKey"
    },
    body: jsonEncode({
      "to": peerToken,
      "priority": "high",
      "data": {
        "type": "100",
        "user_id": userID,
        "title": content,
        "user_pic": globalImage,
        "message": globalName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "sound": "custom.mp3",
        "vibrate": "300",
      },
      "notification": {
        "vibrate": "300",
        "priority": "high",
        "body": content,
        "title": globalName,
        "sound": "custom.mp3",
      }
    }),
  );
  return response;
}

Widget uploadWidget(percentage, _progress, videoStatus) {
  return Center(
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
              center: new Text("${(_progress * 100).toStringAsFixed(0)}%"),
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
  );
}


  Future<http.Response> sendNotification(
      String peerToken, String content) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": content,
          "title": globalName,
          "sound": "default",
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendImageNotification(
      String peerToken, String content) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "image": content,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": "📷 Image",
          "title": globalName,
          "sound": "default",
          "image": content,
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendVideoNotification(
      String peerToken, String content) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": "🎥 Video",
          "title": globalName,
          "sound": "default",
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendFileNotification(
      String peerToken, String content) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": "📄 File",
          "title": globalName,
          "sound": "default",
        }
      }),
    );
    return response;
  }

  Future<http.Response> sendAudioNotification(
      String peerToken, String content) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "key=$serverKey"
      },
      body: jsonEncode({
        "to": peerToken,
        "priority": "high",
        "data": {
          "type": "100",
          "user_id": userID,
          "title": content,
          "message": globalName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "sound": "default",
          "vibrate": "300",
        },
        "notification": {
          "vibrate": "300",
          "priority": "high",
          "body": "🔊 Voice Message",
          "title": globalName,
          "sound": "default",
        }
      }),
    );
    return response;
  }
