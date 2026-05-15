import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/meeting_service.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingService>().initMeetings();
    });
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch meeting link')));
      }
    }
  }

  void _showScheduleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final linkController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Schedule Meeting'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Meeting Title')),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Agenda/Description')),
                  TextField(controller: linkController, decoration: const InputDecoration(labelText: 'Link (Zoom/Meet) or Location')),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(selectedDate == null 
                          ? 'No Date Selected' 
                          : DateFormat('MMM d, yyyy - h:mm a').format(selectedDate!)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month, color: Color(0xFF0D47A1)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (date != null && context.mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                              });
                            }
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                onPressed: () async {
                  if (titleController.text.isNotEmpty && selectedDate != null) {
                    await context.read<MeetingService>().scheduleMeeting(
                      titleController.text, 
                      descController.text, 
                      selectedDate!, 
                      linkController.text
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Schedule'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting Room')),
      body: Consumer<MeetingService>(
        builder: (context, service, child) {
          if (service.isLoading && service.meetings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.meetings.isEmpty) {
            return const Center(child: Text('No upcoming meetings.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: service.meetings.length,
            itemBuilder: (context, index) {
              final meeting = service.meetings[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(meeting.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (meeting.dateScheduled != null) ...[
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(meeting.dateScheduled!),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(meeting.description, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 16),
                      if (meeting.meetingLink != null && meeting.meetingLink!.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                            icon: const Icon(Icons.video_call),
                            label: const Text('Join Meeting'),
                            onPressed: () => _launchURL(meeting.meetingLink!),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: context.watch<MeetingService>().canSchedule
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              onPressed: () => _showScheduleDialog(context),
              child: const Icon(Icons.add_task),
            )
          : null,
    );
  }
}
