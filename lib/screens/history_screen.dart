import 'package:flutter/material.dart';

import '../main.dart';
import '../theme.dart';
import '../widgets/cover.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _when(DateTime d) {
    final now = DateTime.now();
    final hm =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (days == 0) return 'hoje\n$hm';
    if (days == 1) return 'ontem\n$hm';
    return '${d.day}/${d.month}\n$hm';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.history;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(children: [
              Expanded(
                  child: Text('Histórico',
                      style: Theme.of(context).textTheme.headlineSmall)),
              if (items.isNotEmpty)
                TextButton(
                    onPressed: store.clearHistory,
                    child: const Text('Limpar')),
            ]),
            const SizedBox(height: 4),
            const Text('Músicas que você já identificou',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text(
                    'Nada por aqui ainda.\nToque em Ouvir para descobrir sua primeira música.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.5)),
              ),
            for (final s in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.panel2,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ResultScreen(song: s))),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(children: [
                        Cover(url: s.coverUrl, size: 50, radius: 10),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(s.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text(_when(s.foundAt),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ]),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
