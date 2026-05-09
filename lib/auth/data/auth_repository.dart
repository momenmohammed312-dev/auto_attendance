// // lib/auth/data/auth_repository.dart

import 'package:auto_attendace/auth/data/model/login_request.dart';
import 'package:auto_attendace/auth/data/model/user_model.dart';

class AuthRepository {
  Future<UserModel> login(LoginRequest request) async {
    // ========== MOCK LOGIN ==========
    // بيانات وهمية للاختبار
    await Future.delayed(const Duration(seconds: 1)); // محاكاة انتظار

    // قبول أي email/password للاختبار
    return UserModel(
      id: '1',
      name: 'Alex Rivers',
      email: request.email,
      role: request.role,
    );
    // =================================

    /* 
    // الـ API الحقيقي (شغله لما الـ Backend يكون جاهز)
    final response = await _dio.post(
      'http://10.0.2.2:8000/api/login',
      data: request.toJson(),
    );
    ...
    */
  }
}
