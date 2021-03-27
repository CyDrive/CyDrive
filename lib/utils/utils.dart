library cydrive;

import 'package:crypto/crypto.dart';
import 'dart:convert';


List<int> Md5Hash(List<int> password) {
    return md5.convert(password).bytes;
}

List<int> Sha256Hash(List<int> password) {
    return sha256.convert(password).bytes;
}

String PasswordHash(String password) {

    var bytes =  Sha256Hash(Md5Hash(utf8.encode(password)));
    String res = "";
    bytes.forEach((element) {
      res += element.toString();
    });
    return res;
}



