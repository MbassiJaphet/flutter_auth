import 'package:flutter/foundation.dart';

class User{
  String id;
  String email;
  String username;

  User({this.id, @required this.username, @required this.email});

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        email = json['email'],
        id = json['objectId'];
}
