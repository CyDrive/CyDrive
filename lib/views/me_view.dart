import 'package:flutter/material.dart';

class MeView extends StatefulWidget {
  @override
  _MeViewState createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('This is me view'),
    );
  }
}
