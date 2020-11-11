import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/app.dart';
import 'package:flutter_auth/pages/pages.dart';
import 'package:flutter_auth/utils/utils.dart';
import 'package:flutter_auth/models/models.dart';
import 'package:flutter_auth/services/services.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;
  static final String route = '/signup';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _signingUp = false;
  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _userNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _eMailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: this._scaffoldKey,
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
                key: this._userNameFieldKey,
                validator: _validateUserName,
                decoration: InputDecoration(
                  hintText: "Username",
                  icon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                key: this._eMailFieldKey,
                validator: _validateEmail,
                decoration: InputDecoration(
                  hintText: "E-mail",
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: RaisedButton(
                  color: Colors.blue,
                  padding:
                      EdgeInsets.symmetric(horizontal: 48.0, vertical: 12.0),
                  onPressed:
                      this._signingUp ? null : () => {_handleSignUp(context)},
                  child: !this._signingUp
                      ? Text(
                          "Sign Up",
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                        ),
                ),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, SignInPage.route);
                  },
                  child: Center(child: Text('Sign In')))
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

  String _validateEmail(value) {
    if (value.isEmpty) {
      return "E-mail is required";
    } else {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return 'Please enter a valid email address';
      } else
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

  void _handleSignUp(context) async {
    if (this._formKey.currentState.validate()) {
      this.setState(() {
        this._signingUp = true;
      });
      print('Form Validated');
      String username = this._userNameFieldKey.currentState.value;
      String email = this._eMailFieldKey.currentState.value;
      String password = this._passwordFieldKey.currentState.value;

      print("Signing Up");
      ParseResponse userResponse =
          await UserService.signUp(username, email, password);
      if (userResponse.success) {
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
        this._sendPushs(user.username);
        Navigator.pushReplacementNamed(context, HomePage.route);
      } else {
        this._scaffoldKey.currentState.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black87.withOpacity(0.5),
            content: SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.warning, size: 36, color: Colors.yellow),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Eighter username or email already exist."),
                      SizedBox(height: 2),
                      Text("Please try with non existing ones")
                    ],
                  ),
                ],
              ),
            ),
            margin: EdgeInsets.fromLTRB(12, 0, 12, 24),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)))));
      }
      this.setState(() {
        this._signingUp = false;
      });
    }
  }

  Future<bool> _sendPushs(String username) async {
    print("Sending pushs");
    final pushNoitificationMannager = PushNotificationsManager();
    pushNoitificationMannager.init();
    ParseResponse installationResponse = await ParseInstallation().getAll();
    if (installationResponse.success) {
      List<ParseObject> installations = installationResponse.results;
      installations.forEach((installation) {
        String receiverToken = installation.get("deviceToken");
        Map<String, dynamic> notification = {
          "title": "New user registered",
          "body":
              "A new user has signed up in flutter_auth\nUsername: $username"
        };
        final pushNoitificationMannager = PushNotificationsManager();
        pushNoitificationMannager.init();
        pushNoitificationMannager.sendNotification(
            notification: notification, receiverToken: receiverToken);
      });
    }
    return installationResponse.success;
  }
}
