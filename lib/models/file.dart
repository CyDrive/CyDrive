import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class FileInfo {
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
}
