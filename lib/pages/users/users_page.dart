import 'package:flutter/material.dart';
import 'package:flutter_auth/models/models.dart';

import 'package:flutter_auth/services/services.dart';

class UsersPage extends StatefulWidget {
  UsersPage({Key key, this.title}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();

  final String title;
  static final String route = '/users';
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Users"),
        ),
        body: FutureBuilder(
          future: UserService.getUsers(),
          builder: (context, snapshot) => _displayUsers(context, snapshot),
        ));
  }
}

Widget _displayUsers(BuildContext context, AsyncSnapshot<List<User>> snapshot) {
  if (snapshot.connectionState == ConnectionState.done) {
    return ListView(
      children: snapshot.data.map((user) => ListTile(title: Text(user.username),)).toList()
    );
  } else {
    return Center(child: CircularProgressIndicator());
  }
}
