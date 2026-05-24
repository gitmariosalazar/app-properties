import 'package:equatable/equatable.dart';
import 'package:app_properties/features/auth/domain/entities/user.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// No session active — show login screen.
class LoginInitial extends LoginState {}

/// Async operation in progress.
class LoginLoading extends LoginState {}

/// Login / session restore succeeded.
class LoginSuccess extends LoginState {
  final User user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Login / session restore failed with a message.
class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// The cached session belongs to a user who no longer exists or is inactive
/// in the backend. The app must clear the local session and redirect to login.
class LoginUserNotFound extends LoginState {
  final String message;

  const LoginUserNotFound(this.message);

  @override
  List<Object?> get props => [message];
}
