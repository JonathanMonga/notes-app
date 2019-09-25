import 'package:flutter/material.dart';
import 'package:notes_app_rxvms/app/main_page.dart';
import 'package:notes_app_rxvms/managers/app_manager.dart';
import 'package:notes_app_rxvms/service_locator.dart';

Future<Null> main() async {
  setUpServiceLocator();
  await sl.get<AppManager>().init();

  runApp(new MainPage());
}
