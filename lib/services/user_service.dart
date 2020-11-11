import 'package:flutter_auth/models/models.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<ParseResponse> signUp(
      String username, String email, String password) async {
    return ParseUser(username, password, email).signUp();
  }

  static Future<ParseResponse> signIn(String username, String password) async {
    return ParseUser(username, password, "").login();
  }

  static Future<bool> signOut() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    ParseResponse response = await ParseSession().delete(id: preferences.getString('session_id'), path: "/classes/_Session");
    return true;
    // return response.success;
  }

  static Future<List<User>> getUsers() async {
    var apiResponse = await ParseUser.all();
    List<ParseUser> parseUsers = apiResponse.results;

    List<User> users = parseUsers.map(
        (_pasreUser) => User(username: _pasreUser.username, email: _pasreUser.password)).toList();
    return users;
  }
}
