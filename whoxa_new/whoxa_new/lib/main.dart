//import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/splashscreen.dart';
import 'package:flutterwhatsappclone/app.dart';
import 'package:flutterwhatsappclone/constatnt/Constant.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/widgets/provider_widget.dart' as pre;

const iOSLocalizedLabels = false;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Admob.initialize();
  await SharedPreferences.getInstance().then(
    (prefs) {
      runApp(new pre.Provider(
        auth: AuthService(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: appName,
          theme: new ThemeData(
              accentColor: Colors.black,
              primaryColor: Colors.black,
              primaryColorDark: Colors.black),
          home: SplashScreen(),
          routes: <String, WidgetBuilder>{
            APP_SCREEN: (BuildContext context) => new App(prefs),
            // LOGIN_SCREEN: (BuildContext context) => new Login(),
            // SIGN_UP_SCREEN: (BuildContext context) => new SignUp(),
            // ANIMATED_SPLASH: (BuildContext context) => new SplashScreen(),
          },
        ),
      ));
    },
  );
}
