import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MOCK DATA
    final List<Map<String, dynamic>> notifications = [
      {'title': 'Request Completed', 'body': 'Your wedding photos are ready!', 'time': '2h ago', 'read': false},
      {'title': 'New Message', 'body': 'Staff: Can you upload the raw files?', 'time': '5h ago', 'read': true},
      {'title': 'Welcome', 'body': 'Welcome to AI Styler App!', 'time': '1d ago', 'read': true},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: notif['read'] ? Colors.grey[300] : Colors.orange.withOpacity(0.2),
              child: Icon(
                Icons.notifications, 
                color: notif['read'] ? Colors.grey : Colors.orange
              ),
            ),
            title: Text(
              notif['title'], 
              style: TextStyle(fontWeight: notif['read'] ? FontWeight.normal : FontWeight.bold)
            ),
            subtitle: Text(notif['body']),
            trailing: Text(notif['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
            tileColor: notif['read'] ? Colors.transparent : Colors.orange.withOpacity(0.05),
            onTap: () {
              // Handle tap (e.g., mark as read)
            },
          );
        },
      ),
    );
  }
}