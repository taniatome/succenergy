import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/exercise.dart';
import '../models/exercise_response.dart';
import '../models/principle.dart';
import '../repositories/exercises_repository.dart';
import 'exercise_mapper.dart';

/// The exercise library and the answers saved against it.
///
/// The library at `/v1/exercises` is shared and carries no per-account state,
/// so `completedAt` is merged in from the caller's own responses. That is two
/// reads for the library screen and it has to be: whether *this* person has
/// done an exercise is not a property of the exercise.
class ApiExercisesRepository implements ExercisesRepository {
  const ApiExercisesRepository(this._api);

  final ApiClient _api;

  static const String _libraryPath = '/exercises';
  static const String _responsesPath = '/me/exercise-responses';

  @override
  Future<List<Exercise>> loadExercises() async {
    // Fetched together rather than in sequence: neither depends on the other,
    // and the library screen should not pay for two round trips end to end.
    final List<Object?> library;
    final List<Object?> responses;
    (library, responses) =
        await (_api.getAll(_libraryPath), _api.getAll(_responsesPath)).wait;

    final Map<String, DateTime> completions =
        ExerciseMapper.completionsFromJson(responses);

    return ExerciseMapper.listFromJson(library)
        .map(
          (Exercise exercise) =>
              completions.containsKey(exercise.id)
                  ? exercise.copyWith(completedAt: completions[exercise.id])
                  : exercise,
        )
        .toList(growable: false);
  }

  /// Filtered in the app rather than by a query parameter.
  ///
  /// The library is small and already loaded whole for the principle
  /// selector, which shows a count per principle — narrowing on the server
  /// would mean seven requests to draw one screen.
  @override
  Future<List<Exercise>> loadByPrinciple(Principle? principle) async {
    final List<Exercise> all = await loadExercises();
    if (principle == null) {
      return all;
    }
    return all
        .where((Exercise exercise) => exercise.principle == principle)
        .toList(growable: false);
  }

  @override
  Future<Exercise?> loadExercise(String id) async {
    try {
      return ExerciseMapper.fromJson(await _api.get('$_libraryPath/$id'));
    } on ApiException catch (error) {
      if (error.kind == ApiFailureKind.notFound) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<ExerciseResponse>> loadResponses(String exerciseId) async {
    return ExerciseMapper.allResponsesFromJson(
      await _api.getAll('$_responsesPath?exerciseId=$exerciseId'),
    );
  }

  /// Records a finished session and answers with the exercise, now completed.
  ///
  /// The interface returns the exercise rather than the response because the
  /// library card is what changes on screen. The completion time comes from
  /// the stored row, so it is the server's clock rather than the device's.
  @override
  Future<Exercise> completeExercise({
    required String exerciseId,
    required List<ExerciseResponse> responses,
  }) async {
    final Map<String, Object?> stored = await _api.post(
      _responsesPath,
      body: ExerciseMapper.submitBody(
        exerciseId: exerciseId,
        responses: responses,
      ),
    );

    final Exercise? exercise = await loadExercise(exerciseId);
    if (exercise == null) {
      throw const ApiException(ApiFailureKind.notFound);
    }

    return exercise.copyWith(
      completedAt:
          ExerciseMapper.completionsFromJson(<Object?>[stored])[exerciseId],
    );
  }
}
