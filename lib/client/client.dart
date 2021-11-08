// library cydrive;

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:cydrive/consts.dart';
// import 'package:cydrive/models/task.dart';
// import 'package:cydrive/utils.dart';
// import 'package:dio/dio.dart';
// import 'package:cydrive/models/resp.dart';
// import 'package:cydrive/models/file.dart';
// import 'package:dio_cookie_manager/dio_cookie_manager.dart';
// import 'package:cookie_jar/cookie_jar.dart';
// import 'package:cydrive/models/user.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// import '../globals.dart';

// class CyDriveClient {
//   Dio _httpClient = Dio();
//   String _username;
//   String _password;
//   Map<int, Task> taskMap = Map();

//   CyDriveClient(String serverAddr) {
//     getApplicationDocumentsDirectory().then((value) {
//       _httpClient.interceptors.add(
//           CookieManager(PersistCookieJar(storage: FileStorage(value.path))));
//     });
//     _httpClient.options.baseUrl = serverAddr;
//     _httpClient.options.connectTimeout = 1000;
//   }

//   Future<User> login(String username, String passwd) async {
//     _username = username;
//     _password = passwd;

//     try {
//       Response<String> resp = await _httpClient.post('/login',
//           data: FormData.fromMap(
//               {'username': username, 'password': passwordHash(passwd)}));

//       Map<String, dynamic> json = jsonDecode(resp.data);
//       var res = Resp.fromJson(json);

//       if (res.status != 0) {
//         return null;
//       }

//       json = jsonDecode(res.data);
//       var user = User.fromJson(json);
//       return user;
//     } catch (err) {
//       return Future.error("can't connect to the server");
//     }
//   }

//   Future<List<FileInfo>> list(String folderPath,
//       {bool shouldRetry = true}) async {
//     Response<String> resp;
//     try {
//       resp = await _httpClient.get('/list/' + folderPath);
//       Map<String, dynamic> json = jsonDecode(resp.data.toString());
//       var res = Resp.fromJson(json);

//       if (res.status != 0 && shouldRetry) {
//         if (await login(_username, _password) != null) {
//           return list(folderPath, shouldRetry: false);
//         } else {
//           return Future.error("can't connect to the server");
//         }
//       }

//       Iterable it = jsonDecode(res.data);
//       List<FileInfo> fileInfos =
//           List<FileInfo>.from(it.map((e) => FileInfo.fromJson(e)));

//       return fileInfos;
//     } catch (err) {
//       stderr.writeln(err);
//       return Future.error("can't connect to the server");
//     }
//   }

//   Future<FileInfo> download(String filePath, {bool shouldRetry = true}) async {
//     try {
//       // var fileList = Directory(_appDocDirPath).listSync();

//       Response<String> resp = await _httpClient.get('/file/' + filePath);
//       Map<String, dynamic> json = jsonDecode(resp.data.toString());
//       var res = Resp.fromJson(json);

//       if (res.status != 0) {
//         stderr.writeln(res.msg);
//         return null;
//       }

//       String storePath = filesDirPath + filePath;
//       var dir = Directory(parentPath(storePath));
//       dir.createSync(recursive: true);

//       json = jsonDecode(res.data);
//       var fileInfo = FileInfo.fromJson(json);

//       var taskId = int.parse(res.msg);
//       var task = Task(taskId, fileInfo, TaskType.Download, doneBytes: 0);

//       taskMap[taskId] = task;

//       _downloadTask(task);

//       return fileInfo;
//     } catch (err) {
//       stderr.writeln(err);
//       throw ("occures error when downloading: $err");
//     }
//   }

//   Future<void> upload(String filePath, String remotePath,
//       {bool shouldRetry = true}) async {
//     try {
//       var fileInfo = FileInfo.fromFile(filePath);

//       Response<String> resp = await _httpClient.put(join('/file/', remotePath),
//           data: fileInfo.toJson().toString());
//       Map<String, dynamic> json = jsonDecode(resp.data.toString());
//       var res = Resp.fromJson(json);

//       if (res.status != 0) {
//         stderr.writeln(res.msg);
//         return;
//       }

//       var taskId = int.parse(res.msg);
//       var task = Task(taskId, fileInfo, TaskType.Upload, doneBytes: 0);

//       taskMap[taskId] = task;
//       _uploadTask(task);
//     } catch (err) {
//       stderr.writeln(err);
//       throw ("occures error when uploading: $err");
//     }
//   }

//   void _downloadTask(Task task) async {
//     String storePath = filesDirPath + '/' + task.fileInfo.filePath;

//     File file = File(storePath);
//     task.socket = await Socket.connect(kHost, kCyDriveFtmPort);

//     // send task id
//     var bdata = ByteData(8);
//     bdata.setInt64(0, task.id, Endian.little);
//     task.socket.add(bdata.buffer.asUint8List());

//     // transfer file
//     task.socket.flush().whenComplete(() {
//       var stream = task.socket.asBroadcastStream();
//       var fileWriter = file.openWrite(mode: FileMode.writeOnlyAppend);

//       fileWriter.addStream(stream).whenComplete(() {
//         fileWriter.flush().whenComplete(() {
//           fileWriter.close();
//         });
//       }).onError((error, stackTrace) {
//         stderr.writeln(error);
//       });
//     });
//   }

//   void _uploadTask(Task task) async {
//     String storePath = join(filesDirPath, task.fileInfo.filePath);

//     File file = File(storePath);
//     task.socket = await Socket.connect(kHost, kCyDriveFtmPort);

//     // send task id
//     var bdata = ByteData(8);
//     bdata.setInt64(0, task.id, Endian.little);
//     task.socket.add(bdata.buffer.asUint8List());

//     // transfer file
//     task.socket.flush().whenComplete(() {
//       var fileReader = file.openRead();

//       task.socket.addStream(fileReader).onError((error, stackTrace) {
//         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         //     content:
//         //         Text('Upload file ${task.fileInfo.filename} failed: $error')));
//         stderr.writeln(error);
//       });
//     });
//   }
// }
