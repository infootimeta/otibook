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

  String? _selectedStudentId; // Öğrenci seçimini id ile tutuyoruz
  final Map<String, bool> _selectedTeachers = {}; // teacher.uid -> seçili mi?

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final students = await _firestoreService.getStudents();
      final teachers = await _firestoreService.getTeachers();

      // Eğer mevcut seçim yeni listede yoksa sıfırla
      final stillExists = _selectedStudentId != null &&
          students.any((s) => s.id == _selectedStudentId);

      setState(() {
        _students = students;
        _teachers = teachers;
        if (!stillExists) {
          _selectedStudentId = null;
          _selectedTeachers.clear();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  StudentModel? _getStudentById(String? id) {
    if (id == null) return null;
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void _onStudentSelected(String? studentId) {
    setState(() {
      _selectedStudentId = studentId;
      _selectedTeachers.clear();

      final student = _getStudentById(studentId);
      if (student != null) {
        // Mevcut atanmış öğretmenleri işaretle
        for (final teacherRef in student.assignedTeacherRefs) {
          _selectedTeachers[teacherRef.id] = true;
        }
      }
    });
  }

  Future<void> _saveAssignment() async {
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir öğrenci seçin.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<DocumentReference<Map<String, dynamic>>> teacherRefs = [];
      _selectedTeachers.forEach((teacherId, isSelected) {
        if (isSelected) {
          teacherRefs.add(
            FirebaseFirestore.instance
                .collection('users')
                .doc(teacherId),
          );
        }
      });

      await _firestoreService.updateStudent(
        _selectedStudentId!,
        {'assignedTeacherRefs': teacherRefs},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atama başarıyla güncellendi!')),
      );

      // Verileri tazele
      await _loadData();
      _onStudentSelected(null); // Seçimi sıfırla
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStudent = _getStudentById(_selectedStudentId);
    final hasAnySelectedTeacher =
        _selectedTeachers.values.any((v) => v == true);

    return Scaffold(
      appBar: AppBar(title: const Text('Öğretmen - Öğrenci Atama')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_students.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Kayıtlı öğrenci bulunamadı.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    value: _selectedStudentId,
                    hint: const Text('Öğrenci Seçin'),
                    items: _students.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.nameSurname),
                      );
                    }).toList(),
                    onChanged: _onStudentSelected,
                  ),
                  const SizedBox(height: 20),

                  if (currentStudent != null) ...[
                    Text(
                      '${currentStudent.nameSurname} için Öğretmenleri Seçin:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    if (_teachers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text('Kayıtlı öğretmen bulunamadı.'),
                      ),
                    ..._teachers.map((teacher) => CheckboxListTile(
                          title: Text(teacher.nameSurname),
                          value: _selectedTeachers[teacher.uid] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedTeachers[teacher.uid] = value ?? false;
                            });
                          },
                        )),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: (_selectedStudentId == null || !hasAnySelectedTeacher)
                          ? null
                          : _saveAssignment,
                      child: const Text('Atamayı Kaydet'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
