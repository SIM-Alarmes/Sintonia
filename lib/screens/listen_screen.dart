import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../services/jamendo.dart';
import '../services/recognizer.dart';
import '../theme.dart';
import 'result_screen.dart';

class ListenScreen extends StatefulWidget {
  const ListenScreen({super.key});
  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen>
    with SingleTickerProviderStateMixin {
  final _recognizer = Recognizer();
  final _jamendo = Jamendo();
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600));

  String _status = 'idle'; // idle, listening, thinking

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (_status != 'idle') return;
    setState(() => _status = 'listening');
    _pulse.repeat();
    try {
      final songFuture = _recognizer.listenAndRecognize();
      // depois de gravar, mostra "procurando"
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted && _status == 'listening') {
          setState(() => _status = 'thinking');
        }
      });
      var song = await songFuture;
      if (!mounted) return;
      if (song == null) {
        _snack('Não reconheci essa música. Chegue mais perto do som e tente de novo.');
        return;
      }
      final free = await _jamendo.findSame(song);
      if (free != null) song = song.copyWith(freeTrack: free);
      await store.addToHistory(song);
      if (!mounted) return;
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ResultScreen(song: song!)));
    } on RecognizeException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('Algo deu errado. Tente de novo.');
    } finally {
      _pulse.stop();
      _pulse.reset();
      if (mounted) setState(() => _status = 'idle');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final busy = _status != 'idle';
    final hint = switch (_status) {
      'listening' => 'Ouvindo… aproxime o celular do som',
      'thinking' => 'Procurando a música…',
      _ => 'Toque para descobrir a música que está tocando',
    };
    final label = switch (_status) {
      'listening' => 'Ouvindo…',
      'thinking' => 'Procurando…',
      _ => 'Ouvir',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.fg),
              children: const [
                TextSpan(text: 'sinton'),
                TextSpan(text: 'i', style: TextStyle(color: AppColors.hot)),
                TextSpan(text: 'a'),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 16)),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(alignment: Alignment.center, children: [
                  if (busy) ...[
                    _Ring(anim: _pulse, delay: 0),
                    _Ring(anim: _pulse, delay: .5),
                  ],
                  GestureDetector(
                    onTap: _listen,
                    child: Semantics(
                      button: true,
                      label: 'Ouvir música',
                      child: Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment(-.3, -.4),
                            colors: [
                              Color(0xFFFF8DB4),
                              AppColors.hot,
                              AppColors.cool
                            ],
                            stops: [0, .45, 1],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x666B5BFF),
                                blurRadius: 60,
                                spreadRadius: 4)
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(busy ? Icons.graphic_eq : Icons.mic,
                                color: Colors.white, size: 44),
                            const SizedBox(height: 6),
                            Text(label,
                                style: GoogleFonts.sora(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Ring extends StatelessWidget {
  final AnimationController anim;
  final double delay;
  const _Ring({required this.anim, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, _) {
        final t = (anim.value + delay) % 1;
        return Opacity(
          opacity: (1 - t) * .8,
          child: Container(
            width: 200 + 100 * t,
            height: 200 + 100 * t,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.hot, width: 2),
            ),
          ),
        );
      },
    );
  }
}
