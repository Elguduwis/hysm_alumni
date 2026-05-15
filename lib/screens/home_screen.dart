import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import 'directory_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HYSM Alumni Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        children: [
          _buildCard(
            context,
            icon: Icons.person,
            label: 'Bio Data',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DirectoryScreen()),
            ),
          ),
          _buildCard(context, icon: Icons.monetization_on, label: 'Monthly Dues', onTap: () {}),
          _buildCard(context, icon: Icons.announcement, label: 'Announcements', onTap: () {}),
          _buildCard(context, icon: Icons.groups, label: 'Meeting Room', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF0D47A1)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
