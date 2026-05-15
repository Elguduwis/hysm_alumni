import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/directory_service.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DirectoryService>().fetchAlumni();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Directory'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or grad year...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: Consumer<DirectoryService>(
              builder: (context, directory, child) {
                if (directory.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (directory.alumni.isEmpty) {
                  return const Center(child: Text('No alumni found yet.'));
                }

                // Filtering logic
                final filteredList = directory.alumni.where((a) {
                  final nameMatch = a.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
                  final yearMatch = a.graduationYear.toString().contains(_searchQuery);
                  return nameMatch || yearMatch;
                }).toList();

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final alumni = filteredList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0D47A1),
                          child: Text(
                            alumni.fullName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(alumni.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Class of ${alumni.graduationYear} ${alumni.profession != null ? '• ${alumni.profession}' : ''}'),
                        trailing: (alumni.roleName != 'Member' && alumni.roleName != null)
                            ? Chip(
                                label: Text(alumni.roleName!, style: const TextStyle(fontSize: 10, color: Colors.white)),
                                backgroundColor: const Color(0xFF0D47A1),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
