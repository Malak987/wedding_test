/// Cross-platform fallback for APIs that only exist in browsers.
///
/// The real implementation is selected on Flutter Web through a conditional
/// import. Keeping this stub lets the project still analyze/test on non-web
/// platforms without importing `dart:html`.
class WebRuntime {
  WebRuntime._();

  static String? readStorage(String key) => null;

  static void writeStorage(String key, String value) {}

  static String get userAgent => '';

  static int get maxTouchPoints => 0;

  static String get localTimeZone => DateTime.now().timeZoneName;

  static void downloadTextFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) {}
}
