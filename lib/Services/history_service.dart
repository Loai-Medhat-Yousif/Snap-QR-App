import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_qr/Model/history_model.dart';
import 'package:uuid/uuid.dart';

class QRHistoryService {
  static const String _historyKey = 'qr_history';
  final Uuid _uuid = const Uuid();

  Future<void> addHistory({required String data, required type}) async {
    final prefs = await SharedPreferences.getInstance();

    final List<QRHistoryModel> history = await getHistory();

    final existingIndex = history.indexWhere((item) => item.data == data);

    if (existingIndex != -1) {
      history.removeAt(existingIndex);
    }

    final newItem = QRHistoryModel(
      id: _uuid.v4(),
      data: data,
      type: type,
      createdAt: DateTime.now(),
    );

    history.insert(0, newItem);

    final jsonList = history.map((item) => item.toMap()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  Future<List<QRHistoryModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);

    if (historyJson == null || historyJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(historyJson);
      return jsonList
          .map((json) => QRHistoryModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<QRHistoryModel> history = await getHistory();

    history.removeWhere((item) => item.id == id);

    final jsonList = history.map((item) => item.toMap()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }
}
