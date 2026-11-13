import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models.dart';

/// Busca músicas com licença livre no Jamendo. Só devolve faixas em que o
/// próprio artista liberou o download.
class Jamendo {
  Future<List<FreeTrack>> search(String text, {int limit = 20}) async {
    if (!Config.hasJamendo || text.trim().isEmpty) return [];
    final uri = Uri.https('api.jamendo.com', '/v3.0/tracks/', {
      'client_id': Config.jamendoClientId,
      'format': 'json',
      'limit': '$limit',
      'search': text,
      'audioformat': 'mp32', // MP3 de alta qualidade (VBR ~ 320 kbps)
      'audiodlformat': 'mp32',
      'include': 'licenses',
      'imagesize': '600',
    });
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    final results = (data['results'] as List?) ?? [];
    return results
        .where((t) =>
            t['audiodownload_allowed'] == true &&
            (t['audiodownload'] ?? '').toString().isNotEmpty)
        .map((t) => FreeTrack(
              id: '${t['id']}',
              title: t['name'] ?? '',
              artist: t['artist_name'] ?? '',
              coverUrl: t['album_image'] ?? t['image'],
              downloadUrl: t['audiodownload'],
              license: _license(t['license_ccurl']),
              durationSeconds: (t['duration'] as num?)?.toInt() ?? 0,
            ))
        .toList();
  }

  /// Procura a mesma música (mesmo título e artista) no Jamendo.
  Future<FreeTrack?> findSame(Song song) async {
    try {
      final found = await search(song.searchText, limit: 10);
      String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      for (final t in found) {
        if (norm(t.artist) == norm(song.artist) &&
            norm(t.title).contains(norm(song.title))) {
          return t;
        }
      }
    } catch (_) {}
    return null;
  }

  String _license(dynamic url) {
    final u = (url ?? '').toString();
    final m = RegExp(r'licenses/([a-z\-]+)/').firstMatch(u);
    return m == null ? 'Creative Commons' : 'CC ${m.group(1)!.toUpperCase()}';
  }
}
