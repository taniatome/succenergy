import '../../core/network/api_client.dart';
import '../models/milestone.dart';
import '../models/principle.dart';
import '../models/progress_snapshot.dart';
import '../repositories/progress_repository.dart';
import 'json_reader.dart';
import 'progress_mapper.dart';

/// Progress against `/v1/me/progress`.
///
/// The interface asks five separate questions and the API answers all five in
/// one payload, so the read is shared rather than repeated: a screen that
/// calls all five methods makes one request.
///
/// The window is deliberately short. It exists to collapse one screen's five
/// calls into one request, not to cache progress — reopening the screen after
/// completing a goal has to show the new number, which is the whole point of
/// these figures being derived rather than stored.
class ApiProgressRepository implements ProgressRepository {
  ApiProgressRepository(this._api);

  final ApiClient _api;

  static const String _path = '/me/progress';

  /// How long one fetch answers for. Long enough for a screen build, short
  /// enough that a return visit is a fresh read.
  static const Duration _window = Duration(seconds: 2);

  Future<Map<String, Object?>>? _inFlight;
  DateTime? _fetchedAt;

  /// The summary, shared across the calls of a single screen build.
  ///
  /// The in-flight future is handed to concurrent callers rather than each
  /// starting its own request, which is what makes five simultaneous calls
  /// one round trip instead of five.
  Future<Map<String, Object?>> _summary() {
    final DateTime? fetchedAt = _fetchedAt;
    final Future<Map<String, Object?>>? pending = _inFlight;

    if (pending != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _window) {
      return pending;
    }

    _fetchedAt = DateTime.now();
    final Future<Map<String, Object?>> request = _api.get(_path);
    _inFlight = request;
    return request;
  }

  /// Drops the shared read, so the next call goes to the server.
  ///
  /// Called after recording a snapshot: the figures have just changed and
  /// answering from the window would show the state before the write.
  void _invalidate() {
    _inFlight = null;
    _fetchedAt = null;
  }

  @override
  Future<List<ProgressSnapshot>> loadHistory() async {
    final Map<String, Object?> summary = await _summary();
    return ProgressMapper.snapshotsFromJson(summary['snapshots']);
  }

  @override
  Future<Map<Principle, int>> loadPracticeByPrinciple() async {
    final Map<String, Object?> summary = await _summary();
    return ProgressMapper.breakdownFromJson(summary['principleBreakdown']);
  }

  @override
  Future<List<Milestone>> loadReachedMilestones() async {
    final Map<String, Object?> summary = await _summary();
    return ProgressMapper.milestonesFromJson(summary['reachedMilestones']);
  }

  @override
  Future<double> loadCycleCompletion() async {
    final Map<String, Object?> summary = await _summary();
    return Json.number(summary['cycleCompletion']);
  }

  @override
  Future<Map<String, int>> loadHeadlineStats() async {
    final Map<String, Object?> summary = await _summary();
    return ProgressMapper.headlineFromJson(summary['headline']);
  }

  /// Records today's activity.
  ///
  /// Not on the interface: nothing in the app calls it yet, and it is here so
  /// the endpoint has a client when the app starts recording days. It takes
  /// no body — the server reads the figures itself.
  Future<void> recordSnapshot() async {
    await _api.post('$_path/snapshot');
    _invalidate();
  }
}
