import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in a new browser tab (web) or external app.
Future<void> launchAppUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // Silently ignore — avoid crashing the invitation page.
  }
}

/// Builds a tel: link and launches it.
Future<void> launchPhoneCall(String phoneNumber) async {
  await launchAppUrl('tel:$phoneNumber');
}
