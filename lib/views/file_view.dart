import 'dart:io';
import 'dart:math';

import 'package:cydrive/utils.dart';
import 'package:cydrive_sdk/models/file_info.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        child: Text('Open'),
        value: 'Open',
      ),
      PopupMenuItem(
        child: Text('Download'),
        value: 'Download',
      ),
      PopupMenuItem(
        child: Text('Share'),
        value: 'Share',
      ),
      PopupMenuItem(
        child: Text('Delete'),
        value: 'Delete',
      ),
    ];

    if (!file.existsSync()) {}

    return ListTile(
      leading: icon,
      title: Text(fileInfo.filePath.split('/').last),
      subtitle: buildSizeText(fileInfo),
      trailing: fileInfo.isDir
          ? SizedBox.shrink()
          : PopupMenuButton(
              itemBuilder: (BuildContext context) => filePopMenuItems,
              onSelected: (item) {
                switch (item) {
                  case 'Open':
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

                  case 'Download':
                    client
                        .download(
                            fileInfo.filePath, filesDirPath + fileInfo.filePath,
                            shouldTruncate: true)
                        .then((value) {
                      ftm.addTask(value);
                      widget.onStateChange();
                    });
                    break;

                  case 'Share':
                    client.share(fileInfo.filePath).then((value) {
                      Clipboard.setData(ClipboardData(text: value))
                          .whenComplete(() => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text(
                                      'has copied the share-link: $value'))));
                    });

                    break;

                  case 'Delete':
                    if (file.existsSync()) {
                      file.deleteSync();
                    }
                    showDeleteDialog(context).then((value) {
                      if (value) {
                        client
                            .delete(fileInfo.filePath)
                            .whenComplete(() => widget.onStateChange());
                      } else {
                        widget.onStateChange();
                      }
                    });
                    break;
                }
              },
            ),
      onTap: () {
        widget.onTapped(fileInfo);
      },
    );
  }
}
