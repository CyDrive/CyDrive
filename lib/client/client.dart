library cydrive;

import 'dart:convert';
import 'dart:io';
import 'package:cydrive/utils.dart';
import 'package:dio/dio.dart';
import 'package:cydrive/models/resp.dart';
import 'package:cydrive/models/file.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class CyDriveClient {
  Dio _httpClient;

  CyDriveClient(String serverAddr) {
    _httpClient = Dio();
    _httpClient.interceptors.add(CookieManager(PersistCookieJar()));
    _httpClient.options.baseUrl = serverAddr;
  }

  Future<bool> login(String username, String passwd) async {
    Response<String> resp = await _httpClient.post('/login',
        data: FormData.fromMap(
            {'username': username, 'password': passwordHash(passwd)}));

    Map<String, dynamic> json = jsonDecode(resp.data);
    var res = Resp.fromJson(json);
    stderr.writeln(resp.data);

    return res.status == 0;
  }

  Future<List<FileInfo>> list(String folderPath) async {
    Response<String> resp = await _httpClient.get('/list/' + folderPath);
    Map<String, dynamic> json = jsonDecode(resp.data.toString());
    var res = Resp.fromJson(json);

    Iterable it = jsonDecode(res.data);
    List<FileInfo> fileInfos =
        List<FileInfo>.from(it.map((e) => FileInfo.fromJson(e)));

    return fileInfos;
  }
}
