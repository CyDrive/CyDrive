import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cydrive/globals.dart';

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
