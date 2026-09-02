/// Normalizes socket URLs for [socket_io_client], which expects an HTTP(S) origin.
String normalizeSocketOrigin(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.startsWith('wss://')) {
    return trimmed.replaceFirst('wss://', 'https://');
  }
  if (trimmed.startsWith('ws://')) {
    return trimmed.replaceFirst('ws://', 'http://');
  }
  return trimmed;
}

/// Resolves the Socket.IO origin from env config.
String resolveSocketOrigin({
  required String socketUrl,
  required String baseUrl,
}) {
  final normalizedSocket = normalizeSocketOrigin(socketUrl);
  if (normalizedSocket.isNotEmpty) {
    return normalizedSocket;
  }
  return normalizeSocketOrigin(baseUrl);
}
