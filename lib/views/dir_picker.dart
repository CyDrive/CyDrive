import 'package:cydrive/consts.dart';
import 'package:cydrive/globals.dart';
import 'package:cydrive/models/file.dart';
import 'package:cydrive/views/folder_view.dart';
import 'package:flutter/material.dart';

class DirPickerPage extends StatefulWidget {
  final String path;

  DirPickerPage(this.path);

  @override
  _DirPickerPageState createState() => _DirPickerPageState();
}

class _DirPickerPageState extends State<DirPickerPage> {
  Future<List<FileInfo>> _fileInfoList;

  @override
  void initState() {
    super.initState();
    _fileInfoList = client.list(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path),
      ),
      body: Column(
        children: [
          FolderView(_fileInfoList, widget.path, (FileInfo fileInfo) {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DirPickerPage(fileInfo.filePath)))
                .then((value) {
              Navigator.pop(context, value);
            });
          }, filter: ListFilter.OnlyDir),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context, widget.path);
              },
              child: Text('choose here'))
        ],
      ),
    );
  }
}
