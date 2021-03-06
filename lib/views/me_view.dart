import 'package:cydrive/utils.dart';
import 'package:flutter/material.dart';
import 'package:cydrive/globals.dart';

class MeView extends StatefulWidget {
  @override
  _MeViewState createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            buildUserCard(),
          ],
        ));
  }

  Widget buildUserCard() {
    return Card(
        child: Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.username,
            textScaleFactor: 1.5,
          ),
          SizedBox(
            height: 2,
          ),
          Row(
            children: [
              Text('Storage Usage:', textScaleFactor: 1.2),
              Spacer(),
              Text('${sizeString(user.usage)} / ${sizeString(user.cap)}'),
            ],
          ),
          SizedBox(height: 1.2),
          LinearProgressIndicator(value: user.usage.toDouble() / user.cap),
        ],
      ),
    ));
  }
}
