import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otibook/core/services/firestore_service.dart';
import 'package:otibook/models/student_model.dart';
import 'package:otibook/models/user_model.dart';

class AssignTeacherPage extends StatefulWidget {
  const AssignTeacherPage({super.key});

  @override
  State<AssignTeacherPage> createState() => _AssignTeacherPageState();
}

class _AssignTeacherPageState extends State<AssignTeacherPage> {
  final FirestoreService _firestoreService = FirestoreService();

  List<StudentModel> _students = [];
  List<UserModel> _teachers = [];

  StudentModel? _selectedStudent;
  final Map<String, bool> _selectedTeachers = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _students = await _firestoreService.getStudents();
      _teachers = await _firestoreService.getTeachers();
    } catch (e) {
      // Hata yönetimi
    }
    setState(() => _isLoading = false);
  }

  void _onStudentSelected(StudentModel? student) {
    setState(() {
      _selectedStudent = student;
      _selectedTeachers.clear();
      if (student != null) {
        // Mevcut atanmış öğretmenleri işaretle
        for (var teacherRef in student.assignedTeacherRefs) {
          _selectedTeachers[teacherRef.id] = true;
        }
      }
    });
  }

  Future<void> _saveAssignment() async {
    if (_selectedStudent == null) {
      Builder(builder: (BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir öğrenci seçin.')),
        );
        return const SizedBox.shrink();
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<DocumentReference> teacherRefs = [];
      _selectedTeachers.forEach((teacherId, isSelected) {
        if (isSelected) {
          teacherRefs.add(
            FirebaseFirestore.instance.collection('users').doc(teacherId),
          );
        }
      });

      await _firestoreService.assignTeachersToStudent(
        _selectedStudent!.id,
        teacherRefs,
      );

      Builder(builder: (BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atama başarıyla güncellendi!')),
        );
        return const SizedBox.shrink();
      });

      // Verileri tazelemek için
      _loadData();
      _onStudentSelected(null); // Seçimi sıfırla
    } catch (e) {
      Builder(builder: (BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        return const SizedBox.shrink();
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Öğretmen - Öğrenci Atama')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<StudentModel>(
                      initialValue: _selectedStudent,
                      hint: const Text('Öğrenci Seçin'),
                      items:
                          _students.map((student) {
                            return DropdownMenuItem(
                              value: student,
                              child: Text(student.nameSurname),
                            );
                          }).toList(),
                      onChanged: _onStudentSelected,
                    ),
                    const SizedBox(height: 20),

                    if (_selectedStudent != null) ...[
                      Text(
                        '${_selectedStudent!.nameSurname} için Öğretmenleri Seçin:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(),
                      ..._teachers.map((teacher) {
                        return CheckboxListTile(
                          title: Text(teacher.nameSurname),
                          value: _selectedTeachers[teacher.uid] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedTeachers[teacher.uid] = value!;
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _saveAssignment,
                        child: const Text('Atamayı Kaydet'),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
