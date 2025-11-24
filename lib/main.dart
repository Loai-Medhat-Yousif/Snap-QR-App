import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:snap_qr/Theme/app_theme.dart';
import 'package:snap_qr/Views/Splash-View/splash_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Snap Qr',
        theme: AppTheme.apptheme,
        home: SplashView(),
      ),
    );
  }
}
