import 'package:url_launcher/url_launcher.dart';

/// Opens a destination outside the app.
///
/// The one place `url_launcher` is called, so a screen only has to name the
/// constant it wants opened. A destination that cannot be handled — no
/// browser, a malformed address, a platform without the plugin — resolves to
/// false rather than throwing, and the caller decides what to say about it.
class ExternalLinks {
  const ExternalLinks._();

  /// Opens [url] in the platform browser. Returns false when it could not be
  /// opened.
  static Future<bool> open(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
