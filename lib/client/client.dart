library cydrive;

import 'dart:convert';
import 'dart:io';
import 'package:cydrive/utils.dart';
import 'package:dio/dio.dart';
import 'package:cydrive/models/resp.dart';
import 'package:cydrive/models/file.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:cydrive/models/user.dart';
import 'package:path_provider/path_provider.dart';

class CyDriveClient {
  Dio _httpClient = Dio();
  User _user = User();
  String _appDocDirPath;

  CyDriveClient(String serverAddr) {
    getApplicationDocumentsDirectory().then((value) {
      _appDocDirPath = value.path;
      _httpClient.interceptors.add(CookieManager(
          PersistCookieJar(storage: FileStorage(_appDocDirPath))));
    });
    _httpClient.options.baseUrl = serverAddr;
    _httpClient.options.connectTimeout = 1000;
  }

  Future<bool> login(String username, String passwd) async {
    _user.username = username;
    _user.password = passwd;

    try {
      Response<String> resp = await _httpClient.post('/login',
          data: FormData.fromMap(
              {'username': username, 'password': passwordHash(passwd)}));

      Map<String, dynamic> json = jsonDecode(resp.data);
      var res = Resp.fromJson(json);

      return res.status == 0;
    } catch (err) {
      return Future.error("can't connect to the server");
    }
  }

  Future<List<FileInfo>> list(String folderPath,
      {bool shouldRetry = true}) async {
    Response<String> resp;
    try {
      resp = await _httpClient.get('/list/' + folderPath);
      Map<String, dynamic> json = jsonDecode(resp.data.toString());
      var res = Resp.fromJson(json);

      if (res.status != 0 && shouldRetry) {
        if (await login(_user.username, _user.password)) {
          return list(folderPath, shouldRetry: false);
        } else {
          return Future.error("can't connect to the server");
        }
      }

      Iterable it = jsonDecode(res.data);
      List<FileInfo> fileInfos =
          List<FileInfo>.from(it.map((e) => FileInfo.fromJson(e)));

      return fileInfos;
    } catch (err) {
      stderr.writeln(err);
      return Future.error("can't connect to the server");
    }
  }

  Future<void> download(String filePath, {bool shouldRetry = true}) async {
    try {
      // var fileList = Directory(_appDocDirPath).listSync();
      String storePath = _appDocDirPath + filePath;
      // var dir = Directory(parentPath(storePath));
      // dir.createSync(recursive: true);
      await _httpClient.download('/file/' + filePath, storePath);
      // fileList = dir.listSync();
      // stderr.writeln(fileList);
    } catch (err) {
      stderr.writeln(err);
      throw ("occures error when downloading: $err");
    }
  }
}
