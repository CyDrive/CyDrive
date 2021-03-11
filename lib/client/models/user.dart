import 'dart:ffi';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  Int64 id;
  String username;
  String password;
  Int64 usage;
  Int64 cap;

  @JsonKey(name: 'root_dir')
  String rootDir;

  @JsonKey(name: 'work_dir')
  String workDir;

  @JsonKey(name: 'created_at')
  DateTime createdAt;

  @JsonKey(name: 'updated_at')
  DateTime updatedAt;
}
