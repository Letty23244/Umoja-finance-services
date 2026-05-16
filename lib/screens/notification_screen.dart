import 'package:flutter/material.dart';
import '../authScreens/auth_services_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  // ── Colors ─────────────────────────────
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen   = Color(0xFFD7E8BA);
  static const Color bgColor      = Color(0xFFF5F5F0);

  List notifications = [];
  bool isLoading = true;
  int unreadCount = 0;

  final AuthService authService = AuthService();

  // ───────────────────────────────────────
  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  // ── Fetch Notifications ────────────────
  Future<void> loadNotifications() async {
    try {
      final data  = await authService.getNotifications();
      final count = await authService.getUnreadCount();

      setState(() {
        notifications = data;
        unreadCount = count;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ── Mark One Read ──────────────────────
  Future<void> markRead(int id) async {
    await authService.markNotificationRead(id);
    loadNotifications();
  }

  // ── Mark All Read ──────────────────────
  Future<void> markAllRead() async {
    await authService.markAllNotificationsRead();
    loadNotifications();
  }

  // ── Delete Notification ────────────────
  Future<void> deleteNotification(int id) async {
    await authService.deleteNotification(id);
    loadNotifications();
  }

  // ───────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // ── APP BAR ─────────────────────────
      appBar: AppBar(
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllRead,
              child: const Text(
                "Mark all read",
                style: TextStyle(color: lightGreen, fontSize: 12),
              ),
            ),
        ],
      ),

      // ── BODY ────────────────────────────
      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          // ── Empty State ─────────────────
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        "No notifications yet",
                        style:
                            TextStyle(fontSize: 18, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )

              // ── Notification List ─────────
              : Column(
                  children: [

                    // HEADER
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
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: lightGreen,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unreadCount > 0
                                    ? "$unreadCount Unread Notifications"
                                    : "All caught up!",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${notifications.length} total notifications",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // LIST
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {

                          final n = notifications[index];
                          final bool isRead = n['is_read'] ?? false;

                          return Dismissible(
                            key: Key(n['id'].toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) =>
                                deleteNotification(n['id']),

                            background: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),

                            child: GestureDetector(
                              onTap: () => markRead(n['id']),
                              child: Container(
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isRead
                                      ? Colors.white
                                      : lightGreen.withOpacity(0.4),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: isRead
                                      ? null
                                      : Border.all(color: lightGreen),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 6)
                                  ],
                                ),

                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8),

                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: primaryBrown
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.notifications,
                                      color: primaryBrown,
                                    ),
                                  ),

                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n['title'] ?? '',
                                          style: TextStyle(
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                            fontSize: 14,
                                            color: primaryBrown,
                                          ),
                                        ),
                                      ),

                                      if (!isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration:
                                              const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: primaryBrown,
                                          ),
                                        ),
                                    ],
                                  ),

                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        n['message'] ?? '',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n['created_at'] ?? '',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                Colors.grey.shade400),
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