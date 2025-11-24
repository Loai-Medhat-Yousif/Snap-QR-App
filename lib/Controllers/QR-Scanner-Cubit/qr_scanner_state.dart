import 'package:equatable/equatable.dart';

class SnapQRScannerState extends Equatable {
  final bool flashOn;
  final bool isFrontCamera;
  final bool isScanning;
  final String? scannedData;
  final String? errorMessage;

  const SnapQRScannerState({
    this.flashOn = false,
    this.isFrontCamera = false,
    this.isScanning = true,
    this.scannedData,
    this.errorMessage,
  });

  SnapQRScannerState copyWith({
    bool? flashOn,
    bool? isFrontCamera,
    bool? isScanning,
    String? scannedData,
    String? errorMessage,
  }) {
    return SnapQRScannerState(
      flashOn: flashOn ?? this.flashOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isScanning: isScanning ?? this.isScanning,
      scannedData: scannedData,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [flashOn, isFrontCamera, isScanning, scannedData, errorMessage];
}
