import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:open_appstore/open_appstore.dart';

import '../utils/common_functions.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';

class UpdateDialog extends StatelessWidget {
  final String packageName;
  UpdateDialog({
    required this.packageName,
  });

  @override
  Widget build(BuildContext context) {
    buildTitleWidget() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5.0),
            topRight: Radius.circular(5.0),
          ),
          color: Colors.white,
        ),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                "New Version Available".toUpperCase(),
                style: kBoldTextStyle.copyWith(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          // padding: EdgeInsets.only(left: 8, top: 8.0 + 8, right: 8, bottom: 8),
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            // ignore: prefer_const_literals_to_create_immutables
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitleWidget(),
              Center(
                child: SizedBox(
                  height: 25,
                  child: Image(
                      image: AssetImage('${assetImagePath}cultyvate.png')),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Text(
                  updateApp,
                  style: kTextStyle.copyWith(),
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 25),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async{
                        print('UPDATE CLICKED!');
                        final url = 'https://play.google.com/store/apps/details?id=$packageName';
                        final Uri _url = Uri.parse(url);
                         // OpenAppstore.launch(
                         //     androidAppId: packageName, iOSAppId: "");
                        if (!await launchUrl(_url)) {
                          throw Exception('Could not launch $_url');
                        }
                      },
                      child: Text(
                        "UPDATE",
                        style: kSmallTextStyle.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: cultGreen),
                    ),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 25),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        "Later",
                        style: kSmallTextStyle.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: cultGreen),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}
