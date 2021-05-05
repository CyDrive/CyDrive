import 'package:cydrive/client/client.dart';
import 'package:mime/mime.dart';

CyDriveClient client = CyDriveClient('http://123.57.39.79:6454');

MimeTypeResolver mimeTypeResolver = MimeTypeResolver();

String lookupMimeType(String filename) {
  String type = mimeTypeResolver.lookup(filename);
  if (type == null) {
    return 'text/plain';
  }
  return type;
}
