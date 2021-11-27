import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cydrive/globals.dart';
import 'package:cydrive_sdk/models/file_info.pb.dart';
import 'package:flutter/material.dart';

List<int> md5Hash(List<int> str) {
  return md5.convert(str).bytes;
}

List<int> sha256Hash(List<int> str) {
  return sha256.convert(str).bytes;
}

String passwordHash(String passwd) {
  var bytes = sha256Hash(md5Hash(passwd.codeUnits));
  String res = '';
  for (var byte in bytes) {
    res += byte.toString();
  }

  return res;
}

String parentPath(String path) {
  var pathLevels = path.split('/');
  pathLevels.removeLast();
  return pathLevels.join('/');
}

String sizeString(int size) {
  const units = ["B", "KiB", "MiB", "GiB"];
  int unitIndex = 0;
  while (unitIndex + 1 < units.length && size >= 1024) {
    size >>= 10;
    unitIndex++;
  }

  return size.toString() + ' ' + units[unitIndex];
}

bool hasLocalFile(String filePath) {
  var cacheFile = File(filesCachePath + filePath),
      file = File(filesDirPath + filePath);

  return cacheFile.existsSync() || file.existsSync();
}

File getLocalFile(String filePath) {
  var cacheFile = File(filesCachePath + filePath),
      file = File(filesDirPath + filePath);

  if (file.existsSync()) {
    return file;
  } else if (cacheFile.existsSync()) {
    return cacheFile;
  } else {
    return file;
  }
}

Widget buildSizeText(FileInfo fileInfo) {
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

Future<int> showFileDeleteDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        bool isDeleteRemote = false;
        return AlertDialog(
          title: Text('Delete', textAlign: TextAlign.center),
          content: Column(children: [
            Text("Make sure delete this file", textAlign: TextAlign.start),
          ], mainAxisSize: MainAxisSize.min),
          actions: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              StatefulBuilder(builder: (context, StateSetter setState) {
                return Container(
                    child: CheckboxListTile(
                        dense: true,
                        title: Text("Delete the remote file?",
                            textAlign: TextAlign.start),
                        value: isDeleteRemote,
                        onChanged: (bool) {
                          setState(() {
                            isDeleteRemote = !isDeleteRemote;
                          });
                        }));
              }),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: TextButton(
                          onPressed: () => Navigator.of(context).pop(0),
                          child: Text('No'))),
                  Expanded(
                      child: TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(isDeleteRemote ? 2 : 1),
                          child: Text('Yes')))
                ],
              )
            ]),
          ],
        );
      });
}

Future<bool> showTaskDeleteDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete', textAlign: TextAlign.center),
          content: Column(children: [
            Text("Make sure delete this task", textAlign: TextAlign.start),
          ], mainAxisSize: MainAxisSize.min),
          actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('No'))),
                  Expanded(
                      child: TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(true),
                          child: Text('Yes')))
                ],
              ),
          ],
        );
      });
}