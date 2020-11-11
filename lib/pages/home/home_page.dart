import 'package:flutter/material.dart';
import 'package:flutter_auth/app.dart';
import 'package:flutter_auth/pages/pages.dart';
import 'package:flutter_auth/services/services.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;
  static final String route = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _signingOut = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 24),
            Text(
              'Welcome,',
              style: TextStyle(fontSize: 36),
            ),
            Text(
              AppSession.of(context).sessionData.currentUser.username,
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 36),
            RaisedButton(
                color: Colors.red,
                textColor: Colors.white,
                child: !this._signingOut
                    ? Text("Sign Out")
                    : Container(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.yellow,
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      ),
                onPressed: this._signingOut
                    ? null
                    : () {
                        _handleSignout(context);
                      }),
            Expanded(
                child: SizedBox(
              width: 4,
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.people),
          onPressed: () {
            Navigator.pushNamed(context, UsersPage.route);
          }),
    );
  }

  void _handleSignout(BuildContext context) async {
    print("Signing Out");

    this.setState(() {
      this._signingOut = true;
    });

    await AppSession.of(context).reset();
    Navigator.pushReplacementNamed(context, SignInPage.route);

    this.setState(() {
      this._signingOut = false;
    });
  }
}
