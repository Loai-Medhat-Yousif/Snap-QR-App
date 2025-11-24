import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_qr/Controllers/QR-Scanner-Cubit/qr_scanner_cubit.dart';
import 'package:snap_qr/Theme/app_theme.dart';
import 'package:snap_qr/Views/Home-View/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isSeen = prefs.getBool('seen') ?? false;

    if (isSeen) {
      if (mounted) {
        _navigateToHome();
      }
    } else {
      setState(() {
        _showButton = true;
      });
    }
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => SnapQRScannerCubit(),
          child: const HomeView(),
        ),
      ),
    );
  }

  Future<void> _markAsSeenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => SnapQRScannerCubit(),
            child: const HomeView(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppTheme.primary),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  width: 200.w,
                  height: 200.h,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 50.h),
              alignment: Alignment.bottomCenter,
              child: _showButton
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(319.w, 58.h),
                        backgroundColor: AppTheme.secondary,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: _markAsSeenAndNavigate,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Let\'s Go',
                            style: TextStyle(
                              fontSize: 25.sp,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          20.horizontalSpace,
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.primary,
                            size: 25.sp,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
