import '../models/exercise.dart';
import '../models/exercise_response.dart';
import '../models/exercise_step.dart';
import '../models/principle.dart';
import 'json_reader.dart';

/// Translates between the exercise endpoints and the app's models.
///
/// Two shapes have to be reconciled here. The API stores one row per
/// completed run, with the answers as a map; the Dart model is one
/// `ExerciseResponse` per step. So a session read fans out into entries and a
/// submission collapses back into a map — and the closing reflection, which
/// is not one of the exercise's declared steps, travels in its own field
/// rather than as a map entry.
class ExerciseMapper {
  const ExerciseMapper._();

  /// Wire step types are snake case; the Dart enum is camel case.
  static const Map<String, ExerciseStepType> _stepTypes =
      <String, ExerciseStepType>{
        'free_text': ExerciseStepType.freeText,
        'single_choice': ExerciseStepType.singleChoice,
        'scale': ExerciseStepType.scale,
      };

  static Exercise fromJson(Map<String, Object?> json) {
    return Exercise(
      id: Json.text(json['id']),
      principle: Json.enumByName(
        json['principle'],
        Principle.values,
        Principle.purpose,
      ),
      title: Json.localized(json['title']),
      summary: Json.localized(json['summary']),
      durationMinutes: Json.integer(json['durationMinutes']),
      steps: Json.objects(
        json['steps'],
      ).map(_stepFromJson).toList(growable: false),
      suggestedAction: Json.localized(json['suggestedAction']),
    );
  }

  static List<Exercise> listFromJson(Object? value) {
    return Json.objects(value).map(fromJson).toList(growable: false);
  }

  static ExerciseStep _stepFromJson(Map<String, Object?> json) {
    return ExerciseStep(
      // `saveAs` is what an answer is filed under when the exercise names one,
      // and the step id otherwise — the same rule the API documents.
      id: Json.text(json['saveAs'], fallback: Json.text(json['id'])),
      type: _stepTypes[Json.text(json['type'])] ?? ExerciseStepType.freeText,
      prompt: Json.localized(json['prompt']),
      help: Json.localized(json['help']),
      options: Json.objects(
        json['options'],
      ).map(Json.localized).toList(growable: false),
      scaleLowLabel: Json.localized(json['scaleLowLabel']),
      scaleHighLabel: Json.localized(json['scaleHighLabel']),
    );
  }

  /// One stored session, flattened into the per-step entries the app holds.
  ///
  /// The reflection comes back as an entry under the reserved step id, which
  /// is how the review screen finds it — the same id the model documents.
  static List<ExerciseResponse> responsesFromJson(Map<String, Object?> json) {
    final String exerciseId = Json.text(json['exerciseId']);
    final DateTime completedAt = Json.date(json['completedAt']);
    final Map<String, String> answers = Json.strings(json['stepResponses']);
    final String reflection = Json.text(json['reflection']);

    final List<ExerciseResponse> entries = <ExerciseResponse>[
      for (final MapEntry<String, String> answer in answers.entries)
        ExerciseResponse(
          exerciseId: exerciseId,
          stepId: answer.key,
          value: answer.value,
          answeredAt: completedAt,
        ),
    ];

    if (reflection.isNotEmpty) {
      entries.add(
        ExerciseResponse(
          exerciseId: exerciseId,
          stepId: ExerciseResponse.reflectionStepId,
          value: reflection,
          answeredAt: completedAt,
        ),
      );
    }

    return entries;
  }

  /// Every session in a list response, flattened and concatenated.
  static List<ExerciseResponse> allResponsesFromJson(Object? value) {
    return Json.objects(
      value,
    ).expand(responsesFromJson).toList(growable: false);
  }

  /// The body `POST /v1/me/exercise-responses` takes.
  ///
  /// The reflection is lifted out of the per-step list into its own field.
  /// The mock layer collected it on the closing screen and dropped it; this
  /// is the field that keeps it.
  ///
  /// `principle` is deliberately absent: the API reads it from the exercise
  /// row, so a client cannot file practice under a principle it did not do.
  static Map<String, Object?> submitBody({
    required String exerciseId,
    required List<ExerciseResponse> responses,
  }) {
    final Map<String, String> steps = <String, String>{};
    String reflection = '';

    for (final ExerciseResponse response in responses) {
      if (response.stepId == ExerciseResponse.reflectionStepId) {
        reflection = response.value;
        continue;
      }
      steps[response.stepId] = response.value;
    }

    return <String, Object?>{
      'exerciseId': exerciseId,
      'stepResponses': steps,
      'reflection': reflection,
    };
  }

  /// The most recent completion per exercise, from a list of sessions.
  ///
  /// The library is shared and carries no per-account state, so completion is
  /// merged in from the caller's own responses rather than read off it.
  static Map<String, DateTime> completionsFromJson(Object? value) {
    final Map<String, DateTime> newest = <String, DateTime>{};

    for (final Map<String, Object?> session in Json.objects(value)) {
      final String exerciseId = Json.text(session['exerciseId']);
      final DateTime completedAt = Json.date(session['completedAt']);
      final DateTime? existing = newest[exerciseId];

      if (existing == null || completedAt.isAfter(existing)) {
        newest[exerciseId] = completedAt;
      }
    }

    return newest;
  }
}
