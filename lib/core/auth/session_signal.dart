import 'package:firebase_auth/firebase_auth.dart';

/// Tells [AuthState] that someone has signed in or out.
///
/// An abstraction rather than the Firebase stream directly, so the launch
/// state machine can be exercised without a Firebase project behind it — the
/// widget tests drive it from the mock repository. It carries no identity:
/// who is signed in is the resolver's answer, and all the state machine needs
/// from here is that the answer may have changed.
abstract class SessionSignal {
  /// Fires whenever the session may have changed, and once on subscription
  /// with whatever the state already is.
  ///
  /// The opening event is the contract that matters: Firebase restores a
  /// persisted session asynchronously, so [hasSession] read at construction
  /// would say "signed out" and flash the Welcome screen at someone who is
  /// signed in. The state machine waits for this stream instead.
  Stream<void> get changes;

  /// Whether a session exists right now.
  bool get hasSession;
}

/// The real signal: Firebase Auth's own session stream, which already emits
/// the current user on subscription.
class FirebaseSessionSignal implements SessionSignal {
  FirebaseSessionSignal({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<void> get changes => _auth.authStateChanges();

  @override
  bool get hasSession => _auth.currentUser != null;
}
