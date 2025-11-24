enum QRType { scanned, generated }

class QRHistoryModel {
  final String id;
  final String data;
  final QRType type;
  final DateTime createdAt;

  QRHistoryModel({
    required this.id,
    required this.data,
    required this.type,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'type': type == QRType.scanned ? 'scanned' : 'generated',
      'createdAt': createdAt.toIso8601String(),
    };
  }
  factory QRHistoryModel.fromMap(Map<String, dynamic> map) {
    return QRHistoryModel(
      id: map['id'] as String,
      data: map['data'] as String,
      type: map['type'] == 'scanned' ? QRType.scanned : QRType.generated,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
  
  QRHistoryModel copyWith({
    String? id,
    String? data,
    QRType? type,
    DateTime? createdAt,
  }) {
    return QRHistoryModel(
      id: id ?? this.id,
      data: data ?? this.data,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
