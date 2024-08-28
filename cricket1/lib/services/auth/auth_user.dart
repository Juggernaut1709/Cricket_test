import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;

  AuthUser({required this.isEmailVerified});

  factory AuthUser.fromFirebaseUser(User user) {
    return AuthUser(isEmailVerified: user.emailVerified);
  }
}
