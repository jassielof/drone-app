import '../services/auth_service.dart';

class RegisterViewModel {
  final _authService = AuthService();

  Future<bool> register(String email, String password, String name) async {
    return await _authService.register(email, password, name);
  }

  Future<bool> login(String email, String password) async {
    return await _authService.signIn(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
