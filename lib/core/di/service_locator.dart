import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final sl = GetIt.instance;

void setupLocator() {
  if (!sl.isRegistered<AuthService>()) {
    sl.registerLazySingleton<AuthService>(() => AuthService());
  }
  if (!sl.isRegistered<FirestoreService>()) {
    sl.registerLazySingleton<FirestoreService>(() => FirestoreService());
  }
}