import 'package:flutter/foundation.dart';

/// Returns the current platform name as a lowercase string (e.g. 'android', 'ios', 'web').
///
/// Fully compatible with all Flutter platforms including WebAssembly (WASM),
/// with zero dependencies on `dart:io`.
String currentPlatformName() {
  if (kIsWeb) return 'web';
  return defaultTargetPlatform.name.toLowerCase();
}
