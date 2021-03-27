import 'dart:typed_data';

enum MessageType {
  Text,
  Image,
  Video,
  File,
}

class Message {
  Type type;
  String content;
  DateTime createdAt;
  String sender;
  String receiver;
}
