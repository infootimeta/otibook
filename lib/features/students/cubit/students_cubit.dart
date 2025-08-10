import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/student_model.dart';

sealed class StudentsState {}
class StudentsLoading extends StudentsState {}
class StudentsLoaded extends StudentsState { final List<StudentModel> items; StudentsLoaded(this.items); }
class StudentsError extends StudentsState { final String message; StudentsError(this.message); }

class StudentsCubit extends Cubit<StudentsState> {
  StudentsCubit(): super(StudentsLoading()) { _subscribe(); }

  final _fs = sl<FirestoreService>();
  Stream<List<StudentModel>>? _sub;

  void _subscribe() {
    emit(StudentsLoading());
    _sub = _fs.streamStudents();
    _sub!.listen(
      (items) => emit(StudentsLoaded(items)),
      onError: (e) => emit(StudentsError(_fs.getFirestoreErrorMessage(e))),
      cancelOnError: false,
    );
  }

  Future<void> delete(String id) async {
    try { await _fs.deleteStudent(id); }
    catch (e) { emit(StudentsError(_fs.getFirestoreErrorMessage(e))); }
  }
}