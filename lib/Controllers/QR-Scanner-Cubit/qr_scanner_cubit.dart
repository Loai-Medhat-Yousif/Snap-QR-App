import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap_qr/Controllers/QR-Scanner-Cubit/qr_scanner_state.dart';
import 'package:snap_qr/Model/history_model.dart';
import 'package:snap_qr/Services/history_service.dart';

class SnapQRScannerCubit extends Cubit<SnapQRScannerState> {
  final MobileScannerController controller = MobileScannerController();
  final QRHistoryService _historyService = QRHistoryService();

  SnapQRScannerCubit() : super(const SnapQRScannerState());

  Future<void> toggleFlash() async {
    try {
      await controller.toggleTorch();
      emit(state.copyWith(flashOn: !state.flashOn));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> switchCamera() async {
    try {
      await controller.switchCamera();
      emit(state.copyWith(isFrontCamera: !state.isFrontCamera));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void pauseCamera() {
    controller.stop();
  }

  void resumeCamera() {
    controller.start();
  }

  Future<void> onScan(String value) async {
    controller.stop();
    await _historyService.addHistory(
      data: value,
      type: QRType.scanned,
    );
    
    emit(state.copyWith(scannedData: value, isScanning: false));
  }

  void restartScanning() {
    controller.start();
    emit(state.copyWith(scannedData: null, isScanning: true));
  }

  Future<void> scanFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        emit(
          state.copyWith(
            errorMessage: "No image selected",
            scannedData: null,
            isScanning: false,
          ),
        );
        return;
      }

      final result = await controller.analyzeImage(pickedFile.path);
      if (result != null && result.barcodes.isNotEmpty) {
        final value = result.barcodes.first.rawValue ?? "";
        await _historyService.addHistory(
          data: value,
          type: QRType.scanned,
        );
        
        emit(
          state.copyWith(
            scannedData: value,
            isScanning: false,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            errorMessage: "No QR code found in the selected image",
            scannedData: null,
            isScanning: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          scannedData: null,
          isScanning: false,
        ),
      );
    }
  }
}