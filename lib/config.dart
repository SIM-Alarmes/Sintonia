/// CHAVES DAS APIs
///
/// Cole aqui as suas chaves gratuitas (veja o GUIA.md, passo 1).
/// Também é possível passar as chaves na hora de gerar o app:
///   flutter build apk --dart-define=AUDD_TOKEN=xxx --dart-define=JAMENDO_CLIENT_ID=yyy
class Config {
  /// Chave do AudD (reconhecimento de música). Pegue em https://dashboard.audd.io
  static const auddToken =
      String.fromEnvironment('AUDD_TOKEN', defaultValue: 'COLE_SUA_CHAVE_AUDD');

  /// Client ID do Jamendo (músicas livres). Pegue em https://devportal.jamendo.com
  static const jamendoClientId = String.fromEnvironment('JAMENDO_CLIENT_ID',
      defaultValue: 'COLE_SEU_CLIENT_ID_JAMENDO');

  /// Quantos segundos o app escuta antes de tentar reconhecer.
  static const listenSeconds = 8;

  static bool get hasAudd =>
      auddToken.isNotEmpty && !auddToken.startsWith('COLE_');
  static bool get hasJamendo =>
      jamendoClientId.isNotEmpty && !jamendoClientId.startsWith('COLE_');
}
