import 'dart:io';

import 'package:flutter/material.dart';

class ImagePage extends StatefulWidget {
  final imagePath;
  ImagePage(this.imagePath);
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: Image.file(File(widget.imagePath)),
    ));
  }
}
