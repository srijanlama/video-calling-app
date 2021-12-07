import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/utils/widgets.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/provider/countries.dart';
import 'package:flutterwhatsappclone/provider/phone_auth.dart';
import 'package:flutterwhatsappclone/provider/select_country.dart';
import 'package:flutterwhatsappclone/provider/verify.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class WrongPhone extends StatefulWidget {
  @override
  _PhoneAuthGetPhoneState createState() => _PhoneAuthGetPhoneState();
}

class _PhoneAuthGetPhoneState extends State<WrongPhone> {
  double _height, _fixedPadding;

  @override
  void initState() {
    mobNo = '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "scaffold-get-phone");

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _fixedPadding = _height * 0.025;
    final countriesProvider = Provider.of<CountryProvider>(context);
    final loader = Provider.of<PhoneAuthDataProvider>(context).loading;

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: appColorBlue,
        title: Text(
          "Phone Number",
          style: TextStyle(fontFamily: "MontserratBold", fontSize: 17,color: appColorWhite),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        // leading: Icon(Icons.arrow_back_ios),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(
        //       Icons.filter_list,
        //     ),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              child: _getBody(countriesProvider)
            ),
            loader ? Container() : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _getBody(CountryProvider countriesProvider) =>
      countriesProvider.countries.length > 0
          ? _getColumnBody(countriesProvider)
          : Center(child: CircularProgressIndicator());

  Widget _getColumnBody(CountryProvider countriesProvider) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Center(
              child: Text(
                'Please confirm your country code and enter your phone number',
                style: TextStyle(fontSize: 17, fontFamily: "MontserratBold"),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Container(
            height: 40,
          ),

          Padding(
            padding: EdgeInsets.only(top: _fixedPadding, left: _fixedPadding),
            child: CustomText(
              text: "Choose a country",
              alignment: Alignment.centerLeft,
              fontSize: 14,
              fontFamily: "MontserratBold",
              fontWeight: FontWeight.bold,
              color: appColorBlack,
            ),
          ),

          Padding(
              padding:
                  EdgeInsets.only(left: _fixedPadding, right: _fixedPadding),
              child: ShowSelectedCountry(
                country: countriesProvider.selectedCountry,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SelectCountry()),
                  );
                },
              )),

          Padding(
              padding: EdgeInsets.only(top: 10.0, left: _fixedPadding),
              child: CustomText(
                text: "Enter your phone",
                alignment: Alignment.centerLeft,
                fontSize: 14,
                fontFamily: "MontserratBold",
                fontWeight: FontWeight.bold,
                color: appColorBlack,
              )),

          Padding(
            padding: EdgeInsets.only(
                left: _fixedPadding,
                right: _fixedPadding,
                bottom: _fixedPadding),
            child: PhoneNumberField(
              controller:
                  Provider.of<PhoneAuthDataProvider>(context, listen: false)
                      .phoneNumberController,
              prefix: countriesProvider.selectedCountry.dialCode ?? "+91",
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 30, top: 0, left: 30, bottom: 10),
              child: SizedBox(
                height: SizeConfig.blockSizeVertical * 7,
                width: SizeConfig.screenWidth,
                child: CustomButtom(
                    title: 'NEXT',
                    fontSize: 16,
                    fontFamily: "MontserratBold",
                    fontWeight: FontWeight.bold,
                    textColor: appColorWhite,
                    color: appColorBlue,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    onPressed: () {
                      mobNo = '';
                      mobNo = Provider.of<PhoneAuthDataProvider>(context,
                                listen: false)
                            .phoneNumberController
                            .text;
                      validateMobile(Provider.of<PhoneAuthDataProvider>(context,
                              listen: false)
                          .phoneNumberController
                          .text);
                    }),
              ),
            ),
          ),
          //_dontHaveAnAccount()
        ],
      );

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

  _showSnackBar(String text) {
     // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(
      SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 1),
          action: SnackBarAction(
            label: 'ACTION',
            onPressed: () {},
          )),
    );
//     final snackBar = SnackBar(
//       content: Text('$text'),
//     );
// //    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
//     scaffoldKey.currentState.showSnackBar(snackBar);
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
          _showSnackBar(phoneAuthDataProvider.message);
        },
        onError: () {
          _showSnackBar(phoneAuthDataProvider.message);
        });
    if (!validPhone) {
      phoneAuthDataProvider.loading = false;
      _showSnackBar("Oops! Number seems invaild");
      return;
    }
  }
}
