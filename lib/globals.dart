import 'package:cydrive/client/client.dart';
import 'package:cydrive/consts.dart';
import 'package:mime/mime.dart';
import 'package:cydrive/models/user.dart';

User user = User();
CyDriveClient client = CyDriveClient('http://$kHost:$kCyDrivePort');

MimeTypeResolver mimeTypeResolver = MimeTypeResolver();

String filesDirPath;

String lookupMimeType(String filename) {
  String type = mimeTypeResolver.lookup(filename);
  if (type == null) {
    return 'text/plain';
  }
  return type;
}
