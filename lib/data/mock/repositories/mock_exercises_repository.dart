import '../../models/exercise.dart';
import '../../models/exercise_response.dart';
import '../../models/principle.dart';
import '../../repositories/exercises_repository.dart';
import '../mock_data.dart';

/// In-memory exercise library and response store.
class MockExercisesRepository implements ExercisesRepository {
  final List<Exercise> _exercises = List<Exercise>.from(MockData.exercises);
  final Map<String, List<ExerciseResponse>> _responses =
      Map<String, List<ExerciseResponse>>.from(MockData.exerciseResponses);

  @override
  Future<List<Exercise>> loadExercises() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return List<Exercise>.unmodifiable(_exercises);
  }

  @override
  Future<List<Exercise>> loadByPrinciple(Principle? principle) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (principle == null) {
      return List<Exercise>.unmodifiable(_exercises);
    }
    return List<Exercise>.unmodifiable(
      _exercises.where((Exercise e) => e.principle == principle),
    );
  }

  @override
  Future<Exercise?> loadExercise(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final Exercise exercise in _exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }

  @override
  Future<List<ExerciseResponse>> loadResponses(String exerciseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List<ExerciseResponse>.unmodifiable(
      _responses[exerciseId] ?? const <ExerciseResponse>[],
    );
  }

  @override
  Future<Exercise> completeExercise({
    required String exerciseId,
    required List<ExerciseResponse> responses,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final int index = _exercises.indexWhere((Exercise e) => e.id == exerciseId);
    final Exercise updated = _exercises[index].copyWith(
      completedAt: DateTime.now(),
    );
    _exercises[index] = updated;
    _responses[exerciseId] = List<ExerciseResponse>.from(responses);
    return updated;
  }
}
