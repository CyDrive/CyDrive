import 'dart:io';

import 'package:cydrive/consts.dart';
import 'package:cydrive/models/file.dart';
import 'package:flutter/material.dart';
import 'package:cydrive/globals.dart';

class FolderView extends StatefulWidget {
  final Future<List<FileInfo>> fileInfoList;
  final remoteDir;
  final Function(FileInfo fileInfo) onItemTapped;
  final ListFilter filter;

  FolderView(this.fileInfoList, this.remoteDir, this.onItemTapped,
      {this.filter = ListFilter.All});

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  Future<List<FileInfo>> _fileInfoListF;
  List<FileInfo> _fileInfoList;

  @override
  void initState() {
    super.initState();
    _fileInfoListF = widget.fileInfoList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileInfo>>(
      future: _fileInfoListF,
      builder: (BuildContext context, AsyncSnapshot<List<FileInfo>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "failed to connect to the server",
                  textScaleFactor: 1.5,
                ),
                ElevatedButton(
                    child: Text('retry'),
                    onPressed: () {
                      _onRefresh();
                    })
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          _fileInfoList = snapshot.data;
          _fileInfoList.sort((a, b) {
            if (a.filename == '..') return -1;
            if (a.isDir != b.isDir) {
              if (a.isDir) {
                return -1;
              } else {
                return 1;
              }
            } else {
              return a.filename.compareTo(b.filename);
            }
          });
          return RefreshIndicator(
              child: ListView.builder(
                itemBuilder: _buildFileItem,
                itemCount: _fileInfoList.where((element) {
                  switch (widget.filter) {
                    case ListFilter.All:
                      return true;
                    case ListFilter.OnlyDir:
                      return element.isDir;
                    case ListFilter.OnlyFile:
                      return !element.isDir;
                  }
                  return false;
                }).length,
              ),
              onRefresh: _onRefresh);
        }
      },
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _fileInfoListF = client.list(widget.remoteDir);
    });
  }

  Widget _buildFileItem(BuildContext context, int index) {
    IconData iconData = Icons.file_copy_sharp;
    Color color = ThemeData().iconTheme.color;

    if (_fileInfoList[index].isDir) {
      iconData = Icons.folder_open_sharp;
    }
    if (File(filesDirPath + _fileInfoList[index].filePath).existsSync()) {
      color = Color(Colors.greenAccent.value);
    }

    Icon icon = Icon(iconData, color: color);

    return ListTile(
      leading: icon,
      title: Text(_fileInfoList[index].filename),
      trailing: _buildSizeText(_fileInfoList[index]),
      onTap: () {
        widget.onItemTapped(_fileInfoList[index]);
      },
      onLongPress: () {},
    );
  }

  Widget _buildSizeText(FileInfo fileInfo) {
    if (fileInfo.isDir) {
      return Text('');
    }
    const units = ["B", "KiB", "MiB", "GiB"];
    int unitIndex = 0;
    var size = fileInfo.size.toDouble();
    while (unitIndex + 1 < units.length && size >= 1024) {
      size /= 1024;
      unitIndex++;
    }

    return Text(size.toStringAsFixed(2) + ' ' + units[unitIndex]);
  }
}
