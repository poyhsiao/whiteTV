import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/history/models/play_history.dart';

class HistoryLocalService {
  static const String _key = 'play_history';
  final SharedPreferences _prefs;

  HistoryLocalService(this._prefs);

  static Future<HistoryLocalService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return HistoryLocalService(prefs);
  }

  Future<List<PlayHistory>> getAll() async {
    final String? data = _prefs.getString(_key);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
    final records = jsonList
        .map((e) => PlayHistory.fromJson(e as Map<String, dynamic>))
        .toList();

    records.sort((a, b) => b.saveTime.compareTo(a.saveTime));
    return records;
  }

  Future<void> save(PlayHistory history) async {
    final records = await getAll();

    final existingIndex = records.indexWhere((r) => r.key == history.key);
    if (existingIndex >= 0) {
      records[existingIndex] = history;
    } else {
      records.add(history);
    }

    records.sort((a, b) => b.saveTime.compareTo(a.saveTime));

    final jsonList = records.map((r) => r.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }

  Future<void> delete(String key) async {
    final records = await getAll();
    records.removeWhere((r) => r.key == key);

    final jsonList = records.map((r) => r.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
