import 'package:cydrive/consts.dart';
import 'package:cydrive/file_transfer_manager/file_transfer_manager.dart';
import 'package:mime/mime.dart';
import 'package:cydrive/models/user.dart';

import 'package:cydrive_sdk/cydrive_sdk.dart';
import 'package:cydrive_sdk/models/account.pb.dart';

CyDriveClient client = CyDriveClient('$kHost', 1);
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
