import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/apptheme.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';

class ChatBackup extends StatefulWidget {
  @override
  ChatBackupState createState() {
    return new ChatBackupState();
  }
}

class ChatBackupState extends State<ChatBackup> {
  bool status = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
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
                      padding:
                          const EdgeInsets.only(left: 0, right: 0, top: 10),
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
                            'Chat Backup',
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
                                    builder: (context) => AppTheme()),
                              );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Backup chat to iCloud / Drive',
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
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => ProfilePicture()),
                              // );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Backup chat now manually',
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
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => ProfilePicture()),
                              // );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Auto Backup',
                                    style: new TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text('Weekly'),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward_ios),
                                        color: Colors.black,
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
                      Container(
                        color: Colors.white,
                        height: 50,
                      ),
                      Container(
                        color: Colors.white,
                        height: SizeConfig.blockSizeVertical * 10,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => NewContact()),
                              // );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Include Videos',
                                    style: new TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Container(
                                    child: CustomSwitch(
                                      activeColor: Colors.green,
                                      value: status,
                                      onChanged: (value) {
                                        print("VALUE : $value");
                                        setState(() {
                                          status = value;
                                        });
                                      },
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
