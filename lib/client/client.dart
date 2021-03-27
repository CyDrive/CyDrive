library cydrive;

import 'dart:io';

import 'package:cydrive/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class CyDriveClient {
    CyDriveClient._internal() ;

    static final CyDriveClient _singleton = CyDriveClient._internal();
    factory CyDriveClient() {
        return _singleton;
    }

    BaseOptions options = BaseOptions(
        baseUrl: "http://123.57.39.79:6454",
        connectTimeout: 5000,
        receiveTimeout: 3000,
    );

    void login(String username, String passwd) async {

        Dio dio = new Dio(options);
        FormData formData = new FormData.fromMap({
            "username": username,
            "password": PasswordHash(passwd),
        });
        try {
            Response response = await dio.post(
                "/login",
                data: formData
            );
            print(response.data.toString());
        }   catch(e) {
            print(e);
        }
    }

    void list(String folderPath) async {

        Dio dio = Dio(options);
        try {
            Response response = await dio.get("/list?path=" + folderPath);
            print(response.data.toString());
            try {
                var directory = new Directory(options.baseUrl);
                List<FileSystemEntity> files = directory.listSync();
                for (var f in files) {
                    print(f.path);
                }
            } catch(e) {
                print(e);
            }
        }   catch(e) {
            print(e);
        }
    }
}
