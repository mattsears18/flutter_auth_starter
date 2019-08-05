// import 'package:flutter/material.dart';

// //TODO set you custom theme here
// ThemeData theme() {
//   return ThemeData(
//       primaryColor: Colors.blue,
//       primaryColorDark: Colors.blue[900],
//       primaryColorLight: Colors.blue[400],
//       accentColor: Colors.lightBlueAccent);
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainTheme {
  MainTheme();

  static final themeData = new ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    primaryColorDark: Colors.blue[900],
    primaryColorLight: Colors.blue[400],
    accentColor: Colors.lightBlueAccent,
  );

  static final cupertinoTheme = new CupertinoThemeData(
    primaryColor: Colors.blue,
  );

  static material() => themeData;
  static cupertino() => cupertinoTheme;
}
