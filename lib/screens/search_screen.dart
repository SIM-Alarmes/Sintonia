import 'package:flutter/material.dart';

import '../config.dart';
import '../main.dart';
import '../models.dart';
import '../services/jamendo.dart';
import '../theme.dart';
import '../widgets/cover.dart';

/// Busca no Jamendo: mais de 500 mil músicas com licença livre.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _jamendo = Jamendo();
  final _ctrl = TextEditingController();
  List<FreeTrack> _results = [];
  bool _loading = false;
  String? _message;

  Future<void> _search() async {
    if (!Config.hasJamendo) {
      setState(() => _message = 'Falta o Client ID do Jamendo. Veja o passo 1 do guia.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final r = await _jamendo.search(_ctrl.text);
      setState(() {
        _results = r;
        if (r.isEmpty) _message = 'Nenhuma música livre encontrada.';
      });
    } catch (_) {
      setState(() => _message = 'Sem internet ou serviço fora do ar.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _download(FreeTrack t) async {
    try {
      await store.download(t);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${t.title}" está em Minhas músicas.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('O download falhou. Tente de novo.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.panel,
          title: const Text('Músicas livres')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Artista, música ou estilo (ex.: lofi, rock)',
              filled: true,
              fillColor: AppColors.panel2,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        if (_loading) const LinearProgressIndicator(color: AppColors.hot),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted)),
          ),
        Expanded(
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final t = _results[i];
                final done = store.isDownloaded(t.id);
                final p = store.inProgress[t.id];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.panel2,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Cover(url: t.coverUrl, size: 50, radius: 10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text('${t.artist} · ${t.license}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (p != null)
                        SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                                value: p, color: AppColors.ok))
                      else
                        IconButton(
                          onPressed: done ? null : () => _download(t),
                          icon: Icon(done ? Icons.check : Icons.download,
                              color: done ? AppColors.ok : AppColors.hot),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
