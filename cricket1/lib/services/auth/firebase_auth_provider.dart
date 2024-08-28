import 'package:firebase_core/firebase_core.dart';
import 'auth_provider.dart';
import 'auth_user.dart';
import 'auth_exp.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser?> signUp(
    String email,
    String password,
    String confirmPassword,
  ) async {
    // TODO: implement createUserWithEmailAndPassword
    try {
      if (password != confirmPassword) {
        throw PasswordsDoNotMatchException();
      } else {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final user = currentUser;
        if (user != null) {
          return user;
        } else {
          throw UserNotCreatedException();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else {
        throw GeneralException();
      }
    } catch (e) {
      throw GeneralException();
    }
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.sendEmailVerification();
    } else {
      throw GeneralException();
    }
  }

  @override
  Future<AuthUser?> signIn(
    String email,
    String password,
  ) async {
    // TODO: implement signInWithEmailAndPassword
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw GeneralException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credentials') {
        throw InvalidCredentialsException();
      } else if (e.code == 'channel-error') {
        throw ChannelErrorException();
      } else if (e.code == 'email-not-verified') {
        throw EmailNotVerifiedException();
      } else {
        throw GeneralException();
      }
    } catch (e) {
      throw GeneralException();
    }
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseAuth.instance.signOut();
    } else {
      throw GeneralException();
    }
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebaseUser(user);
    } else {
      return null;
    }
  }
}
