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
  Dio _httpClient;
  User user = User();
  String _remoteDir = '';
  Function(String) _onRemoteDirChangeCallback =
      _defaultOnRemoteDirChangeCallback;

  String get remoteDir {
    return _remoteDir;
  }

  set remoteDir(String dirPath) {
    _remoteDir = dirPath;
    _onRemoteDirChangeCallback(_remoteDir);
  }

  static _defaultOnRemoteDirChangeCallback(String dirPath) {}

  CyDriveClient(String serverAddr,
      {Function(String) onRemoteDirChangeCallback =
          _defaultOnRemoteDirChangeCallback}) {
    getApplicationDocumentsDirectory().then((value) => {
          _httpClient.interceptors.add(
              CookieManager(PersistCookieJar(storage: FileStorage(value.path))))
        });
    _httpClient = Dio();
    // _httpClient.interceptors.add(CookieManager(PersistCookieJar()));
    _httpClient.options.baseUrl = serverAddr;
    _httpClient.options.connectTimeout = 1000;
  }

  registerCallback(Function(String) callback) {
    _onRemoteDirChangeCallback = callback;
  }

  Future<bool> login(String username, String passwd) async {
    user.username = username;
    user.password = passwd;

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
        if (await login(user.username, user.password)) {
          return list(remoteDir, shouldRetry: false);
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
}
