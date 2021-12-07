import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterwhatsappclone/Screens/groupCalling/groupPickupScreen.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/call_method.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/pickup_screen.dart';
import 'package:flutterwhatsappclone/Screens/videoCall/user_provider.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();
  var date = DateTime.now().add(Duration(seconds: 10));

  PickupLayout({
    @required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    // if (userProvider == null) {
    //   closeNotification();
    // }

    return Stack(
      children: [
        scaffold,
        StreamBuilder(
          stream: Firestore.instance
              .collection("groupCall")
              .where('groupUsers', arrayContains: userID)
              .where('timestamp',
                  isGreaterThan: DateTime.now().millisecondsSinceEpoch)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data.documents == null) {
              closeNotification();
            }
            if (snapshot.hasData && snapshot.data.documents.length > 0) {
              print(snapshot.data.documents[0]['channelId']);
              return GroupPickupScreen(document: snapshot.data.documents[0]);
              // return Container();
            } else {
              return Container();
            }
          },
        ),
        (userProvider != null && userProvider.getUser != null)
            ? StreamBuilder<DocumentSnapshot>(
                stream: callMethods.callStream(uid: userProvider.getUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.data == null) {
                    closeNotification();
                  }
                  if (snapshot.hasData && snapshot.data.data != null) {
                    Call call = Call.fromMap(snapshot.data.data);

                    if (!call.hasDialled) {
                      return PickupScreen(call: call);
                    }
                  }
                  return Container();
                },
              )
            : Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ],
    );
  }

  closeNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(0);
    //

    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
