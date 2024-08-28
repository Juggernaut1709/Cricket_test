//login exceptions

class InvalidCredentialsException implements Exception {
  final String message = 'Invalid Credentials';
}

class ChannelErrorException implements Exception {
  final String message = 'Channel Error';
}

class EmailNotVerifiedException implements Exception {
  final String message = 'Email Not Verified';
}

//register exceptions
class EmailAlreadyInUseException implements Exception {
  final String message = 'Email Already In Use';
}

class WeakPasswordException implements Exception {
  final String message = 'Weak Password';
}

class InvalidEmailException implements Exception {
  final String message = 'Invalid Email';
}

class PasswordsDoNotMatchException implements Exception {
  final String message = 'Passwords Do Not Match';
}

class UserNotCreatedException implements Exception {
  final String message = 'User Not Created';
}

//general exceptions

class GeneralException implements Exception {
  final String message = 'General Exception';
}
