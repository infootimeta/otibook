import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/view/login_page.dart';
import 'features/students/cubit/students_cubit.dart';
import 'features/students/view/students_page.dart';
import 'features/session_notes/view/new_note_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => StudentsCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (_) => const LoginPage(),
          '/students': (_) => const StudentsPage(),
          '/student/new': (ctx) {
            final arg = ModalRoute.of(ctx)?.settings.arguments as String? ?? '';
            return NewNotePage(studentId: arg);
          },
        },
      ),
    );
  }
}