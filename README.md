# Sintonia

App (Android e iPhone) que ouve a música tocando, mostra nome, artista, capa e letra,
e baixa em alta qualidade as músicas de licença livre (Jamendo). Para músicas
comerciais, abre Spotify, Deezer, YouTube Music ou Apple Music.

- Reconhecimento: [AudD](https://audd.io)
- Músicas livres: [Jamendo API](https://devportal.jamendo.com)
- Feito em Flutter 3.24

Leia o **GUIA.md** para configurar as chaves e instalar no celular.

## Estrutura

- `lib/config.dart`: chaves das APIs
- `lib/services/recognizer.dart`: grava 8 s do microfone e consulta o AudD
- `lib/services/jamendo.dart`: busca músicas livres com download liberado
- `lib/services/store.dart`: histórico e downloads salvos no celular
- `lib/screens/`: telas Ouvir, Resultado, Histórico, Minhas músicas e Busca
