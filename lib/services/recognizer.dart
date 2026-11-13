import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../config.dart';
import '../models.dart';

class RecognizeException implements Exception {
  final String message;
  RecognizeException(this.message);
  @override
  String toString() => message;
}

/// Grava alguns segundos de áudio pelo microfone e pergunta ao AudD
/// qual música é.
class Recognizer {
  final _recorder = AudioRecorder();

  Future<bool> askMicPermission() => _recorder.hasPermission();

  Future<Song?> listenAndRecognize() async {
    if (!Config.hasAudd) {
      throw RecognizeException(
          'Falta a chave do AudD. Veja o passo 1 do guia.');
    }
    if (!await _recorder.hasPermission()) {
      throw RecognizeException(
          'O app precisa do microfone. Libere nas configurações do celular.');
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/amostra.m4a';
    await _recorder.start(
      const RecordConfig(
          encoder: AudioEncoder.aacLc, sampleRate: 44100, bitRate: 128000),
      path: path,
    );
    await Future.delayed(const Duration(seconds: Config.listenSeconds));
    final recorded = await _recorder.stop();
    if (recorded == null) {
      throw RecognizeException('Não consegui gravar o som. Tente de novo.');
    }

    try {
      return await _askAudd(File(recorded));
    } on SocketException {
      throw RecognizeException('Sem internet. Verifique sua conexão.');
    }
  }

  Future<Song?> _askAudd(File audio) async {
    final req = http.MultipartRequest('POST', Uri.parse('https://api.audd.io/'))
      ..fields['api_token'] = Config.auddToken
      ..fields['return'] = 'apple_music,spotify,deezer'
      ..files.add(await http.MultipartFile.fromPath('file', audio.path));
    final res = await http.Response.fromStream(await req.send());
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (data['status'] != 'success') {
      final msg = (data['error']?['error_message'] ?? 'erro desconhecido');
      throw RecognizeException('O serviço de reconhecimento recusou: $msg');
    }
    final r = data['result'];
    if (r == null) return null; // não reconheceu

    final spotify = r['spotify'];
    final deezer = r['deezer'];
    final apple = r['apple_music'];

    String? cover;
    final imgs = spotify?['album']?['images'];
    if (imgs is List && imgs.isNotEmpty) cover = imgs.first['url'];
    cover ??= deezer?['album']?['cover_xl'];
    final appleArt = apple?['artwork']?['url'];
    if (cover == null && appleArt is String) {
      cover = appleArt.replaceAll('{w}', '600').replaceAll('{h}', '600');
    }

    final song = Song(
      title: r['title'] ?? 'Sem título',
      artist: r['artist'] ?? 'Artista desconhecido',
      album: r['album'] ?? '',
      coverUrl: cover,
      spotifyUrl: spotify?['external_urls']?['spotify'],
      deezerUrl: deezer?['link'],
      appleUrl: apple?['url'],
    );
    final lyrics = await _findLyrics(song.searchText);
    return song.copyWith(lyrics: lyrics);
  }

  Future<String?> _findLyrics(String q) async {
    try {
      final res = await http.post(Uri.parse('https://api.audd.io/findLyrics/'),
          body: {'api_token': Config.auddToken, 'q': q});
      final data = jsonDecode(res.body);
      final list = data['result'];
      if (list is List && list.isNotEmpty) return list.first['lyrics'];
    } catch (_) {}
    return null;
  }
}
