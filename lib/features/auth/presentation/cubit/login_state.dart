import 'package:equatable/equatable.dart';
import 'package:app_properties/features/auth/domain/entities/user.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;
  final String token;

  const LoginSuccess(this.user, this.token);

  @override
  List<Object?> get props => [user, token];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when the cached session belongs to a user who no longer exists
/// or is inactive in the backend. The app must clear the local session
/// and redirect to the login screen.
class LoginUserNotFound extends LoginState {
  final String message;

  const LoginUserNotFound(this.message);

  @override
  List<Object?> get props => [message];
}
