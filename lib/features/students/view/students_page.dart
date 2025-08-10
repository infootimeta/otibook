import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/students_cubit.dart';
import '../../../models/student_model.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Öğrenciler')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/student/new', arguments: 'studentId_here'),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<StudentsCubit, StudentsState>(
        listener: (context, state) {
          if (state is StudentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentsLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text('Kayıt yok'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final StudentModel s = items[i];
                return ListTile(
                  title: Text(s.nameSurname),
                  subtitle: Text(s.id),
                  onTap: () => Navigator.of(context).pushNamed('/student/${s.id}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete), // Specify parameters to all arguments in declaration. 
                    onPressed: () => context.read<StudentsCubit>().delete(s.id),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: items.length,
            );
          }
          if (state is StudentsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}