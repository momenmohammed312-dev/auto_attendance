import 'package:auto_attendace/auth/data/model/login_request.dart';
import 'package:auto_attendace/auth/data/model/user_model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio = Dio();
  //TODO My API
  Future<UserModel> login(LoginRequest request) async {
    final response = await _dio.post(
      'http://10.0.2.2:8000/api/login',
      data: request.toJson(),
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> logout() async {
    // TODO: Implement logout
  }
}
