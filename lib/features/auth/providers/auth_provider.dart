import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otibook/core/services/auth_service.dart';
import 'package:otibook/models/user_model.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _firebaseUser;
  UserModel? _userModel;
  AuthState _authState = AuthState.unknown;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Getter'lar
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _userModel;
  AuthState get authState => _authState;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  String? get userRole => _userModel?.role;

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _firebaseUser = null;
      _userModel = null;
      _authState = AuthState.unauthenticated;
    } else {
      _firebaseUser = user;
      // Firestore'dan kullanıcı profilini çek
      _userModel = await _authService.getUserProfile(user.uid);
      // Eğer profil varsa authenticated, yoksa yeni kullanıcıdır,
      // profil oluşturma ekranına yönlenmesi gerekir.
      // Bu mantık router'da ve AuthGate'te işlenecek.
      _authState =
          _userModel != null
              ? AuthState.authenticated
              : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> refreshUserProfile() async {
    if (_firebaseUser != null) {
      _userModel = await _authService.getUserProfile(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
