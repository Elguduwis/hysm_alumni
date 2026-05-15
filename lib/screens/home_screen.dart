
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../services/supabase_service.dart';



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

          _buildCard(Icons.person, 'Bio Data'),

          _buildCard(Icons.monetization_on, 'Monthly Dues'),

          _buildCard(Icons.announcement, 'Announcements'),

          _buildCard(Icons.groups, 'Meeting Room'),

        ],

      ),

    );

  }



  Widget _buildCard(IconData icon, String label) {

    return Card(

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(icon, size: 40, color: const Color(0xFF0D47A1)),

          const SizedBox(height: 8),

          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),

        ],

      ),

    );

  }

}

