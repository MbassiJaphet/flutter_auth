import 'package:flutter/material.dart';
import 'package:flutter_auth/app.dart';
import 'package:flutter_auth/utils/utils.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

void initServer() async {
  await Parse().initialize(ParseApplicationId, ParseServerURL,
      masterKey: ParseMasterKey, clientKey: ParseClientKey);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String deviceToken = preferences.getString('device_token') ?? null;
  if (deviceToken == null) {
    ParseInstallation installation =
        await ParseInstallation.currentInstallation();
    PushNotificationsManager pushNotificationManager =
        PushNotificationsManager();
    pushNotificationManager.init();
    installation.deviceToken = await pushNotificationManager.deviceToken();
    installation.save();
    preferences.setString('device_token', installation.deviceToken);
  }
}

void main() {
  runApp(AppSession(child: App()));
  final pushNoitificationMannager = PushNotificationsManager();
  pushNoitificationMannager.init();
  initServer();
}
