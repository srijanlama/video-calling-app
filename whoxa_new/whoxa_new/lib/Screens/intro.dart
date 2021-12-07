import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/provider/get_phone.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
        //  decoration: BoxDecoration(
        //     image: DecorationImage(
        //       image: AssetImage('assets/images/back.jpg'),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: LayoutBuilder(builder: (context, constraint) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraint.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 10,
                          ),
                          Expanded(
                            child: Container(
                              height: 130,
                              width: double.infinity,
                              decoration: BoxDecoration(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.asset(
                                      'assets/images/applogo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: SizeConfig.blockSizeVertical * 6,
                            width: SizeConfig.blockSizeHorizontal * 70,
                            // ignore: deprecated_member_use
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhoneAuthGetPhone(),
                                  ),
                                );
                              },
                              color: appColorBlue,
                              textColor: Colors.white,
                              child: Text("let's go".toUpperCase(),
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 3,
                                      fontFamily: "MontserratBold",
                                      color: appColorWhite)),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 10,
                          ),
                        ],
                      ),
                    )),
              );
            })),
      ),
    );
  }
}
