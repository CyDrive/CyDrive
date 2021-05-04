import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class FileInfo {
  FileInfo();

  @JsonKey(ignore: true)
  String filename;

  @JsonKey(name: 'file_mode')
  int fileMode;

  @JsonKey(name: 'modify_time')
  int modifyTime;

  @JsonKey(name: 'file_path')
  String filePath;

  int size;

  @JsonKey(name: 'is_dir')
  bool isDir;

  @JsonKey(name: 'is_compressed')
  bool isCompressed;

  FileInfo.fromJson(Map<String, dynamic> json) {
    fileMode = json['file_mode'];
    modifyTime = json['modify_time'];
    filePath = json['file_path'];
    size = json['size'];
    isDir = json['is_dir'];
    isCompressed = json['is_compressed'];

    filename = filePath.split('/').last;
  }

  Map<String, dynamic> toJson() => {
        'file_mode': fileMode,
        'modify_time': modifyTime,
        'file_path': filePath,
        'size': size,
        'is_dir': isDir,
        'is_compressed': isCompressed,
      };
}
