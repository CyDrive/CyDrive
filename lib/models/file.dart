import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:cydrive/globals.dart';

// @JsonSerializable()
// class FileInfo {
//   FileInfo();

//   @JsonKey(ignore: true)
//   String filename;

//   @JsonKey(name: 'file_mode')
//   int fileMode;

//   @JsonKey(name: 'modify_time')
//   int modifyTime;

//   @JsonKey(name: 'file_path')
//   String filePath;

//   int size;

//   @JsonKey(name: 'is_dir')
//   bool isDir;

//   @JsonKey(name: 'is_compressed')
//   bool isCompressed;

//   FileInfo.fromJson(Map<String, dynamic> json) {
//     fileMode = json['file_mode'];
//     modifyTime = json['modify_time'];
//     filePath = json['file_path'];
//     size = json['size'];
//     isDir = json['is_dir'];
//     isCompressed = json['is_compressed'];

//     filename = basename(filePath);
//   }

//   FileInfo.fromFile(String absPath) {
//     var file = File(absPath);
//     file.stat().then((stat) {
//       fileMode = stat.mode;
//       modifyTime = stat.modified.millisecondsSinceEpoch ~/ 1000;
//       size = stat.size;
//       isDir = stat.type == FileSystemEntityType.directory;
//     });
//     filePath = relative(absPath, from: filesDirPath);
//     isCompressed = false;

//     filename = basename(filePath);
//   }

//   Map<String, dynamic> toJson() => {
//         'file_mode': fileMode,
//         'modify_time': modifyTime,
//         'file_path': filePath,
//         'size': size,
//         'is_dir': isDir,
//         'is_compressed': isCompressed,
//       };
// }
