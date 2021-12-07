// /// SHARE ON FACEBOOK CALL
//   shareOnFacebook() async {
//     String result = await FlutterSocialContentShare.share(
//         type: ShareType.facebookWithoutImage,
//         url: "https://www.apple.com",
//         quote: "captions");
//     print(result);
//   }

//   /// SHARE ON INSTAGRAM CALL
//   shareOnInstagram() async {
//     String result = await FlutterSocialContentShare.share(
//         type: ShareType.instagramWithImageUrl,
//         imageUrl:
//             "https://post.healthline.com/wp-content/uploads/2020/09/healthy-eating-ingredients-732x549-thumbnail-732x549.jpg");
//     print(result);
//   }

//   /// SHARE ON WHATSAPP CALL
//   shareWatsapp() async {
//     String result = await FlutterSocialContentShare.shareOnWhatsapp(
//         number: "xxxxxx", text: "Text appears here");
//     print(result);
//   }

//   /// SHARE ON EMAIL CALL
//   shareEmail() async {
//     String result = await FlutterSocialContentShare.shareOnEmail(
//         recipients: ["xxxx.xxx@gmail.com"],
//         subject: "Subject appears here",
//         body: "Body appears here",
//         isHTML: true); //default isHTML: False
//     print(result);
//   }

//   /// SHARE ON SMS CALL
//   shareSMS() async {
//     String result = await FlutterSocialContentShare.shareOnSMS(
//         recipients: ["xxxxxx"], text: "Text appears here");
//     print(result);
//   }