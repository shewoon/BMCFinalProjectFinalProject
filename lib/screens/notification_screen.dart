import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _markAllAsRead();
  }

  Future<void> _markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to view notifications.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no notifications.'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final String title = data['title'] ?? 'No Title';
              final String body = data['body'] ?? '';
              final Timestamp? createdAt = data['createdAt'];
              final bool isRead = data['isRead'] ?? false;

              final String formattedDate = createdAt != null
                  ? DateFormat('MM/dd/yyyy hh:mm a').format(createdAt.toDate())
                  : 'Unknown Date';

              return ListTile(
                leading: Icon(
                  isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: isRead ? Colors.grey : Colors.red,
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text('$body\n$formattedDate'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
