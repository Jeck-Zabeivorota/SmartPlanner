import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'dart:io';
import 'package:hive/hive.dart';
//
import 'View/Home/home_view.dart';
import 'View/colors.dart';
//
import 'Database/model_adapter.dart';
import 'Database/Models/settings_model.dart';
import 'Database/Models/item_model.dart';
import 'Database/Models/q_state_model.dart';

Future<void> setWindowSize() async {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await DesktopWindow.setMinWindowSize(const Size(400, 500));
  }
}

void initHive() {
  String path;
  if (Platform.isWindows) {
    path = 'Data\\';
  } else if (Platform.isLinux || Platform.isMacOS) {
    path = 'Data/';
  } else if (Platform.isAndroid) {
    path = '/storage/emulated/0/Smart planner/';
  } else {
    exit(0);
  }

  Hive.registerAdapter(ModelAdapter<SettingsModel>(typeId: 0));
  Hive.registerAdapter(ModelAdapter<ItemModel>(typeId: 1));
  Hive.registerAdapter(ModelAdapter<QStateModel>(typeId: 2));
  Hive.init(path);

  Directory dir = Directory(path);
  if (!dir.existsSync()) dir.createSync();
}

void main() async {
  initHive();
  runApp(const App());
  await setWindowSize();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: ViewColors.accent,
          selectionColor: ViewColors.accent.withOpacity(0.2),
        ),
      ),
      home: const HomeView(),
    );
  }
}
