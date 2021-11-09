import 'dart:io';
import 'dart:math';

import 'package:cydrive/models/file.dart';
import 'package:cydrive/utils.dart';
import 'package:cydrive_sdk/models/file_info.pb.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import '../globals.dart';

class FileView extends StatefulWidget {
  final FileInfo fileInfo;
  final Function(FileInfo fileInfo) onTapped;
  final Function() onStateChange;

  FileView(this.fileInfo, this.onTapped, this.onStateChange);

  @override
  _FileViewState createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.file_copy_sharp;
    Color color = ThemeData().iconTheme.color;
    var fileInfo = widget.fileInfo;
    bool hasLocal = hasLocalFile(fileInfo.filePath);
    var file = getLocalFile(fileInfo.filePath);

    if (fileInfo.isDir) {
      iconData = Icons.folder_open_sharp;
    }
    if (file.existsSync()) {
      color = Color(Colors.greenAccent.value);
    }

    Icon icon = Icon(iconData, color: color);

    var filePopMenuItems = <PopupMenuEntry>[
      PopupMenuItem(
        child: Text('Download'),
        value: 0,
      ),
      PopupMenuItem(
        child: Text('Delete'),
        value: 1,
      ),
    ];

    if (file.existsSync()) {
      filePopMenuItems.add(PopupMenuItem(
        child: Text('Open'),
        value: 2,
      ));
    }

    return ListTile(
      leading: icon,
      title: Text(fileInfo.filePath.split('/').last),
      subtitle: _buildSizeText(fileInfo),
      trailing: fileInfo.isDir
          ? SizedBox.shrink()
          : PopupMenuButton(
              itemBuilder: (BuildContext context) => filePopMenuItems,
              onSelected: (index) {
                switch (index) {
                  case 0:
                    client
                        .download(
                            fileInfo.filePath, filesDirPath + fileInfo.filePath,
                            shouldTruncate: true)
                        .then((value) {
                      ftm.addTask(value);
                      widget.onStateChange();
                    });
                    break;
                  case 1:
                    if (file.existsSync()) {
                      file.deleteSync();
                    }
                    _showDeleteDialog().then((value) {
                      if (value) {
                        client
                            .delete(fileInfo.filePath)
                            .whenComplete(() => widget.onStateChange());
                      } else {
                        widget.onStateChange();
                      }
                    });
                    break;
                  case 2:
                    if (!file.existsSync()) {
                      client
                          .download(fileInfo.filePath,
                              filesDirPath + fileInfo.filePath,
                              shouldTruncate: true)
                          .then((value) => ftm.addTask(value));
                    } else {
                      OpenFile.open(file.path,
                          type: lookupMimeType(fileInfo.filePath));
                    }
                    break;
                }
              },
            ),
      onTap: () {
        widget.onTapped(fileInfo);
      },
    );
  }

  Future<bool> _showDeleteDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete'),
            content: Text('Also delete the remote file?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes')),
            ],
          );
        });
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
