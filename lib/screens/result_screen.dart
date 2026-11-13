import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/cover.dart';

class ResultScreen extends StatelessWidget {
  final Song song;
  const ResultScreen({super.key, required this.song});

  Future<void> _open(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não consegui abrir o link.')));
      }
    }
  }

  Uri _search(String host, String path, [String key = 'q']) =>
      Uri.https(host, path, {key: song.searchText});

  @override
  Widget build(BuildContext context) {
    final free = song.freeTrack;
    final spotify = song.spotifyUrl != null
        ? Uri.parse(song.spotifyUrl!)
        : Uri.https('open.spotify.com', '/search/${song.searchText}');
    final deezer = song.deezerUrl != null
        ? Uri.parse(song.deezerUrl!)
        : Uri.https('www.deezer.com', '/search/${song.searchText}');
    final apple = song.appleUrl != null
        ? Uri.parse(song.appleUrl!)
        : _search('music.apple.com', '/search', 'term');

    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.panel),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          LayoutBuilder(
              builder: (_, c) =>
                  Cover(url: song.coverUrl, size: c.maxWidth, radius: 20)),
          const SizedBox(height: 18),
          Text(song.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
              song.album.isEmpty
                  ? song.artist
                  : '${song.artist} · ${song.album}',
              style: const TextStyle(color: AppColors.muted, fontSize: 15)),
          const SizedBox(height: 14),
          _Chip(free: free != null),
          const SizedBox(height: 16),
          if (free != null) ...[
            ListenableBuilder(
              listenable: store,
              builder: (_, _) {
                final done = store.isDownloaded(free.id);
                final p = store.inProgress[free.id];
                return FilledButton.icon(
                  onPressed: done || p != null
                      ? null
                      : () async {
                          try {
                            await store.download(free);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Pronto! Está em Minhas músicas.')));
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'O download falhou. Tente de novo.')));
                            }
                          }
                        },
                  icon: Icon(done ? Icons.check : Icons.download),
                  label: Text(done
                      ? 'Já está no seu celular'
                      : p != null
                          ? 'Baixando… ${(p * 100).round()}%'
                          : 'Baixar em alta qualidade (MP3)'),
                );
              },
            ),
            const SizedBox(height: 6),
            Text('Licença ${free.license}. Download liberado pelo artista.',
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 16),
          ],
          const Text('Ouça nos apps oficiais',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.2,
            children: [
              OutlinedButton(
                  onPressed: () => _open(context, spotify),
                  child: const Text('Spotify')),
              OutlinedButton(
                  onPressed: () => _open(context, deezer),
                  child: const Text('Deezer')),
              OutlinedButton(
                  onPressed: () => _open(context, song.youtubeMusicUrl),
                  child: const Text('YouTube Music')),
              OutlinedButton(
                  onPressed: () => _open(context, apple),
                  child: const Text('Apple Music')),
            ],
          ),
          if (song.lyrics != null && song.lyrics!.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.panel2,
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LETRA',
                      style: TextStyle(
                          letterSpacing: 1.2,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(song.lyrics!.trim(),
                      style: const TextStyle(
                          color: AppColors.muted, height: 1.6)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final bool free;
  const _Chip({required this.free});
  @override
  Widget build(BuildContext context) {
    final color = free ? AppColors.ok : AppColors.warm;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(99)),
        child: Text(
            free
                ? 'Licença livre · download liberado'
                : 'Música comercial · ouça nos apps oficiais',
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
