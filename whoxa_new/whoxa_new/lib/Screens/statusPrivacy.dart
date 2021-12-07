import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/newcontact.dart';
import 'package:flutterwhatsappclone/Screens/privacy.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';


class StatusPrivacy extends StatefulWidget {
  @override
  StatusPrivacyState createState() {
    return new StatusPrivacyState();
  }
}

class StatusPrivacyState extends State<StatusPrivacy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: SizeConfig.blockSizeVertical * 15,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'aaa',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  children: <Widget>[
                    Container(
                      height: SizeConfig.blockSizeVertical * 10,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrivacyOptions()),
                            );
                          },
                          child: ListTile(
                            title: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Text(
                                  'Everyone',
                                  style: new TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 4,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      color: Colors.green,
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical * 10,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewContact()),
                            );
                          },
                          child: ListTile(
                            title: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Text(
                                  'My Contacts',
                                  style: new TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 4,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical * 10,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewContact()),
                            );
                          },
                          child: ListTile(
                            title: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Text(
                                  'Only share with selectable contacts',
                                  style: new TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 4,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
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
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
