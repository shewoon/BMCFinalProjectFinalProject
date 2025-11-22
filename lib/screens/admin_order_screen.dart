import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ UPDATED FUNCTION: now accepts userId and creates notification
  Future<void> _updateOrderStatus(
      String orderId, String newStatus, String userId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ✅ ADD NOTIFICATION DOCUMENT
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Order Status Updated',
        'body': 'Your order ($orderId) has been updated to "$newStatus".',
        'orderId': orderId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to "$newStatus"!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  // ✅ UPDATED: Accepts userId
  void _showStatusDialog(String orderId, String currentStatus, String userId) {
    const statuses = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled'
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return ListTile(
              title: Text(status),
              trailing:
              currentStatus == status ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.of(dialogContext).pop();
                _updateOrderStatus(orderId, status, userId);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No orders found.'));

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              final String orderId = doc.id;
              final String userId = data['userId'] ?? 'Unknown User';
              final double totalPrice = (data['totalPrice'] is num)
                  ? (data['totalPrice'] as num).toDouble()
                  : 0.0;
              final String status = data['status'] ?? 'Pending';
              final Timestamp? timestamp = data['createdAt'];
              final String formattedDate = timestamp != null
                  ? DateFormat('MM/dd/yyyy hh:mm a').format(timestamp.toDate())
                  : 'Unknown date';

              final colorMap = {
                'Pending': Colors.orange,
                'Processing': Colors.blue,
                'Shipped': Colors.deepPurple,
                'Delivered': Colors.green,
                'Cancelled': Colors.red,
              };

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  title: Text(
                    'Order ID: $orderId',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  subtitle: Text(
                    'User: $userId\n'
                        'Total: ₱${totalPrice.toStringAsFixed(2)}\n'
                        'Date: $formattedDate',
                  ),
                  isThreeLine: true,
                  trailing: Chip(
                    label: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: colorMap[status] ?? Colors.grey,
                  ),
                  onTap: () => _showStatusDialog(orderId, status, userId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
