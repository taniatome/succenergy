/// Named animation durations.
///
/// Interface motion stays between 200ms and 400ms. Only the splash sequence,
/// which is a deliberate brand moment, runs longer.
class AppDurations {
  const AppDurations._();

  /// Immediate feedback: button press, chip selection.
  static const Duration instant = Duration(milliseconds: 120);

  /// Standard state change.
  static const Duration fast = Duration(milliseconds: 200);

  /// Default entrance and transition.
  static const Duration medium = Duration(milliseconds: 320);

  /// Emphasised entrance, ring draw-in, celebration bloom.
  static const Duration slow = Duration(milliseconds: 420);

  /// Gap between staggered siblings in a reveal sequence.
  static const Duration stagger = Duration(milliseconds: 60);

  /// One full turn of the loading ring's travelling highlight.
  static const Duration loaderTurn = Duration(milliseconds: 1500);

  /// Continuous pulse on the active cycle segment.
  static const Duration pulse = Duration(milliseconds: 2400);

  /// Ambient background drift on the AI Coach screen.
  static const Duration ambientDrift = Duration(seconds: 18);

  /// Simulated coach thinking time before a reply resolves.
  static const Duration coachThinking = Duration(milliseconds: 1400);

  /// Goal completion: the gold bloom that radiates off the progress ring.
  /// The second deliberate brand moment, and the only interface motion
  /// besides the splash that runs past 400ms.
  static const Duration goalCompletion = Duration(milliseconds: 720);

  /// Splash: logo bloom expansion.
  static const Duration splashBloom = Duration(milliseconds: 1100);

  /// Splash: total time on screen before routing onward.
  static const Duration splashHold = Duration(milliseconds: 2600);
}
