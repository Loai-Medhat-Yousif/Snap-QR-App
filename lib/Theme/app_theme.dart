import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xfffdb624);
  static const Color secondary = Color(0xff333333);

  static final ThemeData apptheme = ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    fontFamily: 'Itim',
  );
}
