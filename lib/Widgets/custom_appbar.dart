import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:snap_qr/Theme/app_theme.dart';

class CustomAppbar extends StatelessWidget {
  final String title;
  const CustomAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: REdgeInsets.all(10),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_outlined,
              color: AppTheme.primary,
              size: 50.sp,
            ),
          ),
        ),
        30.horizontalSpace,
        Text(
          title,
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
