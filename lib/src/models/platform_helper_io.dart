import 'dart:io' show Platform;

/// Returns the current platform name on non-web targets (VM / Flutter native).
String currentPlatformName() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  if (Platform.isLinux) return 'linux';
  if (Platform.isFuchsia) return 'fuchsia';
  return 'unknown';
}
