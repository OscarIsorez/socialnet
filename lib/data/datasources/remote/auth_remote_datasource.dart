import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);

  Future<UserModel> signUp(String email, String password, String profileName);

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}
