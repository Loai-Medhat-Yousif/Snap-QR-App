import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_qr/Model/history_model.dart';
import 'package:snap_qr/Services/history_service.dart';
import 'package:snap_qr/Theme/app_theme.dart';
import 'package:snap_qr/Widgets/custom_appbar.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final QRHistoryService _historyService = QRHistoryService();
  List<QRHistoryModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final history = await _historyService.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(String id) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Delete QR Code',
      desc: 'Are you sure you want to delete this QR code from history?',
      btnCancelOnPress: () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      btnOkOnPress: () async {
        await _historyService.deleteHistory(id);
        _loadHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('QR Code deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: REdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      btnOkText: 'Delete',
      btnOkColor: AppTheme.primary,
    ).show();
  }

  Future<void> _copyToClipboard(String data) async {
    await Clipboard.setData(ClipboardData(text: data));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: REdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  Future<void> _shareQRData(String data) async {
    try {
      await SharePlus.instance.share(ShareParams(text: data));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to share QR code'),
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

  void _showOptionsBottomSheet(QRHistoryModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        return Container(
          padding: REdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              20.verticalSpace,
              Text(
                'QR Code Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              30.verticalSpace,
              _buildOptionTile(
                icon: Icons.copy,
                title: 'Copy',
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(item.data);
                },
              ),
              _buildOptionTile(
                icon: Icons.share,
                title: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  _shareQRData(item.data);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Delete',
                onTap: () {
                  Navigator.pop(context);
                  _deleteItem(item.id);
                },
              ),
              20.verticalSpace,
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: REdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              CustomAppbar(title: 'History'),
              20.verticalSpace,
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              else if (_history.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80.sp,
                          color: AppTheme.primary,
                        ),
                        20.verticalSpace,
                        Text(
                          'No History Yet',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        10.verticalSpace,
                        Text(
                          'Scanned and generated QR codes\nwill appear here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: REdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return Container(
                        margin: REdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primary, blurRadius: 4),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: REdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          leading: QrImageView(
                            padding: REdgeInsets.all(5),
                            data: item.data,
                            size: 60.w,
                          ),
                          title: Text(
                            item.data,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              5.verticalSpace,
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy - hh:mm a',
                                ).format(item.createdAt),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: AppTheme.primary,
                                ),
                              ),
                              10.verticalSpace,
                              Container(
                                padding: REdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withAlpha(200),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Text(
                                  item.type == QRType.scanned
                                      ? 'Scanned'
                                      : 'Generated',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: AppTheme.primary,
                              size: 30.sp,
                            ),
                            onPressed: () => _showOptionsBottomSheet(item),
                          ),
                          onTap: () => _showOptionsBottomSheet(item),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
