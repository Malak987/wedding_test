import 'dart:html' as html;
import 'dart:js' as js;

/// Browser-only helpers used by RSVP identity, calendar downloads, and
/// platform detection. This file is conditionally imported only on Web.
class WebRuntime {
  WebRuntime._();

  static String? readStorage(String key) {
    try {
      return html.window.localStorage[key];
    } catch (_) {
      return null;
    }
  }

  static void writeStorage(String key, String value) {
    try {
      html.window.localStorage[key] = value;
    } catch (_) {}
  }

  static String get userAgent {
    try {
      return html.window.navigator.userAgent;
    } catch (_) {
      return '';
    }
  }

  static int get maxTouchPoints {
    try {
      final value = js.context.callMethod('eval', ['navigator.maxTouchPoints || 0']);
      if (value is num) return value.toInt();
    } catch (_) {}
    return 0;
  }

  /// IANA timezone when available, e.g. `Africa/Cairo`.
  static String get localTimeZone {
    try {
      final value = js.context.callMethod(
        'eval',
        ['Intl.DateTimeFormat().resolvedOptions().timeZone'],
      );
      if (value is String && value.trim().isNotEmpty) return value;
    } catch (_) {}
    return DateTime.now().timeZoneName;
  }

  static void downloadTextFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) {
    final blob = html.Blob([content], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
