import 'user.dart';

/// Simple immutable auth state holder used by AuthProvider.
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;

  const AuthState({this.user, this.token, this.isLoading = false});

  AuthState copyWith({User? user, String? token, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'token': token,
        'isLoading': isLoading,
      };

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      user: json['user'] != null ? User.fromJson(Map<String, dynamic>.from(json['user'])) : null,
      token: json['token'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'AuthState(user: $user, token: ${token != null ? '***' : null}, isLoading: $isLoading)';
}
