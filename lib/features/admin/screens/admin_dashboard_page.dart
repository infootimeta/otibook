import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:otibook/features/auth/providers/auth_provider.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetici Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
              context.go('/auth');
            },
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.person_add_alt_1,
            title: 'Yeni Kullanıcı Ekle',
            onTap: () {
              // TODO: Yeni kullanıcı ekleme sayfasına yönlendir
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bu özellik yakında eklenecek.')),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.person_add,
            title: 'Yeni Öğrenci Ekle',
            onTap: () {
              context.go('/admin_dashboard/create_student');
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.assignment_ind,
            title: 'Öğretmen-Öğrenci Ata',
            onTap: () {
              context.go('/admin_dashboard/assign_teacher');
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.list_alt,
            title: 'Tüm Kullanıcılar',
            onTap: () {
              // TODO: Kullanıcı listesi sayfasına yönlendir
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bu özellik yakında eklenecek.')),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.list,
            title: 'Tüm Öğrenciler',
            onTap: () {
              // TODO: Öğrenci listesi sayfasına yönlendir
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bu özellik yakında eklenecek.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
