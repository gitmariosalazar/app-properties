// lib/features/auth/data/datasources/auth_local_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_properties/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> cacheUser(UserModel user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel> login(String email, String password) async {
    // Mock login logic for demo (in real app, use API)
    if (email == 'root' && password == '12345') {
      final user = UserModel(id: '1', email: email);
      await cacheUser(user);
      return user;
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString('user_id', user.id);
    await sharedPreferences.setString('user_email', user.email);
  }
}
