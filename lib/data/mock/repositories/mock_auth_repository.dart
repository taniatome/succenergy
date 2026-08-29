import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import '../mock_data.dart';

/// In-memory authentication for the showcase build.
///
/// No credentials are checked: any well-formed input succeeds, because the
/// purpose here is to demonstrate the journey, not to guard anything.
class MockAuthRepository implements AuthRepository {
  User? _user;
  bool _needsOnboarding = false;

  @override
  User? get currentUser => _user;

  @override
  bool get isLoggedIn => _user != null;

  @override
  bool get needsOnboarding => _needsOnboarding;

  @override
  Future<User> logIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    _user = MockData.user;
    _needsOnboarding = false;
    return _user!;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    _user = MockData.user.copyWith(name: name, email: email);
    _needsOnboarding = true;
    return _user!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
  }

  @override
  Future<void> logOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _user = null;
    _needsOnboarding = false;
  }

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    _user = null;
    _needsOnboarding = false;
  }
}
