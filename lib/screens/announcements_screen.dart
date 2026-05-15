import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/announcement_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementService>().initAnnouncements();
    });
  }

  void _showPostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 16),
            TextField(controller: contentController, maxLines: 4, decoration: const InputDecoration(labelText: 'Message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                await context.read<AnnouncementService>().postAnnouncement(titleController.text, contentController.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Noticeboard')),
      body: Consumer<AnnouncementService>(
        builder: (context, service, child) {
          if (service.isLoading && service.announcements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.announcements.isEmpty) {
            return const Center(child: Text('No announcements yet.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: service.announcements.length,
            itemBuilder: (context, index) {
              final announcement = service.announcements[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(announcement.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          const Icon(Icons.push_pin, color: Color(0xFF0D47A1), size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(announcement.content, style: const TextStyle(fontSize: 15, height: 1.4)),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Posted by: ${announcement.authorName}', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic)),
                          Text(dateFormat.format(announcement.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // SMART UI: Only show the "+" button if the user is an Exco!
      floatingActionButton: context.watch<AnnouncementService>().canPost
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              onPressed: () => _showPostDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
