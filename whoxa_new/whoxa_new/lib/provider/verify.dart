import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutterwhatsappclone/Screens/createpro.dart';
import 'package:flutterwhatsappclone/Screens/utils/constants.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/provider/countries.dart';
import 'package:flutterwhatsappclone/provider/phone_auth.dart';
import 'package:flutterwhatsappclone/provider/wrong_phone.dart';
import 'package:provider/provider.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:toast/toast.dart';

class PhoneAuthVerify extends StatefulWidget {
  final Color cardBackgroundColor = Color(0xFFFCA967);
  final String logo = Assets.firebase;
  final String appName = "Awesome app";

  @override
  _PhoneAuthVerifyState createState() => _PhoneAuthVerifyState();
}

class _PhoneAuthVerifyState extends State<PhoneAuthVerify> {
  BuildContext scaffoldContext;
  // FocusNode focusNode1 = FocusNode();
  // FocusNode focusNode2 = FocusNode();
  // FocusNode focusNode3 = FocusNode();
  // FocusNode focusNode4 = FocusNode();
  // FocusNode focusNode5 = FocusNode();
  // FocusNode focusNode6 = FocusNode();
  String code = "";
  int endTime;

  @override
  void initState() {
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final phoneAuthDataProvider =
        Provider.of<PhoneAuthDataProvider>(context, listen: false);

    phoneAuthDataProvider.setMethods(
      onStarted: onStarted,
      onError: onError,
      onFailed: onFailed,
      onVerified: onVerified,
      onCodeResent: onCodeResent,
      onCodeSent: onCodeSent,
      onAutoRetrievalTimeout: onAutoRetrievalTimeOut,
    );

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 100.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Center(
                              child: Text(
                                'Enter 6 digits verification code sent to your number',
                                style: TextStyle(
                                    fontSize: 17, fontFamily: "MontserratBold"),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                      ],
                    ),
                    SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WrongPhone()),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Not your phonenumber ?",
                                style: TextStyle(
                                    color: appColorBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Container(height: 5),
                              Text(
                                mobNo,
                                style: TextStyle(
                                    color: appColorBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CountdownTimer(
                          endTime: endTime,
                          widgetBuilder: (BuildContext context,
                              CurrentRemainingTime time) {
                            if (time == null) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      validateMobile(mobNo);
                                    },
                                    child: Text(
                                      'Resend SMS',
                                      style: TextStyle(
                                          color: appColorBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              );
                            }
                            List<Widget> list = [];

                            if (time.min != null) {
                              list.add(Row(
                                children: <Widget>[
                                  Text(time.min.toString()),
                                  Text(":"),
                                ],
                              ));
                            }
                            if (time.sec != null) {
                              list.add(Row(
                                children: <Widget>[
                                  Text(time.sec.toString()),
                                ],
                              ));
                            }

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Resend SMS",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Container(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: list,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0),

                    Padding(
                      padding: const EdgeInsets.only(left: 100, right: 100),
                      child: TextField(
                        textAlign: TextAlign.center,
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.number,
                        onChanged: (String value) {
                          code = value;
                        },
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: <Widget>[
                    //     getPinField(key: "1", focusNode: focusNode1),
                    //     SizedBox(width: 10.0),
                    //     getPinField(key: "2", focusNode: focusNode2),
                    //     SizedBox(width: 10.0),
                    //     getPinField(key: "3", focusNode: focusNode3),
                    //     SizedBox(width: 10.0),
                    //     getPinField(key: "4", focusNode: focusNode4),
                    //     SizedBox(width: 10.0),
                    //     getPinField(key: "5", focusNode: focusNode5),
                    //     SizedBox(width: 10.0),
                    //     getPinField(key: "6", focusNode: focusNode6),
                    //     SizedBox(width: 10.0),
                    //   ],
                    // ),
                    SizedBox(height: 32.0),
                  ],
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                constraints: const BoxConstraints(maxWidth: 500),
                // ignore: deprecated_member_use
                child: RaisedButton(
                  onPressed: signIn,
                  color: appColorBlue,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Confirm',
                          style: TextStyle(
                              color: appColorWhite,
                              fontFamily: "MontserratBold"),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              color: Colors.white),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: appColorBlack,
                            size: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }));
  }

  void _showSnackBar(BuildContext context, String text) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'ACTION',
          onPressed: () {},
        )));
  }

//  _showSnackBar(BuildContext context,String text) {
//
//    Scaffold.of(context).showSnackBar(
//      SnackBar(
//          content: Text(text),
//          duration: const Duration(seconds: 1),
//          action: SnackBarAction(
//            label: 'ACTION',
//            onPressed: () {},
//          )),
//    );
////     final snackBar = SnackBar(
////       content: Text('$text'),
////       duration: Duration(seconds: 2),
////     );
//// //    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
////     scaffoldKey.currentState.showSnackBar(snackBar);
//  }

  signIn() {
    if (code.length != 6) {
      _showSnackBar(context, "Invalid OTP");
    }
    Provider.of<PhoneAuthDataProvider>(context, listen: false)
        .verifyOTPAndLogin(smsCode: code);
  }

  onStarted() {
    _showSnackBar(context, "PhoneAuth started");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  onCodeSent() {
    _showSnackBar(context, "OTP sent");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  onCodeResent() {
    _showSnackBar(context, "OTP resent");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  onVerified() async {
    _showSnackBar(context,
        "${Provider.of<PhoneAuthDataProvider>(context, listen: false).message}");
    await Future.delayed(Duration(seconds: 1));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => CreatePro()));
    //  PagesWidget
  }

  onFailed() {
//    _showSnackBar(phoneAuthDataProvider.message);
    _showSnackBar(context, "PhoneAuth failed");
  }

  onError() {
//    _showSnackBar(phoneAuthDataProvider.message);
    _showSnackBar(context,
        "PhoneAuth error ${Provider.of<PhoneAuthDataProvider>(context, listen: false).message}");
  }

  onAutoRetrievalTimeOut() {
    _showSnackBar(context, "PhoneAuth autoretrieval timeout");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  String validateMobile(String value) {
    if (value.length == 0) {
      Toast.show("Please enter mobile number", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return 'Please enter mobile number';
    }
// else if (!regExp.hasMatch(value)) {
//   Toast.show("Please enter valid mobile number", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
//   return 'Please enter valid mobile number';
// }
    else {
      startPhoneAuth();
    }
    return null;
  }

  startPhoneAuth() async {
    //  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    // print(Provider .of<PhoneAuthDataProvider>(context, listen: false).phoneNumberController.text);
    final phoneAuthDataProvider =
        Provider.of<PhoneAuthDataProvider>(context, listen: false);
    phoneAuthDataProvider.loading = true;
    var countryProvider = Provider.of<CountryProvider>(context, listen: false);
    bool validPhone = await phoneAuthDataProvider.instantiate(
        dialCode: countryProvider.selectedCountry.dialCode,
        onCodeSent: () {
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
              builder: (BuildContext context) => PhoneAuthVerify()));
        },
        onFailed: () {
          _showSnackBar(context, phoneAuthDataProvider.message);
        },
        onError: () {
          _showSnackBar(context, phoneAuthDataProvider.message);
        });
    if (!validPhone) {
      phoneAuthDataProvider.loading = false;
      _showSnackBar(context, "Oops! Number seems invaild");
      return;
    }
  }
}
