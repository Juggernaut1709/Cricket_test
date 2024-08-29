import 'auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<AuthUser?> signIn(
    String email,
    String password,
  );
  Future<AuthUser?> signUp(
    String email,
    String password,
    String confirmPassword,
  );
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> initialize();
}
