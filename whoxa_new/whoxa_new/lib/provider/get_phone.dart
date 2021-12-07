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

class PhoneAuthGetPhone extends StatefulWidget {
  @override
  _PhoneAuthGetPhoneState createState() => _PhoneAuthGetPhoneState();
}

class _PhoneAuthGetPhoneState extends State<PhoneAuthGetPhone> {
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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    BuildContext scaffoldContext;
    _height = MediaQuery.of(context).size.height;
    _fixedPadding = _height * 0.025;
    final countriesProvider = Provider.of<CountryProvider>(context);
    final loader = Provider.of<PhoneAuthDataProvider>(context).loading;

    return Scaffold(
      //  resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: appColorBlue,
        title: Text(
          "Phone Number",
          style: TextStyle(
              fontFamily: "MontserratBold", fontSize: 17, color: appColorWhite),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Builder(builder: (BuildContext context) {
//        scaffoldContext = context;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Stack(
              children: <Widget>[
                Container(
                  child: Container(
                      decoration: new BoxDecoration(color: Colors.white),
                      child: _getBody(countriesProvider)),
                ),
                loader ? Container() : SizedBox()
              ],
            ),
          ),
        );
      }),
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
              fontWeight: FontWeight.bold,
              fontFamily: "MontserratBold",
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
                text: "Enter your phone number",
                alignment: Alignment.centerLeft,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: "MontserratBold",
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
                      setState(() {
                        mobNo = '';
                        mobNo = Provider.of<PhoneAuthDataProvider>(context,
                                listen: false)
                            .phoneNumberController
                            .text;
                      });
                      print("mobNo:" + mobNo);
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
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return 'Please enter mobile number';
    } else {
      startPhoneAuth();
    }
    return null;
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

  startPhoneAuth() async {
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
