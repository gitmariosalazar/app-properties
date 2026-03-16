// lib/features/auth/data/datasources/auth_local_datasource.dart
import 'dart:convert';

import 'package:app_properties/core/error/exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_properties/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
}

const CACHED_AUTH_TOKEN = 'CACHED_AUTH_TOKEN';
const CACHED_USER_DATA = 'CACHED_USER_DATA';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) {
    return sharedPreferences.setString(CACHED_AUTH_TOKEN, token);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(CACHED_AUTH_TOKEN);
  }

  @override
  Future<void> clearToken() {
    return sharedPreferences.remove(CACHED_AUTH_TOKEN);
  }

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString(
      CACHED_USER_DATA,
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final jsonString = sharedPreferences.getString(CACHED_USER_DATA);
    if (jsonString != null) {
      try {
        return UserModel.fromJson(jsonDecode(jsonString));
      } catch (e) {
        throw CacheException('Could not parse cached user data');
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() {
    return sharedPreferences.remove(CACHED_USER_DATA);
  }
}
