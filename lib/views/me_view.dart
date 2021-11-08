import 'package:cydrive/utils.dart';
import 'package:cydrive_sdk/models/account.pb.dart';
import 'package:flutter/material.dart';
import 'package:cydrive/globals.dart';

class MeView extends StatefulWidget {
  @override
  _MeViewState createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {
  @override
  Widget build(BuildContext context) {
    var account = client.account;

    return Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            buildUserCard(account),
            Spacer(),
            Text('id:' + account.id.toString())
          ],
        ));
  }

  Widget buildUserCard(SafeAccount account) {
    return Card(
        child: Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            account.name.length > 0 ? account.name : account.email,
            textScaleFactor: 1.5,
          ),
          SizedBox(
            height: 2,
          ),
          Row(
            children: [
              Text('Storage Usage:', textScaleFactor: 1.2),
              Spacer(),
              Text(
                  '${sizeString(account.usage.toInt())} / ${sizeString(account.cap.toInt())}'),
            ],
          ),
          SizedBox(height: 1.2),
          LinearProgressIndicator(
              value: account.cap.isZero
                  ? 100
                  : account.usage.toDouble() / account.cap.toDouble()),
        ],
      ),
    ));
  }
}
