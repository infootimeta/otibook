import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/di/service_locator.dart';

sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthError extends AuthState { final String message; AuthError(this.message); }

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(): super(AuthInitial());
  final _auth = sl<AuthService>();

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(email, password);
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthError(_auth.getAuthErrorMessage(e)));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      await _auth.signUpWithEmailAndPassword(email, password);
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthError(_auth.getAuthErrorMessage(e)));
    }
  }

  Future<void> sendReset(String email) async {
    try { await _auth.sendPasswordResetEmail(email); }
    catch (e) { emit(AuthError(_auth.getAuthErrorMessage(e))); }
  }

  Future<void> logout() async {
    try { await _auth.signOut(); emit(AuthInitial()); }
    catch (_) { emit(AuthError('Çıkış yapılırken bir sorun oluştu.')); }
  }
}