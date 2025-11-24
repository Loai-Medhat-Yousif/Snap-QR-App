import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:snap_qr/Controllers/QR-Scanner-Cubit/qr_scanner_cubit.dart';
import 'package:snap_qr/Theme/app_theme.dart';

class ScanResultContent extends StatelessWidget {
  final String value;
  final bool isError;
  const ScanResultContent({
    super.key,
    required this.value,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          20.verticalSpace,
          isError
              ? Icon(Icons.error, color: AppTheme.primary, size: 100.w)
              : QrImageView(
                  backgroundColor: Colors.white,
                  data: value,
                  version: QrVersions.auto,
                  size: 150.w,
                ),
          20.verticalSpace,
          SelectableText(
            maxLines: 1,
            value,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18.sp),
          ),
          20.verticalSpace,
          isError
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: REdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    "Scan Again",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  onPressed: () {
                    context.read<SnapQRScannerCubit>().restartScanning();
                    Navigator.pop(context);
                  },
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: REdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      icon: Icon(Icons.copy, color: Colors.white),
                      label: Text(
                        "Copy",
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                      onPressed: () {
                        context.read<SnapQRScannerCubit>().restartScanning();
                        Clipboard.setData(ClipboardData(text: value));
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: REdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      icon: Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        "Scan Again",
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                      onPressed: () {
                        context.read<SnapQRScannerCubit>().restartScanning();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
          10.verticalSpace,
        ],
      ),
    );
  }
}
