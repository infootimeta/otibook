import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:otibook/core/services/auth_service.dart';
import 'package:otibook/features/auth/providers/auth_provider.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedRole = 'teacher'; // Varsayılan rol
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = AuthService();
      final user = authService.currentUser;

      if (user != null) {
        try {
          await authService.createUserProfile(
            uid: user.uid,
            email: user.email ?? 'No Email',
            nameSurname: _nameController.text.trim(),
            role: _selectedRole,
          );

          if (!mounted) return;

          await context.read<AuthProvider>().refreshUserProfile();

          if (!mounted) return;
          context.go('/');
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil oluşturulurken bir hata oluştu: $e')),
          );
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı oturumu bulunamadı.')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = const [
      DropdownMenuItem(value: 'teacher', child: Text('Öğretmen')),
      DropdownMenuItem(value: 'parent', child: Text('Veli')),
      DropdownMenuItem(value: 'admin', child: Text('Yönetici')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Oluştur')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hesabınızı Tamamlayın',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lütfen adınızı, soyadınızı ve rolünüzü belirtin.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Adınız ve Soyadınız',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen adınızı ve soyadınızı girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedRole, // <-- düzeltildi
                  decoration: const InputDecoration(
                    labelText: 'Rolünüz',
                    border: OutlineInputBorder(),
                  ),
                  items: roles,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Lütfen bir rol seçin.' : null,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _createProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Profili Kaydet ve Devam Et'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
