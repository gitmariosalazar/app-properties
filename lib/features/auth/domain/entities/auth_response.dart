import 'package:equatable/equatable.dart';
import 'package:app_properties/features/auth/domain/entities/user.dart';

class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object> get props => [accessToken, refreshToken, user];
}
