import 'package:crypto/crypto.dart';
import 'models/file.dart';

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

FileInfo lastDir(String currentDir) {
  var pathLevels = currentDir.split('/');
  pathLevels.removeLast();
  FileInfo fileInfo = FileInfo();
  fileInfo.filePath = pathLevels.join('/');
  fileInfo.filename = '..';
  fileInfo.size = 0;
  fileInfo.isDir = true;

  return fileInfo;
}
