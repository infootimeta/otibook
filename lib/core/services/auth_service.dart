import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otibook/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for listening to user status
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Exception: ${e.message}',
          name: 'AuthService', error: e);
      rethrow;
    // ignore: unused_catch_stack
    } catch (e, st) {
      log('An unexpected error occurred during registration: $e',
          name: 'AuthService', error: e);
      return null;
    }
  }

  // Login with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Exception: ${e.message}',
          name: 'AuthService', error: e);
      rethrow;
    } catch (e) {
      log('An unexpected error occurred during login: $e',
          name: 'AuthService', error: e);
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get(); // Use fromDoc for conversion
      if (doc.exists && doc.data() != null) {
        return UserModel.fromDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    } catch (e) {
      log('Error getting user profile: $e', name: 'AuthService', error: e);
      return null;
    }
  }

  // Create a profile for the new user in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String nameSurname,
    required String role,
  }) async {
    UserModel newUser = UserModel(
      uid: uid,
      nameSurname: nameSurname,
      role: role,
    );
    await _firestore.collection('users').doc(uid).set(newUser.toMap());
  }

  // -----------------------------
  // Error message mapping (user-friendly)
  // -----------------------------
  String getAuthErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Geçersiz e-posta adresi.';
        case 'user-disabled':
          return 'Bu hesap devre dışı bırakılmış.';
        case 'user-not-found':
          return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Hatalı şifre.';
        case 'email-already-in-use':
          return 'Bu e-posta adresi zaten kullanımda.';
        case 'weak-password':
          return 'Şifre zayıf. Lütfen daha güçlü bir şifre belirleyin.';
        case 'too-many-requests':
          return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
        case 'network-request-failed':
          return 'Ağ hatası. İnternet bağlantınızı kontrol edin.';
        case 'requires-recent-login':
          return 'Bu işlem için yakın zamanda tekrar giriş yapmanız gerekiyor.';
        default:
          return error.message ?? 'Bilinmeyen bir hata oluştu.';
      }
    }
    return 'Beklenmeyen bir hata oluştu.';
  }

  // -----------------------------
  // Password reset
  // -----------------------------
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      log('Password reset error: \'${e.code}\' - ${e.message}', name: 'AuthService', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during password reset: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  // -----------------------------
  // Email verification
  // -----------------------------
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      log('Email verification error: \'${e.code}\' - ${e.message}', name: 'AuthService', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during email verification: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<bool> isEmailVerified({bool reload = false}) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    if (reload) {
      await user.reload();
    }
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  // -----------------------------
  // Re-auth helper for sensitive ops
  // -----------------------------
  Future<void> _reauthenticate(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'Kullanıcı oturumu yok.');
    }
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  // -----------------------------
  // Profile updates
  // -----------------------------
  Future<void> updateDisplayName(String nameSurname) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'Oturum açmış kullanıcı yok.');
      }
      await user.updateDisplayName(nameSurname);
      await user.reload();

      // Firestore profilini de güncelle
      await _firestore.collection('users').doc(user.uid).update({'nameSurname': nameSurname});
    } on FirebaseAuthException catch (e) {
      log('Update display name error: \'${e.code}\' - ${e.message}', name: 'AuthService', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during display name update: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<void> updateProfile({String? nameSurname, String? role}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'Oturum açmış kullanıcı yok.');
      }
      final Map<String, dynamic> data = {};
      if (nameSurname != null) data['nameSurname'] = nameSurname;
      if (role != null) data['role'] = role;
      if (data.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(data);
      }
    } on FirebaseAuthException catch (e) {
      log('Update profile error: \'${e.code}\' - ${e.message}', name: 'AuthService', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during profile update: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  // -----------------------------
  // Email & password changes (with reauth)
  // -----------------------------
  Future<void> updateEmailSecure({required String currentPassword, required String newEmail}) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'Oturum açmış kullanıcı yok.');
      }
      await _reauthenticate(user.email!, currentPassword);
      await user.verifyBeforeUpdateEmail(newEmail);
      await _firestore.collection('users').doc(user.uid).update({'email': newEmail});
    } on FirebaseAuthException catch (e) {
      log('Update email error: \'${e.code}\' - ${e.message}', name: 'AuthService', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during email update: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<void> updatePasswordSecure({required String currentPassword, required String newPassword}) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'Oturum açmış kullanıcı yok.');
      }
      await _reauthenticate(user.email!, currentPassword);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      log('Update password error: \'${e.code}\' - ${e.message}', name: 'AuthService', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during password update: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }
}
