import 'package:flutter/material.dart';
// import 'package:flutterwhatsappclone/Screens/apptheme.dart';
import 'package:flutterwhatsappclone/Screens/chatbg.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';

class ChatOptions extends StatefulWidget {
  @override
  ChatOptionsState createState() {
    return new ChatOptionsState();
  }
}

class ChatOptionsState extends State<ChatOptions> {
  bool status = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "Chats",
          style: TextStyle(
              fontFamily: "MontserratBold", fontSize: 17, color: appColorBlack),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: appColorBlue,
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      // Container(
                      //   height: SizeConfig.blockSizeVertical * 6.4,
                      //   child: Row(
                      //     children: [
                      //       Expanded(
                      //         child: InkWell(
                      //           onTap: () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => AppTheme()),
                      //             );
                      //           },
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.start,
                      //             children: <Widget>[
                      //               Container(width: 15),
                      //               new Text(
                      //                 'Theme',
                      //                 style: new TextStyle(
                      //                     fontSize: 16,
                      //                     fontWeight: FontWeight.bold,
                      //                     color: Colors.black),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: const EdgeInsets.only(top: 0),
                      //         child: Icon(
                      //           Icons.arrow_forward_ios,
                      //           color: appColorGrey,
                      //           size: 20,
                      //         ),
                      //       ),
                      //       Container(width: 10)
                      //     ],
                      //   ),
                      // ),
                      // Container(
                      //   height: 0.5,
                      //   color: Colors.grey[400],
                      // ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 6.4,
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatBg()),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(width: 15),
                                    new Text(
                                      'Chat Background',
                                      style: new TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: appColorGrey,
                                size: 20,
                              ),
                            ),
                            Container(width: 10)
                          ],
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
