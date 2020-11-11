import 'utils/utils.dart';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_auth/models/models.dart';
import 'package:flutter_auth/pages/pages.dart';
import 'package:flutter_auth/services/services.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  MaterialApp _app;
  MaterialApp _appPlaceholder;
  final _appTitle = 'Flutter Auth';
  final _appTheme = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  @override
  initState() {
    super.initState();
    this._appPlaceholder = MaterialApp(
        title: this._appTitle,
        theme: this._appTheme,
        builder: (context, child) =>
            Scaffold(body: Center(child: FlutterLogo(size: 96))));
    this._app = MaterialApp(
      title: this._appTitle,
      theme: this._appTheme,
      navigatorObservers: [routeObserver],
      onGenerateRoute: (settings) {
        return _getRoute(settings, context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppSession.of(context).sessionData.init();
    // return this._app;
    return FutureBuilder(
        future: AppSession.of(context).sessionData.init(),
        builder: (context, snapshot) => _launchApp(context, snapshot));
  }

  Widget _launchApp(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return this._app;
    } else {
      return this._appPlaceholder;
    }
  }
}

class SessionData {
  User _user;
  String sessionId;
  bool _initialized = true;

  User get currentUser  {return this._user;}

  set currentUser(User user) {this._user = user;}

  Future<bool> init() async {
    if(!this._initialized) {return true;}
    SharedPreferences preferences = await SharedPreferences.getInstance();
    this.sessionId = preferences.getString('session_id') ?? null;
    print(" Session Id: ${this.sessionId}");
    if ('session_id' != null) {
      var parseResponse = await ParseSession().getObject(this.sessionId);
      if (parseResponse.results != null) {
        ParseSession result = parseResponse.results[0];
        this._user = User(
            id: result.objectId,
            email: preferences.getString('email') ?? 'email',
            username: preferences.getString('username') ?? 'username');
      }
    }

    this._initialized = false;
    return true;
  }

  Future<bool> reset() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('session_id');
    this.sessionId = null;
    this._user = null;
    return true;
  }
}

class AppSession extends InheritedWidget {
  final Widget child;
  final SessionData sessionData = SessionData();

  AppSession({this.child}) : super(child: child);

  @override
  bool updateShouldNotify(AppSession oldWidget) {
    return this.sessionData.currentUser.username !=
        oldWidget.sessionData.currentUser.username;
  }

  static AppSession of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSession>();

  Future<bool> reset() async{
    bool success = await UserService.signOut();
    if(success) {
      await this.sessionData.reset();
    }
    return success;
  }
}

Route<dynamic> _getRoute(RouteSettings settings, BuildContext context) {
  if (AppSession.of(context).sessionData.currentUser != null) {
    if (settings.name == UsersPage.route) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => UsersPage(
          title: 'Users',
        ),
        fullscreenDialog: true,
      );
    } else {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => HomePage(
          title: 'Home',
        ),
        fullscreenDialog: true,
      );
    }
  } else {
    if (settings.name == SignUpPage.route) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => SignUpPage(
          title: 'Flutter Auth',
        ),
        fullscreenDialog: true,
      );
    } else {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => SignInPage(
          title: 'Flutter Auth',
        ),
        fullscreenDialog: true,
      );
    }
  }
}
