import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

/// Guarda o histórico e as músicas baixadas no próprio celular.
class Store extends ChangeNotifier {
  static const _kHistory = 'history';
  static const _kDownloads = 'downloads';

  final List<Song> history = [];
  final List<DownloadedTrack> downloads = [];

  /// id da música -> progresso de 0 a 1 enquanto baixa
  final Map<String, double> inProgress = {};

  late SharedPreferences _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    for (final s in _prefs.getStringList(_kHistory) ?? <String>[]) {
      try {
        history.add(Song.fromJson(jsonDecode(s)));
      } catch (_) {}
    }
    for (final s in _prefs.getStringList(_kDownloads) ?? <String>[]) {
      try {
        final d = DownloadedTrack.fromJson(jsonDecode(s));
        if (File(d.filePath).existsSync()) downloads.add(d);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> addToHistory(Song song) async {
    history.insert(0, song);
    if (history.length > 200) history.removeLast();
    await _prefs.setStringList(
        _kHistory, history.map((s) => jsonEncode(s.toJson())).toList());
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();
    await _prefs.remove(_kHistory);
    notifyListeners();
  }

  bool isDownloaded(String id) => downloads.any((d) => d.track.id == id);

  Future<void> download(FreeTrack t) async {
    if (isDownloaded(t.id) || inProgress.containsKey(t.id)) return;
    inProgress[t.id] = 0;
    notifyListeners();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final safe = '${t.artist} - ${t.title}'
          .replaceAll(RegExp(r'[^\w\s\-]'), '')
          .trim();
      final file = File('${dir.path}/musicas/$safe-${t.id}.mp3');
      await file.parent.create(recursive: true);

      final res = await http.Client().send(http.Request('GET', Uri.parse(t.downloadUrl)));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final total = res.contentLength ?? 0;
      final sink = file.openWrite();
      var got = 0;
      await for (final chunk in res.stream) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) {
          inProgress[t.id] = got / total;
          notifyListeners();
        }
      }
      await sink.close();

      downloads.insert(
          0, DownloadedTrack(track: t, filePath: file.path, bytes: got));
      await _saveDownloads();
    } finally {
      inProgress.remove(t.id);
      notifyListeners();
    }
  }

  Future<void> deleteDownload(DownloadedTrack d) async {
    try {
      await File(d.filePath).delete();
    } catch (_) {}
    downloads.remove(d);
    await _saveDownloads();
    notifyListeners();
  }

  Future<void> _saveDownloads() => _prefs.setStringList(
      _kDownloads, downloads.map((d) => jsonEncode(d.toJson())).toList());
}
