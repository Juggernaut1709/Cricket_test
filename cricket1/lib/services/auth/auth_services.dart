import 'auth_provider.dart';
import 'firebase_auth_provider.dart';
import 'auth_user.dart';

class AuthServices implements AuthProvider {
  final AuthProvider _authProvider;

  AuthServices(this._authProvider);

  factory AuthServices.firebase() => AuthServices(FirebaseAuthProvider());

  AuthUser? get currentUser => _authProvider.currentUser;

  Future<AuthUser?> signIn(String email, String password) async {
    return _authProvider.signIn(
      email,
      password,
    );
  }

  Future<AuthUser?> signUp(
    String email,
    String password,
    String confirmPassword,
  ) async {
    return _authProvider.signUp(
      email,
      password,
      confirmPassword,
    );
  }

  Future<void> signOut() async {
    return _authProvider.signOut();
  }

  Future<void> sendEmailVerification() async {
    return _authProvider.sendEmailVerification();
  }

  @override
  Future<void> initialize() => _authProvider.initialize();
}
