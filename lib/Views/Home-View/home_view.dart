import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_qr/Controllers/QR-Scanner-Cubit/qr_scanner_cubit.dart';
import 'package:snap_qr/Controllers/QR-Scanner-Cubit/qr_scanner_state.dart';
import 'package:snap_qr/Theme/app_theme.dart';
import 'package:snap_qr/Views/Generate-View/generate_view.dart';
import 'package:snap_qr/Views/History-View/history_view.dart';
import 'package:snap_qr/Views/Scan-Result-View/scan_result_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _hasPermission = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) return true;
    status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  Future<void> _checkPermission() async {
    final granted = await requestCameraPermission();
    setState(() {
      _hasPermission = granted;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: Colors.white, size: 80.sp),
              SizedBox(height: 20.h),
              Text(
                "Camera permission is required\nto scan QR codes.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: _checkPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                ),
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<SnapQRScannerCubit, SnapQRScannerState>(
      builder: (context, state) {
        if (state.scannedData != null || state.errorMessage != null) {
          Future.microtask(() {
            if (!context.mounted) return;
            _showScanResult(
              context,
              state.scannedData ?? state.errorMessage!,
              state.errorMessage != null,
            );
          });
        }

        return Scaffold(
          backgroundColor: AppTheme.primary,
          body: Stack(
            children: [
              AiBarcodeScanner(
                controller: context.read<SnapQRScannerCubit>().controller,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final value = barcodes.first.rawValue ?? "";
                    context.read<SnapQRScannerCubit>().onScan(value);
                  }
                },
                fit: BoxFit.cover,
                galleryButtonType: GalleryButtonType.none,
                overlayConfig: ScannerOverlayConfig(
                  backgroundBlurColor: Colors.transparent.withValues(
                    alpha: 0.25,
                  ),
                  borderColor: AppTheme.primary,
                  animationColor: AppTheme.primary,
                  borderRadius: 20.r,
                ),
              ),
              _buildTopBar(context, state),
              _buildBottomBar(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, SnapQRScannerState state) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          width: 450.w,
          height: 55.h,
          margin: REdgeInsets.only(left: 25.w, right: 25.w, top: 5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: REdgeInsets.symmetric(horizontal: 30.w),
                  child: GestureDetector(
                    onTap: () {
                      if (i == 0) {
                        context.read<SnapQRScannerCubit>().scanFromGallery();
                      } else if (i == 1) {
                        context.read<SnapQRScannerCubit>().toggleFlash();
                      } else {
                        context.read<SnapQRScannerCubit>().switchCamera();
                      }
                    },
                    child: Icon(
                      i == 0
                          ? Icons.photo_library
                          : i == 1
                          ? (state.flashOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded)
                          : Icons.cameraswitch_rounded,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          height: 85.h,
          margin: REdgeInsets.only(left: 25.w, right: 25.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < 2; i++)
                Padding(
                  padding: REdgeInsets.symmetric(horizontal: 30.w),
                  child: GestureDetector(
                    onTap: () async {
                      final cubit = context.read<SnapQRScannerCubit>();
                      cubit.pauseCamera();

                      if (i == 0) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => SnapQRScannerCubit(),
                              child: const GenerateView(),
                            ),
                          ),
                        );
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryView(),
                          ),
                        );
                      }
                      if (context.mounted) {
                        cubit.resumeCamera();
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == 0 ? Icons.qr_code_2_rounded : Icons.history,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                        Text(
                          i == 0 ? 'Generate Qr' : 'History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showScanResult(
    BuildContext context,
    String value,
    bool isError,
  ) {
    final cubit = context.read<SnapQRScannerCubit>();
    return showModalBottomSheet(
      enableDrag: false,
      isDismissible: false,
      context: context,
      backgroundColor: AppTheme.secondary,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: ScanResultContent(value: value, isError: isError),
        );
      },
    );
  }
}
