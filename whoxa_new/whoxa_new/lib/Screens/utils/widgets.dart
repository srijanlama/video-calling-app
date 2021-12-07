import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/provider/country.dart';

class PhoneAuthWidgets {
  static Widget getLogo({String logoPath, double height}) => Material(
        type: MaterialType.transparency,
        elevation: 10.0,
        child: Image.asset(logoPath, height: height),
      );
}

class SearchCountryTF extends StatelessWidget {
  final TextEditingController controller;

  const SearchCountryTF({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10, top: 8.0, bottom: 2.0, right: 10),
      child: Card(
        child: TextFormField(
          autofocus: false,
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search your country',
            contentPadding: const EdgeInsets.only(
                left: 10, right: 5.0, top: 10.0, bottom: 10.0),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String prefix;

  const PhoneNumberField({Key key, this.controller, this.prefix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(3),
          //     side: BorderSide(color: Colors.grey[500], width: 1.5)),
          child: Row(
            children: <Widget>[
              Text("  " + prefix + "  ",
                  style: TextStyle(fontSize: 16.0, color: Colors.black)),
              SizedBox(width: 8.0),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  autofocus: false,
                  keyboardType: TextInputType.phone,
                  key: Key('EnterPhone-TextFormField'),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    errorMaxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1.5,
          color: Colors.grey,
        )
      ],
    );
  }
}

class SubTitle extends StatelessWidget {
  final String text;

  const SubTitle({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(' $text',
            style: TextStyle(
                color: Color(0xFF34C759),
                fontSize: 14.0,
                fontWeight: FontWeight.bold)));
  }
}

class ShowSelectedCountry extends StatelessWidget {
  final VoidCallback onPressed;
  final Country country;

  const ShowSelectedCountry({Key key, this.onPressed, this.country})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // shape:  RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(4),
      //      side: BorderSide(color: Colors.grey[400], width: 2.5)
      //   ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 4.0, right: 4.0, top: 12.0, bottom: 12.0),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    ' ${country.flag}  ${country.name} ',
                    style: TextStyle(color: Colors.black),
                  )),
                  Icon(Icons.arrow_drop_down, size: 24.0)
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  height: 1.5,
                  color: Colors.grey[500],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SelectableWidget extends StatelessWidget {
  final Function(Country) selectThisCountry;
  final Country country;

  const SelectableWidget({Key key, this.selectThisCountry, this.country})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      type: MaterialType.canvas,
      child: InkWell(
        onTap: () => selectThisCountry(country), //selectThisCountry(country),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "  " +
                country.flag +
                "  " +
                country.name +
                " (" +
                country.dialCode +
                ")",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
