import 'dart:io';

import 'package:cydrive/consts.dart';
import 'package:cydrive/models/file.dart';
import 'package:cydrive/views/file_view.dart';
import 'package:cydrive_sdk/models/file_info.pb.dart';
import 'package:flutter/material.dart';
import 'package:cydrive/globals.dart';

class FolderView extends StatefulWidget {
  final remoteDir;
  final Function(FileInfo fileInfo) onItemTapped;
  final ListFilter filter;
  final Future<List<FileInfo>> files;

  FolderView(this.remoteDir, this.files, this.onItemTapped,
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

    _fileInfoListF = widget.files;
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
            if (a.filePath == '..') return -1;
            if (a.isDir != b.isDir) {
              if (a.isDir) {
                return -1;
              } else {
                return 1;
              }
            } else {
              return a.filePath.compareTo(b.filePath);
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
            onRefresh: _onRefresh,
          );
        }
      },
    );
  }

  Future<void> _onRefresh() async {
    await client.login();
    setState(() {
      _fileInfoListF = client.listDir(widget.remoteDir);
    });
  }

  Widget _buildFileItem(BuildContext context, int index) {
    return FileView(_fileInfoList[index], widget.onItemTapped, () {
      setState(() {
        _fileInfoListF = client.listDir(widget.remoteDir);
      });
    });
  }
}
