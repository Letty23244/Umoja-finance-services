import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  // Track read/unread state
  List<Map<String, dynamic>> notifications = [
    {
      'title': 'Deposit Successful',
      'message': 'UGX 500,000 has been added to your savings wallet.',
      'time': '2 hours ago',
      'icon': Icons.arrow_downward_rounded,
      'color': Colors.green,
      'isRead': false,
    },
    {
      'title': 'Auto Savings Deducted',
      'message': 'UGX 50,000 has been automatically saved as per your plan.',
      'time': '5 hours ago',
      'icon': Icons.autorenew,
      'color': Colors.purple,
      'isRead': false,
    },
    {
      'title': 'Savings Goal Reached!',
      'message': 'Congratulations! You have reached your Expand Stock goal.',
      'time': '1 day ago',
      'icon': Icons.flag_rounded,
      'color': Colors.orange,
      'isRead': false,
    },
    {
      'title': 'Withdrawal Processed',
      'message': 'UGX 100,000 has been withdrawn from your wallet.',
      'time': '2 days ago',
      'icon': Icons.arrow_upward_rounded,
      'color': Colors.redAccent,
      'isRead': true,
    },
    {
      'title': 'Locked Savings Matured',
      'message': 'Your House Fund savings have matured. You can now withdraw.',
      'time': '3 days ago',
      'icon': Icons.lock_open_rounded,
      'color': Colors.amber,
      'isRead': true,
    },
    {
      'title': 'New Savings Goal Created',
      'message': 'Your savings goal "Emergency Fund" has been created.',
      'time': '5 days ago',
      'icon': Icons.savings_outlined,
      'color': Colors.blue,
      'isRead': true,
    },
  ];

  int get unreadCount => notifications.where((n) => n['isRead'] == false).length;

  void _markAllRead() {
    setState(() {
      for (var n in notifications) {
        n['isRead'] = true;
      }
    });
  }

  void _markRead(int index) {
    setState(() => notifications[index]['isRead'] = true);
  }

  void _deleteNotification(int index) {
    setState(() => notifications.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: lightGreen, fontSize: 12)),
            ),
        ],
      ),
      body: Column(
        children: [

          // ── Header ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: primaryBrown,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: lightGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unreadCount > 0 ? '$unreadCount Unread Notifications' : 'All caught up!',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${notifications.length} total notifications',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Notifications List ─────────────────────────
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No notifications yet', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text('You\'re all caught up!', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final isRead = n['isRead'] as bool;

                      return Dismissible(
                        key: Key(index.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteNotification(index),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: GestureDetector(
                          onTap: () => _markRead(index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isRead ? Colors.white : lightGreen.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(14),
                              border: isRead ? null : Border.all(color: lightGreen),
                              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (n['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 20),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n['title'],
                                      style: TextStyle(
                                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                        fontSize: 14,
                                        color: primaryBrown,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryBrown,
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    n['message'],
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n['time'],
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}