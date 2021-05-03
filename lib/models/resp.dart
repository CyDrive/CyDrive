import 'dart:ffi';

class Resp {
  int status;
  String msg;
  String data = '';

  Resp.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['message'];
    data = json['data'];

    if (data == null) {
      data = '';
    }
  }
}
