import 'package:cydrive/consts.dart';
import 'package:cydrive/file_transfer_manager/file_transfer_manager.dart';
import 'package:mime/mime.dart';

import 'package:cydrive_sdk/cydrive_sdk.dart';

CyDriveClient client = CyDriveClient('$kHost');
FileTransferManager ftm = FileTransferManager();

MimeTypeResolver mimeTypeResolver = MimeTypeResolver();

String filesDirPath;
String filesCachePath;

String lookupMimeType(String filename) {
  String type = mimeTypeResolver.lookup(filename);
  if (type == null) {
    return 'text/plain';
  }
  return type;
}
