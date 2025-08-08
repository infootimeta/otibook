import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otibook/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı durumunu dinleyen stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // E-posta ve şifre ile kayıt olma
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    }  catch (e) {
      // Hata yönetimi eklenecek
      return null;
    }
  }

  // E-posta ve şifre ile giriş yapma
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // Hata yönetimi eklenecek
      return null;
    }
  }

  // Çıkış yapma
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore'dan kullanıcı profilini getir
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Yeni kullanıcı için Firestore'da profil oluştur
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String nameSurname,
    required String role,
  }) async {
    UserModel newUser = UserModel(
      uid: uid,
      email: email,
      nameSurname: nameSurname,
      role: role,
      createdAt: Timestamp.now(),
    );
    await _firestore.collection('users').doc(uid).set(newUser.toMap());
  }
}
