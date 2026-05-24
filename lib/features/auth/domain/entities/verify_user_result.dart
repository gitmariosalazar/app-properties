import 'package:equatable/equatable.dart';

/// Result returned after verifying a user's existence in the remote system.
/// Only contains safe, non-sensitive fields — no passwords, no tokens.
class VerifyUserResult extends Equatable {
  final bool exists;
  final String? userId;
  final String? username;
  final String? email;
  final bool? isActive;

  const VerifyUserResult({
    required this.exists,
    this.userId,
    this.username,
    this.email,
    this.isActive,
  });

  factory VerifyUserResult.fromJson(Map<String, dynamic> json) {
    return VerifyUserResult(
      exists: json['exists'] as bool,
      userId: json['userId'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  @override
  List<Object?> get props => [exists, userId, username, email, isActive];
}
