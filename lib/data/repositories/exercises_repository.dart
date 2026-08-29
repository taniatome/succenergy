import '../models/exercise.dart';
import '../models/exercise_response.dart';
import '../models/principle.dart';

/// The exercise library and the answers the user saved against it.
abstract class ExercisesRepository {
  Future<List<Exercise>> loadExercises();

  /// The library filtered to one principle, or all of it when null.
  Future<List<Exercise>> loadByPrinciple(Principle? principle);

  Future<Exercise?> loadExercise(String id);

  Future<List<ExerciseResponse>> loadResponses(String exerciseId);

  Future<Exercise> completeExercise({
    required String exerciseId,
    required List<ExerciseResponse> responses,
  });
}
