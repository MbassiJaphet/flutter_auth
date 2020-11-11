import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/app.dart';
import 'package:flutter_auth/pages/pages.dart';
import 'package:flutter_auth/models/models.dart';
import 'package:flutter_auth/services/services.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;
  static final String route = '/signin';

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _signingIn = false;
  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(this.widget.title),
      ),
      body: Form(
          key: this._formKey,
          child: ListView(
            padding: EdgeInsets.all(24.0),
            children: [
              Center(child: FlutterLogo(size: 96)),
              SizedBox(height: 36),
              TextFormField(
                key: this._emailFieldKey,
                validator: _validateUserName,
                decoration: InputDecoration(
                  hintText: "Username or e-mail",
                  icon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                key: this._passwordFieldKey,
                obscureText: _hidePassword,
                validator: _validatePassword,
                decoration: InputDecoration(
                    hintText: "Password",
                    icon: Icon(Icons.lock_outline),
                    suffixIcon: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      child: Icon(
                        _hidePassword ? Icons.visibility : Icons.visibility_off,
                        semanticLabel:
                            _hidePassword ? 'show password' : 'hide password',
                      ),
                    )),
              ),
              SizedBox(height: 24),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: RaisedButton(
                    color: Colors.blue,
                    padding:
                        EdgeInsets.symmetric(horizontal: 48.0, vertical: 12.0),
                    onPressed:
                        this._signingIn ? null : () => {_handleSignIn(context)},
                    child: !this._signingIn
                        ? Text(
                            "Sign In",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0),
                          )
                        : Container(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.yellow,
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white)),
                          )),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.popAndPushNamed(context, SignUpPage.route);
                  },
                  child: Center(child: Text('Sign Up')))
            ],
          )),
    );
  }

  String _validateUserName(value) {
    if (value.isEmpty) {
      return "Username is required";
    } else {
      return null;
    }
  }

  String _validatePassword(String value) {
    final FormFieldState<String> passwordField = _passwordFieldKey.currentState;
    if (passwordField.value == null || passwordField.value.isEmpty)
      return 'Password is required';
    if (passwordField.value != value) return 'The passwords don\'t match';
    return null;
  }

  void _handleSignIn(context) async {
    if (this._formKey.currentState.validate()) {
      print('Form Validated');
      this.setState(() {
        this._signingIn = true;
      });
      String username = this._emailFieldKey.currentState.value;
      String password = this._passwordFieldKey.currentState.value;
      ParseResponse userResponse = await UserService.signIn(username, password);
      if (userResponse.results != null) {
        ParseUser user = userResponse.results[0];
        QueryBuilder<ParseObject> sessionQuery =
            QueryBuilder<ParseObject>(ParseObject('_Session'))
              ..whereEqualTo('sessionToken', '${user.sessionToken}');
        ParseResponse sessionResponse = await sessionQuery.query();
        print("Session response ${sessionResponse.results}");
        ParseObject session = sessionResponse.results[0];
        print("Session Id: ${session.objectId}");
        SharedPreferences preferences = await SharedPreferences.getInstance();
        AppSession.of(context).sessionData.sessionId = session.objectId;
        AppSession.of(context).sessionData.currentUser = User(
            id: user.objectId,
            username: user.username,
            email: user.emailAddress);
        print("Saving Preferences");
        preferences.setString("user_id", user.objectId);
        preferences.setString("username", user.username);
        preferences.setString("email", user.emailAddress);
        preferences.setString("session_id", session.objectId);
        preferences.setString("session_token", user.sessionToken);
        Navigator.pushReplacementNamed(context, HomePage.route);
      } else {
        this._scaffoldKey.currentState.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black87.withOpacity(0.5),
            content: SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.error, size: 36, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Invalid username or password."),
                ],
              ),
            ),
            margin: EdgeInsets.fromLTRB(12, 0, 12, 24),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)))));
      }
      this.setState(() {
        this._signingIn = false;
      });
    }
  }
}
