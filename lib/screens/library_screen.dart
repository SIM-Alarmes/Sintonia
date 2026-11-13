import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/cover.dart';
import 'search_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _player = AudioPlayer();
  String? _playingId;

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed && mounted) {
        setState(() => _playingId = null);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(DownloadedTrack d) async {
    if (_playingId == d.track.id) {
      await _player.pause();
      setState(() => _playingId = null);
      return;
    }
    setState(() => _playingId = d.track.id);
    await _player.setFilePath(d.filePath);
    _player.play();
  }

  String _mb(int bytes) =>
      '${(bytes / 1024 / 1024).toStringAsFixed(1).replaceAll('.', ',')} MB';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.downloads;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Minhas músicas',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text('Baixadas no celular, tocam sem internet',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen())),
              icon: const Icon(Icons.search),
              label: const Text('Buscar músicas livres para baixar'),
            ),
            const SizedBox(height: 16),
            for (final e in store.inProgress.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LinearProgressIndicator(
                    value: e.value, color: AppColors.ok, minHeight: 4),
              ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Text(
                    'Você ainda não baixou nenhuma música.\nBusque músicas livres no botão acima.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.5)),
              ),
            for (final d in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey(d.track.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                        color: Colors.red.shade900,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) {
                    if (_playingId == d.track.id) _player.stop();
                    store.deleteDownload(d);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.panel2,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Cover(url: d.track.coverUrl, size: 50, radius: 10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text('${d.track.artist} · ${_mb(d.bytes)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.hot),
                        onPressed: () => _toggle(d),
                        icon: Icon(_playingId == d.track.id
                            ? Icons.pause
                            : Icons.play_arrow),
                      ),
                    ]),
                  ),
                ),
              ),
            if (items.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Arraste para a esquerda para apagar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }
}
