import 'package:flutter/material.dart';
import '../models/notification_service.dart';
import '../models/user_model.dart';

class NotificationScreen extends StatefulWidget {
  final User currentUser;

  const NotificationScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<AppNotification> _notifications;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络延迟
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _notifications = NotificationService.getUserNotifications(widget.currentUser.id);
        _isLoading = false;
      });
    });
  }

  void _markAsRead(AppNotification notification) {
    NotificationService.markAsRead(notification.id);
    _loadNotifications(); // 重新加载通知列表
  }

  void _markAllAsRead() {
    for (var notification in _notifications) {
      if (!notification.isRead) {
        NotificationService.markAsRead(notification.id);
      }
    }
    _loadNotifications(); // 重新加载通知列表
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('所有通知已标记为已读')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('消息通知'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: '全部标记为已读',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            '暂无通知',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '您将在这里看到订单和系统通知',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotificationColor(notification.type),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.content),
                SizedBox(height: 5),
                Text(
                  _formatTime(notification.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            trailing: !notification.isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
            onTap: () {
              if (!notification.isRead) {
                _markAsRead(notification);
              }
              
              // 根据通知类型执行相应操作
              _handleNotificationTap(notification);
            },
          ),
        );
      },
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'system':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping;
      case 'payment':
        return Icons.payment;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // 根据通知类型执行相应操作
    switch (notification.type) {
      case 'order':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('订单通知: ${notification.content}')),
        );
        break;
      case 'payment':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('支付通知: ${notification.content}')),
        );
        break;
      case 'system':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('系统通知: ${notification.content}')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notification.content)),
        );
    }
  }
}