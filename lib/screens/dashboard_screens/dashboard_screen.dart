import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tapzy/core/common/commonDialog.dart';
import 'package:tapzy/core/common/custom_upgrader_message.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/common/commonBackground.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tapzy/core/services/push_notification_service.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/screens/dashboard_screens/my_card_screen.dart';
import 'package:tapzy/screens/dashboard_screens/notification_screen.dart';
import 'package:tapzy/screens/dashboard_screens/profiles_screen.dart' hide Icon;
import 'package:tapzy/screens/dashboard_screens/scan_connect_screen.dart';
import 'package:tapzy/screens/dashboard_screens/user_profile_screen.dart';
import 'package:tapzy/screens/dashboard_screens/analytics_screen.dart';
import 'package:tapzy/core/utils/confirmation_dialog.dart';
import 'package:tapzy/screens/login_screen/login_screen.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  final int? selectedIndex;
  const DashboardScreen({Key? key, this.selectedIndex}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MyCardsScreen(),
    ProfilesScreen(),
    AnalyticsScreen(),
    ScanConnectScreen(),
    UserProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.credit_card_rounded, Icons.credit_card_outlined, 'Cards'),
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Profiles'),
    _NavItem(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Analytics'),
    _NavItem(Icons.people_rounded, Icons.people_outline_rounded, 'Contacts'),
    _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Me'),
  ];

  bool _hasUnreadNotifications = false;
  OverlayEntry? _currentBannerEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PushNotificationService.onForegroundMessage = _handleForegroundMessage;
    _selectedIndex = widget.selectedIndex ?? 0;
    _checkUnreadNotifications();
    PushNotificationService.registerDeviceToken();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (PushNotificationService.onForegroundMessage == _handleForegroundMessage) {
      PushNotificationService.onForegroundMessage = null;
    }
    _currentBannerEntry?.remove();
    _currentBannerEntry = null;
    super.dispose();
  }

  void _handleForegroundMessage(RemoteMessage message, bool isForeground) {
    _checkUnreadNotifications();
    if (isForeground) {
      final title = message.notification?.title ?? 'Notification Received';
      final body = message.notification?.body ?? 'You have a new notification';
      _showInAppNotificationBanner(title, body);
    }
  }

  void _showInAppNotificationBanner(String title, String body) {
    if (!mounted) return;

    // Dismiss the previous banner if active
    _currentBannerEntry?.remove();
    _currentBannerEntry = null;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => _TopNotificationBannerWidget(
        title: title,
        body: body,
        onDismissed: () {
          if (entry != null && entry.mounted) {
            entry.remove();
            if (_currentBannerEntry == entry) {
              _currentBannerEntry = null;
            }
          }
        },
      ),
    );

    _currentBannerEntry = entry;
    Overlay.of(context).insert(entry);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkUnreadNotifications();
    }
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      final response = await callPostMethod(
        ApiConstants.getNotifications,
        {'mark_as_read': '0'},
      );
      final decoded = json.decode(response);
      if (decoded['isSuccessful'] == true && mounted) {
        final List data = decoded['data'] ?? [];
        final now = DateTime.now();
        
        // Background cleanup: Delete notifications older than 7 days
        for (var n in data) {
          try {
            final createdAtStr = n['created_at'];
            if (createdAtStr != null) {
              final createdAt = DateTime.parse(createdAtStr).toLocal();
              if (now.difference(createdAt).inDays >= 7) {
                final id = n['id'];
                if (id != null) {
                  callPostMethod(
                    ApiConstants.deleteNotification,
                    {'notification_id': id.toString()},
                  ).catchError((_) {});
                }
              }
            }
          } catch (_) {}
        }

        final unreadCount = decoded['unread_count'];
        bool hasUnread;
        if (unreadCount is int) {
          hasUnread = unreadCount > 0;
        } else if (unreadCount is String) {
          hasUnread = int.tryParse(unreadCount) != null &&
              int.parse(unreadCount) > 0;
        } else {
          hasUnread = data.any(
            (n) => n['is_read'] == 0 || n['is_read'] == false,
          );
        }
        setState(() => _hasUnreadNotifications = hasUnread);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackGround(
      body: Stack(
        children: [
          const GlassAmbientOrb(
            size: 280,
            alignment: Alignment(-0.9, -0.85),
            opacity: 0.18,
          ),
          const GlassAmbientOrb(
            size: 220,
            alignment: Alignment(1.1, 0.15),
            opacity: 0.14,
          ),
          const GlassAmbientOrb(
            size: 160,
            alignment: Alignment(0.2, 1.0),
            opacity: 0.1,
          ),
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              drawer: _buildDrawer(),
              extendBody: true,
              appBar: _buildAppBar(),
              body: kDebugMode
                  ? _screens[_selectedIndex]
                  : UpgradeAlert(
                      upgrader: Upgrader(messages: CustomUpgraderMessage()),
                      child: _screens[_selectedIndex],
                    ),
              bottomNavigationBar: _buildBottomNav(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leadingWidth: 68,
      leading: Builder(
        builder: (ctx) => Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: _GlassIconButton(
            icon: Icons.menu_rounded,
            onTap: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      title: Image.asset(
        'assets/images/ic_tran_main_white.png',
        height: 52,
      ),
      actions: [
        if (_selectedIndex == 1)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: _GlassCreateButton(
              onTap: () => showDialog(
                context: context,
                builder: (_) => CommonDialog(selectedIndex: 1),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 8, top: 8, bottom: 8),
          child: _GlassIconButton(
            icon: Icons.notifications_outlined,
            showBadge: _hasUnreadNotifications,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationListingScreen(),
                ),
              );
              _checkUnreadNotifications();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GlassContainer(
        borderRadius: 24,
        blur: 28,
        opacity: 0.06,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorPurple.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final selected = _selectedIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = i);
                  _checkUnreadNotifications();
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: selected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.colorPurple.withOpacity(0.35),
                              AppColors.colorPurpleLight.withOpacity(0.2),
                            ],
                          )
                        : null,
                    border: selected
                        ? Border.all(
                            color: AppColors.colorPurple.withOpacity(0.45),
                            width: 0.8,
                          )
                        : null,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.colorPurple.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.activeIcon : item.icon,
                        color: selected
                            ? AppColors.colorPurple
                            : AppColors.colorTextMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: selected
                              ? AppColors.colorOffWhite
                              : AppColors.colorTextMuted,
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          fontFamily: StringUtils.fontFamilyHeading,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    const exploreItems = [
      _DrawerLink(Icons.play_circle_outline_rounded, 'How to use',
          'https://tapzy.in/how-to-use'),
      _DrawerLink(Icons.language_rounded, 'Visit our site', 'https://tapzy.in'),
      _DrawerLink(
          Icons.info_outline_rounded, 'About us', 'https://tapzy.in/about-us'),
      _DrawerLink(Icons.headset_mic_outlined, 'Contact us',
          'https://tapzy.in/contact-us'),
      _DrawerLink(
          Icons.support_agent_rounded, 'Support', 'https://tapzy.in/support'),
      _DrawerLink(
          Icons.star_outline_rounded, 'Rate us', 'https://tapzy.in/rate-us'),
      _DrawerLink(Icons.help_outline_rounded, 'FAQs', 'https://tapzy.in/faqs'),
    ];

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.colorSurface.withOpacity(0.88),
                  AppColors.colorMainBlack.withOpacity(0.94),
                  AppColors.colorCardDark.withOpacity(0.96),
                ],
              ),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: -40,
                  left: -60,
                  child: GlassAmbientOrb(
                    size: 200,
                    alignment: Alignment.center,
                    opacity: 0.2,
                  ),
                ),
                const Positioned(
                  bottom: 80,
                  right: -50,
                  child: GlassAmbientOrb(
                    size: 160,
                    alignment: Alignment.center,
                    opacity: 0.12,
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDrawerHeader(),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          children: [
                            _drawerSectionLabel('EXPLORE'),
                            const SizedBox(height: 8),
                            GlassContainer(
                              borderRadius: 20,
                              blur: 20,
                              opacity: 0.06,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 6),
                              child: Column(
                                children: [
                                  for (var i = 0;
                                      i < exploreItems.length;
                                      i++) ...[
                                    _drawerMenuTile(
                                      icon: exploreItems[i].icon,
                                      label: exploreItems[i].label,
                                      onTap: () {
                                        Navigator.pop(context);
                                        _launch(exploreItems[i].url);
                                      },
                                    ),
                                    if (i < exploreItems.length - 1)
                                      Divider(
                                        height: 1,
                                        indent: 52,
                                        endIndent: 12,
                                        color: Colors.white
                                            .withOpacity(0.06),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _drawerSectionLabel('ACCOUNT'),
                            const SizedBox(height: 8),
                            GlassContainer(
                              borderRadius: 20,
                              blur: 20,
                              opacity: 0.05,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 6),
                              tintColor: AppColors.colorError,
                              child: Column(
                                children: [
                                  _drawerMenuTile(
                                    icon: Icons.delete_outline_rounded,
                                    label: 'Request Account Deletion',
                                    accentColor: AppColors.colorError,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _launch(
                                          'https://tapzy.in/request-for-account-deletion');
                                    },
                                  ),
                                  Divider(
                                    height: 1,
                                    indent: 52,
                                    endIndent: 12,
                                    color:
                                        Colors.white.withOpacity(0.06),
                                  ),
                                  _drawerMenuTile(
                                    icon: Icons.logout_rounded,
                                    label: 'Log out',
                                    accentColor: AppColors.colorError,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _confirmLogout();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Text(
                          'Powered by NFC Technology',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.colorTextSubtle,
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontFamily: StringUtils.fontFamilyPara,
                          ),
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

  Widget _buildDrawerHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GlassContainer(
        borderRadius: 22,
        blur: 24,
        opacity: 0.08,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.colorPurpleLight.withOpacity(0.45),
            AppColors.colorPurple.withOpacity(0.35),
            Colors.white.withOpacity(0.04),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/ic_tran_main_white.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'DIGITAL BUSINESS CARDS',
                    style: TextStyle(
                      color: AppColors.colorOffWhite.withOpacity(0.85),
                      fontSize: 9.5,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w600,
                      fontFamily: StringUtils.fontFamilyHeading,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap. Share. Connect.',
                    style: TextStyle(
                      color: AppColors.colorTextMuted,
                      fontSize: 11,
                      fontFamily: StringUtils.fontFamilyPara,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.colorOffWhite.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: AppColors.gradientPurple,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.colorTextMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontFamily: StringUtils.fontFamilyHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final accent = accentColor ?? AppColors.colorPurple;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: accent.withOpacity(0.12),
        highlightColor: accent.withOpacity(0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withOpacity(0.22),
                      accent.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: accent.withOpacity(0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: accentColor != null
                        ? accent
                        : AppColors.colorOffWhite.withOpacity(0.92),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: StringUtils.fontFamilyHeading,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.colorTextMuted.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    ConfirmationDialog.show(
      context: context,
      title: 'Log out?',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log out',
      isDestructive: true,
      icon: Icons.logout_rounded,
      onConfirm: () async {
        await PreferenceHelper.clear();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        );
      },
    );
  }

  Future<void> _launch(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}

class _DrawerLink {
  final IconData icon;
  final String label;
  final String url;
  const _DrawerLink(this.icon, this.label, this.url);
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 12,
        blur: 16,
        opacity: 0.05,
        padding: EdgeInsets.zero,
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: AppColors.colorOffWhite, size: 20),
            if (showBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.colorPurple,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.colorMainBlack,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorPurple.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassCreateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GlassCreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppColors.gradientPurple,
          border: Border.all(color: Colors.white.withOpacity(0.22)),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorPurple.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: AppColors.colorWhite, size: 16),
            const SizedBox(width: 4),
            Text(
              'Create',
              style: TextStyle(
                color: AppColors.colorWhite,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: StringUtils.fontFamilyHeading,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNotificationBannerWidget extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismissed;

  const _TopNotificationBannerWidget({
    Key? key,
    required this.title,
    required this.body,
    required this.onDismissed,
  }) : super(key: key);

  @override
  State<_TopNotificationBannerWidget> createState() =>
      __TopNotificationBannerWidgetState();
}

class __TopNotificationBannerWidgetState extends State<_TopNotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismissed();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 12;
    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: GlassContainer(
                borderRadius: 16,
                blur: 16,
                opacity: 0.08,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: Border.all(
                  color: AppColors.colorPurple.withOpacity(0.35),
                  width: 1.2,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.colorPurple.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.colorPurple.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.colorPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: StringUtils.fontFamilyHeading,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: AppColors.colorOffWhite,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: StringUtils.fontFamilyPara,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.5,
                              color: AppColors.colorTextMuted,
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
        ),
      ),
    );
  }
}
