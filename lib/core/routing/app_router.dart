import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otibook/features/auth/screens/auth_gate.dart';
import 'package:otibook/features/auth/screens/create_profile_page.dart';
import 'package:otibook/features/admin/screens/admin_dashboard_page.dart';
import 'package:otibook/features/admin/screens/create_student_page.dart';
import 'package:otibook/features/admin/screens/assign_teacher_page.dart';
import 'package:otibook/features/parent/screens/parent_home_page.dart';
import 'package:otibook/features/teacher/screens/teacher_home_page.dart';
import 'package:otibook/features/teacher/screens/student_detail_page.dart';
import 'package:otibook/features/teacher/screens/add_note_page.dart';
import 'package:otibook/features/auth/screens/role_gate_page.dart';
import 'dart:async';


class AppRouter {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    refreshListenable: GoRouterRefreshStream(_firebaseAuth.authStateChanges()),
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/create_profile',
        builder: (context, state) => const CreateProfilePage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const RoleGatePage(),
      ),
      // Öğretmen Rotaları
      GoRoute(
        path: '/teacher_home',
        builder: (context, state) => const TeacherHomePage(),
        routes: [
           GoRoute(
            path: 'student/:studentId',
            builder: (context, state) {
              final studentId = state.pathParameters['studentId']!;
              return StudentDetailPage(studentId: studentId);
            },
            routes: [
               GoRoute(
                path: 'add_note',
                builder: (context, state) {
                  final studentId = state.pathParameters['studentId']!;
                  return AddNotePage(studentId: studentId);
                },
              ),
            ]
          ),
        ]
      ),
      // Veli Rotaları
      GoRoute(
        path: '/parent_home',
        builder: (context, state) => const ParentHomePage(),
      ),
      // Admin Rotaları
      GoRoute(
        path: '/admin_dashboard',
        builder: (context, state) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'create_student',
            builder: (context, state) => const CreateStudentPage(),
          ),
          // Yeni atama rotası
          GoRoute(
            path: 'assign_teacher',
            builder: (context, state) => const AssignTeacherPage(),
          ),
        ]
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = _firebaseAuth.currentUser != null;
      final bool loggingIn = state.matchedLocation == '/auth';

      if (!loggedIn) {
        return loggingIn ? null : '/auth';
      }

      if (loggingIn) {
        return '/';
      }
      return null;
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
