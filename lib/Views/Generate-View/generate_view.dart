import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:snap_qr/Model/history_model.dart';
import 'package:snap_qr/Services/history_service.dart';
import 'package:snap_qr/Theme/app_theme.dart';
import 'package:snap_qr/Widgets/custom_appbar.dart';
import 'package:share_plus/share_plus.dart';

class GenerateView extends StatefulWidget {
  const GenerateView({super.key});

  @override
  State<GenerateView> createState() => _GenerateViewState();
}

class _GenerateViewState extends State<GenerateView> {
  final TextEditingController _textController = TextEditingController();
  final QRHistoryService _historyService = QRHistoryService();
  final GlobalKey _qrKey = GlobalKey();
  String _qrData = '';
  bool _showQR = false;
  bool _isSaving = false;
  String? _savedFilePath;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _generateQR() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter some data to generate QR code'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: REdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return;
    }

    setState(() {
      _qrData = _textController.text;
      _showQR = true;
    });
    await _historyService.addHistory(data: _qrData, type: QRType.generated);
  }

  Future<void> _saveQRCode() async {
    setState(() {
      _isSaving = true;
    });

    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Storage permission is required to save QR code',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: REdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          }
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      final directory = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/QR_Code_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      setState(() {
        _savedFilePath = filePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Code saved to: ${directory.path}'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            margin: REdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save QR code'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: REdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _shareQRCode() async {
    if (_savedFilePath == null || !File(_savedFilePath!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please save the QR code first'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: REdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(_savedFilePath!)], subject: 'QR Code'),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share QR code'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: REdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          image: const DecorationImage(
            image: AssetImage('assets/images/ScreenBG.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppbar(title: 'Generate QR Code'),
              30.verticalSpace,
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: REdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _textController,
                          style: TextStyle(fontSize: 16.sp),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter data to generate QR code',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: REdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          onChanged: (value) {
                            if (_showQR) {
                              setState(() {
                                _showQR = false;
                              });
                            }
                          },
                        ),
                        20.verticalSpace,
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: REdgeInsets.symmetric(
                              horizontal: 30.w,
                              vertical: 15.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          icon: Icon(
                            Icons.qr_code,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          label: Text(
                            "Generate QR Code",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _generateQR,
                        ),
                        30.verticalSpace,
                        if (_showQR && _qrData.isNotEmpty)
                          Column(
                            children: [
                              RepaintBoundary(
                                key: _qrKey,
                                child: Column(
                                  children: [
                                    QrImageView(
                                      backgroundColor: Colors.white,
                                      data: _qrData,
                                      version: QrVersions.auto,
                                      size: 250.w,
                                    ),
                                    10.verticalSpace,
                                  ],
                                ),
                              ),
                              20.verticalSpace,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      padding: REdgeInsets.symmetric(
                                        horizontal: 25.w,
                                        vertical: 15.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                      ),
                                    ),
                                    icon: _isSaving
                                        ? SizedBox(
                                            width: 20.w,
                                            height: 20.h,
                                            child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                          )
                                        : Icon(
                                            Icons.save,
                                            color: Colors.white,
                                            size: 30.sp,
                                          ),
                                    label: Text(
                                      _isSaving ? "Saving..." : "Save",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _isSaving ? null : _saveQRCode,
                                  ),
                                  15.horizontalSpace,
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      padding: REdgeInsets.symmetric(
                                        horizontal: 25.w,
                                        vertical: 15.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.share,
                                      color: Colors.white,
                                      size: 30.sp,
                                    ),
                                    label: Text(
                                      "Share",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _shareQRCode,
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
