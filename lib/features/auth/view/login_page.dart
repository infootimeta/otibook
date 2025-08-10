import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/students');
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: emailC, decoration: const InputDecoration(labelText: 'E-posta')),
                TextField(controller: passC, obscureText: true, decoration: const InputDecoration(labelText: 'Şifre')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading ? null : () => context.read<AuthCubit>().signIn(emailC.text.trim(), passC.text),
                        child: Text(loading ? '...' : 'Giriş'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: loading ? null : () => context.read<AuthCubit>().signUp(emailC.text.trim(), passC.text),
                        child: const Text('Kayıt Ol'),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.read<AuthCubit>().sendReset(emailC.text.trim()),
                  child: const Text('Şifremi unuttum'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}