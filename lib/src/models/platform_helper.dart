/// Conditional-import shim for platform detection.
///
/// - On non-web targets (Flutter native + CLI Dart VM): delegates to
///   [platform_helper_io.dart] which uses `dart:io`.
/// - On Flutter Web: uses [platform_helper_web.dart] which returns `"web"`.
library;

export 'platform_helper_io.dart'
    if (dart.library.html) 'platform_helper_web.dart';
