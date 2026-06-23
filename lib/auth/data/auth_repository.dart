import 'package:auto_attendace/auth/data/model/login_request.dart';
import 'package:auto_attendace/auth/data/model/user_model.dart';

class AuthRepository {
  Future<UserModel> login(LoginRequest request) async {
    // TODO: Replace mock login with real API authentication
    await Future.delayed(const Duration(seconds: 1));

    return UserModel(
      id: request.studentId,
      name: request.name,
      email: '${request.studentId}@university.edu',
      role: request.role,
    );
  }
}
