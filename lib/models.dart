/// Uma música identificada pelo app.
class Song {
  final String title;
  final String artist;
  final String album;
  final String? coverUrl;
  final String? lyrics;
  final String? spotifyUrl;
  final String? deezerUrl;
  final String? appleUrl;
  final DateTime foundAt;

  /// Preenchido quando a mesma música existe com licença livre no Jamendo.
  final FreeTrack? freeTrack;

  Song({
    required this.title,
    required this.artist,
    this.album = '',
    this.coverUrl,
    this.lyrics,
    this.spotifyUrl,
    this.deezerUrl,
    this.appleUrl,
    this.freeTrack,
    DateTime? foundAt,
  }) : foundAt = foundAt ?? DateTime.now();

  String get searchText => '$artist $title';

  Uri get youtubeMusicUrl => Uri.https(
      'music.youtube.com', '/search', {'q': searchText});

  Song copyWith({String? lyrics, FreeTrack? freeTrack}) => Song(
        title: title,
        artist: artist,
        album: album,
        coverUrl: coverUrl,
        lyrics: lyrics ?? this.lyrics,
        spotifyUrl: spotifyUrl,
        deezerUrl: deezerUrl,
        appleUrl: appleUrl,
        freeTrack: freeTrack ?? this.freeTrack,
        foundAt: foundAt,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'artist': artist,
        'album': album,
        'coverUrl': coverUrl,
        'lyrics': lyrics,
        'spotifyUrl': spotifyUrl,
        'deezerUrl': deezerUrl,
        'appleUrl': appleUrl,
        'foundAt': foundAt.toIso8601String(),
        'freeTrack': freeTrack?.toJson(),
      };

  factory Song.fromJson(Map<String, dynamic> j) => Song(
        title: j['title'] ?? '',
        artist: j['artist'] ?? '',
        album: j['album'] ?? '',
        coverUrl: j['coverUrl'],
        lyrics: j['lyrics'],
        spotifyUrl: j['spotifyUrl'],
        deezerUrl: j['deezerUrl'],
        appleUrl: j['appleUrl'],
        foundAt: DateTime.tryParse(j['foundAt'] ?? '') ?? DateTime.now(),
        freeTrack: j['freeTrack'] == null
            ? null
            : FreeTrack.fromJson(Map<String, dynamic>.from(j['freeTrack'])),
      );
}

/// Uma música com licença livre (Creative Commons) do Jamendo,
/// que pode ser baixada legalmente.
class FreeTrack {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final String downloadUrl;
  final String license;
  final int durationSeconds;

  FreeTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.downloadUrl,
    this.coverUrl,
    this.license = '',
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'coverUrl': coverUrl,
        'downloadUrl': downloadUrl,
        'license': license,
        'durationSeconds': durationSeconds,
      };

  factory FreeTrack.fromJson(Map<String, dynamic> j) => FreeTrack(
        id: '${j['id']}',
        title: j['title'] ?? '',
        artist: j['artist'] ?? '',
        coverUrl: j['coverUrl'],
        downloadUrl: j['downloadUrl'] ?? '',
        license: j['license'] ?? '',
        durationSeconds: j['durationSeconds'] ?? 0,
      );
}

/// Uma música salva no celular.
class DownloadedTrack {
  final FreeTrack track;
  final String filePath;
  final int bytes;

  DownloadedTrack(
      {required this.track, required this.filePath, required this.bytes});

  Map<String, dynamic> toJson() =>
      {'track': track.toJson(), 'filePath': filePath, 'bytes': bytes};

  factory DownloadedTrack.fromJson(Map<String, dynamic> j) => DownloadedTrack(
        track: FreeTrack.fromJson(Map<String, dynamic>.from(j['track'])),
        filePath: j['filePath'],
        bytes: j['bytes'] ?? 0,
      );
}
