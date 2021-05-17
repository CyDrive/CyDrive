import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  int id;
  String username;
  int usage;
  int cap;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    usage = json['usage'];
    cap = json['cap'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'usage': usage,
        'cap': cap,
      };

  User();
}
