import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  int id;
  String username;
  String password;
  int usage;
  int cap;

  @JsonKey(name: 'root_dir')
  String rootDir;

  @JsonKey(name: 'work_dir')
  String workDir;

  @JsonKey(name: 'created_at')
  DateTime createdAt;

  @JsonKey(name: 'updated_at')
  DateTime updatedAt;
}
