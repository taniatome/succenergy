import 'json_reader.dart';

/// Translates `/v1/me/purpose` into the map the Purpose screen reads.
///
/// The API sends a list rather than an object keyed by prompt id, because the
/// ids are localisation keys with dots in them. The app wants the map, so the
/// conversion happens once, here.
class PurposeMapper {
  const PurposeMapper._();

  static Map<String, Map<String, String>> fromJson(Object? value) {
    final Map<String, Map<String, String>> answers =
        <String, Map<String, String>>{};

    for (final Map<String, Object?> entry in Json.objects(value)) {
      final String promptId = Json.text(entry['promptId']);
      if (promptId.isEmpty) {
        continue;
      }
      answers[promptId] = Json.localized(entry['answer']);
    }

    return answers;
  }
}
