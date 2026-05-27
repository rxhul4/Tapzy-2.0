import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/common/commonBackground.dart';
import 'package:tapzy/core/common/glass_ui.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/utils/appUtils.dart';

class AppNotification {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}

class NotificationListingScreen extends StatefulWidget {
  const NotificationListingScreen({super.key});

  @override
  State<NotificationListingScreen> createState() => _NotificationListingScreenState();
}

class _NotificationListingScreenState extends State<NotificationListingScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await callPostMethod(
        ApiConstants.getNotifications,
        {'mark_as_read': '1'},
      );
      final decoded = json.decode(response);

      if (decoded['isSuccessful'] == true) {
        final List data = decoded['data'] ?? [];
        final now = DateTime.now();
        final List<AppNotification> allNotifs = data.map((e) => AppNotification.fromJson(e)).toList();

        // Background cleanup: Delete notifications older than 7 days on server
        final toDelete = allNotifs.where((n) {
          return now.difference(n.createdAt).inDays >= 7;
        }).toList();

        for (var n in toDelete) {
          _deleteNotification(n.id);
        }

        setState(() {
          // Keep only notifications that are less than 7 days old
          _notifications = allNotifs.where((n) {
            return now.difference(n.createdAt).inDays < 7;
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = decoded['message'] ?? 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      final response = await callPostMethod(
        ApiConstants.deleteNotification,
        {'notification_id': id.toString()},
      );
      final decoded = json.decode(response);
      if (decoded['isSuccessful'] != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(decoded['message'] ?? 'Failed to delete notification'),
              backgroundColor: AppColors.colorError,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting notification'),
            backgroundColor: AppColors.colorError,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackGround(
      body: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
              child: Row(
                children: [
                  GlassUi.backButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Text(
                    'Activity',
                    style: TextStyle(
                      color: AppColors.colorOffWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: StringUtils.fontFamilyHeading,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading 
                ? Center(child: AppUtils.loaderWidget(color: AppColors.colorPurple))
                : _errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        _errorMessage, 
                        style: TextStyle(color: Colors.white.withOpacity(0.5))
                      )
                    )
                  : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
                            const SizedBox(height: 16),
                            Text(
                              "No new notifications",
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchNotifications,
                        color: AppColors.colorPurple,
                        backgroundColor: AppColors.colorCard,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return Dismissible(
                              key: Key(notification.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.colorError.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.colorError.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.delete_sweep_rounded,
                                  color: AppColors.colorError,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (direction) {
                                final deletedId = notification.id;
                                setState(() {
                                  _notifications.removeAt(index);
                                });
                                _deleteNotification(deletedId);
                              },
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context, true);
                                },
                                child: _buildGlassNotificationCard(notification),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildGlassNotificationCard(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  notification.isRead ? Colors.white.withOpacity(0.03) : AppColors.colorPurple.withOpacity(0.1),
                  notification.isRead ? Colors.white.withOpacity(0.01) : AppColors.colorPurple.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: notification.isRead ? Colors.white.withOpacity(0.05) : AppColors.colorPurple.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.colorPurple.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.colorPurple.withOpacity(0.5), width: 1),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_add_alt_1_rounded, color: AppColors.colorPurple, size: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.5,
                          height: 1.4,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
