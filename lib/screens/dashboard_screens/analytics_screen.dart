import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/common/glass_ui.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/core/utils/confirmation_dialog.dart';
import 'package:tapzy/models/analytics_model.dart';
import 'package:tapzy/providers/analytics_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
    });
  }

  Future<void> _refresh(AnalyticsProvider provider) async {
    final selected = provider.selectedProfile;
    await provider.fetchAnalytics(
      profileId: selected?.id,
      profileType: selected?.type,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(child: CustomPaint(painter: _OrbPainter())),
          Consumer<AnalyticsProvider>(
            builder: (context, provider, _) {
              if (provider.isFetching && provider.analyticsModel?.data == null) {
                return AppUtils.loaderWidget();
              }

              final data = provider.analyticsModel?.data;
              if (data == null) {
                return RefreshIndicator(
                  onRefresh: () => _refresh(provider),
                  color: AppColors.colorPurple,
                  backgroundColor: AppColors.colorSurface,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                      GlassUi.noData(
                        title: provider.analyticsModel?.message ??
                            'No analytics data available',
                        subtitle: 'Pull down to refresh',
                        icon: Icons.bar_chart_rounded,
                      ),
                    ],
                  ),
                );
              }

              final profiles = data.profiles ?? [];
              final chartData = data.chartData ?? [];
              final breakdown = data.clicksBreakdown ?? [];

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => _refresh(provider),
                    color: AppColors.colorPurple,
                    backgroundColor: AppColors.colorSurface,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: [
                        _buildPageHeader(provider),
                        const SizedBox(height: 16),
                        _buildProfileSelector(provider, profiles),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Overview'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                label: 'Views',
                                value: '${data.totalViews ?? 0}',
                                icon: Icons.remove_red_eye_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                label: 'Clicks',
                                value: '${data.totalClicks ?? 0}',
                                icon: Icons.ads_click_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildMetricCard(
                          label: 'Contacts Exchanged',
                          value: '${data.totalContacts ?? 0}',
                          icon: Icons.contact_mail_outlined,
                          isWide: true,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Activity'),
                        const SizedBox(height: 12),
                        _buildChartCard(chartData),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Top Channels'),
                        const SizedBox(height: 12),
                        _buildBreakdownCard(breakdown),
                      ],
                    ),
                  ),
                  if (provider.isFetching)
                    Positioned.fill(
                      child: Container(
                        color: AppColors.colorMainBlack.withOpacity(0.35),
                        child: AppUtils.loaderWidget(),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(AnalyticsProvider provider) {
    return GlassContainer(
      borderRadius: 24,
      blur: 24,
      opacity: 0.07,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights',
                  style: TextStyle(
                    fontFamily: StringUtils.fontFamilyHeading,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.colorTextMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analytics',
                  style: TextStyle(
                    fontFamily: StringUtils.fontFamilyHeading,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.colorOffWhite,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track views, clicks & contacts',
                  style: TextStyle(
                    fontFamily: StringUtils.fontFamilyPara,
                    fontSize: 11,
                    color: AppColors.colorTextMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Date Range Picker button
          GestureDetector(
            onTap: () => _showDateRangeSelectionSheet(context, provider),
            child: GlassContainer(
              borderRadius: 12,
              blur: 16,
              opacity: 0.05,
              padding: EdgeInsets.zero,
              width: 40,
              height: 40,
              child: Icon(
                provider.selectedDateRange != null
                    ? Icons.date_range_rounded
                    : Icons.calendar_today_rounded,
                color: provider.selectedDateRange != null
                    ? AppColors.colorPurple
                    : AppColors.colorOffWhite,
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Clear Date Filter (only when active)
          if (provider.selectedDateRange != null)
            GestureDetector(
              onTap: () {
                provider.setDateRange(null);
                final selected = provider.selectedProfile;
                provider.fetchAnalytics(
                  profileId: selected?.id,
                  profileType: selected?.type,
                );
              },
              child: GlassContainer(
                borderRadius: 12,
                blur: 16,
                opacity: 0.05,
                padding: EdgeInsets.zero,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.colorTextMuted,
                  size: 18,
                ),
              ),
            ),
          if (provider.selectedDateRange != null) const SizedBox(width: 8),
          // Refresh
          GestureDetector(
            onTap: () => _refresh(provider),
            child: GlassContainer(
              borderRadius: 12,
              blur: 16,
              opacity: 0.05,
              padding: EdgeInsets.zero,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.colorOffWhite,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Clear Analytics (trash)
          GestureDetector(
            onTap: () => _confirmClearAnalytics(provider),
            child: GlassContainer(
              borderRadius: 12,
              blur: 16,
              opacity: 0.05,
              padding: EdgeInsets.zero,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAnalytics(AnalyticsProvider provider) {
    final selected = provider.selectedProfile;
    ConfirmationDialog.show(
      context: context,
      title: 'Clear Analytics?',
      message: selected != null
          ? 'This will permanently delete all interaction data for the selected profile. This cannot be undone.'
          : 'This will permanently delete ALL analytics data for all your profiles. This cannot be undone.',
      confirmText: 'Clear All',
      isDestructive: true,
      icon: Icons.delete_sweep_outlined,
      onConfirm: () async {
        final success = await provider.clearAnalytics(
          profileId: selected?.id,
          profileType: selected?.type,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? 'Analytics cleared successfully.' : 'Failed to clear analytics.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: success ? AppColors.colorPurple : Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: AppColors.gradientPurple,
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPurple.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            letterSpacing: 1.0,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.colorOffWhite,
            fontFamily: StringUtils.fontFamilyHeading,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSelector(
    AnalyticsProvider provider,
    List<AnalyticsProfile> profiles,
  ) {
    final selected = provider.profileMatchingSelection(profiles);

    return GestureDetector(
      onTap: () => _showProfileSelectionSheet(context, provider, profiles),
      child: GlassContainer(
        borderRadius: 16,
        blur: 16,
        opacity: 0.05,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 20,
              color: AppColors.colorPurple.withOpacity(0.9),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected?.label ?? selected?.type ?? 'All Profiles',
                style: TextStyle(
                  color: AppColors.colorOffWhite,
                  fontWeight: FontWeight.w600,
                  fontFamily: StringUtils.fontFamilyHeading,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.colorTextMuted.withOpacity(0.9),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileSelectionSheet(
    BuildContext context,
    AnalyticsProvider provider,
    List<AnalyticsProfile> profiles,
  ) {
    final selected = provider.profileMatchingSelection(profiles);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      context: context,
      builder: (context) {
        return AppUtils.buildSheetWrapper(
          context: context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(color: Colors.white.withOpacity(0.15), thickness: 3.5, endIndent: 150, indent: 150, height: 10),
              const SizedBox(height: 16),
              Text(
                'Select Profile',
                style: TextStyle(
                  color: AppColors.colorOffWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: StringUtils.fontFamilyHeading,
                ),
              ),
              const SizedBox(height: 16),
              // All Profiles Option
              _buildProfileSheetItem(
                context: context,
                label: 'All Profiles',
                type: null,
                isSelected: selected == null,
                onTap: () {
                  provider.setSelectedProfile(null);
                  provider.fetchAnalytics();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              // Individual Profiles
              if (profiles.isNotEmpty)
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: profiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      final isSelected = selected?.id == profile.id && selected?.type == profile.type;
                      return _buildProfileSheetItem(
                        context: context,
                        label: profile.label ?? profile.type ?? 'Profile',
                        type: profile.type,
                        isSelected: isSelected,
                        onTap: () {
                          provider.setSelectedProfile(profile);
                          provider.fetchAnalytics(
                            profileId: profile.id,
                            profileType: profile.type,
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSheetItem({
    required BuildContext context,
    required String label,
    required String? type,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData getIconForType(String? t) {
      if (t == null) return Icons.grid_view_rounded;
      switch (t.toLowerCase()) {
        case 'business':
          return Icons.business_center_rounded;
        case 'personal':
          return Icons.person_rounded;
        case 'instagram':
          return Icons.camera_alt_outlined;
        case 'spotify':
          return Icons.music_note_rounded;
        case 'youtube':
          return Icons.play_circle_outline_rounded;
        case 'linkedin':
          return Icons.work_outline_rounded;
        default:
          return Icons.credit_card_rounded;
      }
    }

    String getSubtitleForType(String? t) {
      if (t == null) return 'View analytics for all active cards';
      switch (t.toLowerCase()) {
        case 'business':
          return 'Business Profile';
        case 'personal':
          return 'Personal Profile';
        default:
          return '${t[0].toUpperCase()}${t.substring(1)} Channel';
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.colorPurple.withOpacity(0.12)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.colorPurple.withOpacity(0.5)
                  : Colors.white.withOpacity(0.08),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon wrapper
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.colorPurple.withOpacity(0.2)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.colorPurple.withOpacity(0.4)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Icon(
                    getIconForType(type),
                    color: isSelected ? AppColors.colorPurple : AppColors.colorTextMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.colorOffWhite,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontFamily: StringUtils.fontFamilyHeading,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        getSubtitleForType(type),
                        style: TextStyle(
                          color: AppColors.colorTextMuted,
                          fontFamily: StringUtils.fontFamilyPara,
                          fontSize: 11,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Selection checkmark
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradientPurple,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDateRangeSelectionSheet(BuildContext context, AnalyticsProvider provider) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      context: context,
      builder: (context) {
        return AppUtils.buildSheetWrapper(
          context: context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(color: Colors.white.withOpacity(0.15), thickness: 3.5, endIndent: 150, indent: 150, height: 10),
              const SizedBox(height: 16),
              Text(
                'Select Date Range',
                style: TextStyle(
                  color: AppColors.colorOffWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: StringUtils.fontFamilyHeading,
                ),
              ),
              const SizedBox(height: 16),
              _buildDateSheetItem(
                context: context,
                label: 'Last 7 Days',
                isSelected: provider.selectedDateRange == null,
                onTap: () {
                  provider.setDateRange(null);
                  final selected = provider.selectedProfile;
                  provider.fetchAnalytics(
                    profileId: selected?.id,
                    profileType: selected?.type,
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildDateSheetItem(
                context: context,
                label: 'Last 30 Days',
                isSelected: provider.selectedDateRange != null && 
                           provider.selectedDateRange!.duration.inDays == 29 && 
                           provider.selectedDateRange!.end.day == DateTime.now().day,
                onTap: () {
                  final now = DateTime.now();
                  final start = now.subtract(const Duration(days: 29));
                  provider.setDateRange(DateTimeRange(start: start, end: now));
                  final selected = provider.selectedProfile;
                  provider.fetchAnalytics(
                    profileId: selected?.id,
                    profileType: selected?.type,
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildDateSheetItem(
                context: context,
                label: 'Custom Range...',
                isSelected: provider.selectedDateRange != null && 
                           !(provider.selectedDateRange!.duration.inDays == 29 && 
                             provider.selectedDateRange!.end.day == DateTime.now().day),
                onTap: () async {
                  Navigator.pop(context); // Close sheet first
                  
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                    initialDateRange: provider.selectedDateRange,
                    builder: (ctx, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          appBarTheme: const AppBarTheme(
                            backgroundColor: Color(0xFF13131A),
                            foregroundColor: AppColors.colorOffWhite,
                            elevation: 0,
                            iconTheme: IconThemeData(color: AppColors.colorOffWhite),
                          ),
                          scaffoldBackgroundColor: const Color(0xFF0A0A0F),
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.colorPurple,
                            onPrimary: Colors.white,
                            secondary: AppColors.colorPurpleLight,
                            onSecondary: Colors.white,
                            surface: Color(0xFF1C1C27),
                            onSurface: AppColors.colorOffWhite,
                            surfaceContainerHighest: Color(0xFF1C1C27),
                          ),
                          dialogBackgroundColor: const Color(0xFF13131A),
                          textTheme: const TextTheme(
                            bodyLarge: TextStyle(color: AppColors.colorOffWhite),
                            bodyMedium: TextStyle(color: AppColors.colorOffWhite),
                            titleMedium: TextStyle(color: AppColors.colorOffWhite),
                            labelLarge: TextStyle(color: AppColors.colorOffWhite),
                          ),
                          datePickerTheme: DatePickerThemeData(
                            backgroundColor: const Color(0xFF13131A),
                            headerBackgroundColor: const Color(0xFF1C1C27),
                            headerForegroundColor: AppColors.colorOffWhite,
                            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) return Colors.white;
                              if (states.contains(WidgetState.disabled)) return AppColors.colorTextSubtle;
                              return AppColors.colorOffWhite;
                            }),
                            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) return AppColors.colorPurple;
                              return Colors.transparent;
                            }),
                            dayOverlayColor: WidgetStateProperty.all(AppColors.colorPurple.withOpacity(0.15)),
                            todayForegroundColor: WidgetStateProperty.all(AppColors.colorPurple),
                            todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
                            todayBorder: const BorderSide(color: AppColors.colorPurple, width: 1),
                            rangePickerBackgroundColor: const Color(0xFF13131A),
                            rangePickerHeaderBackgroundColor: const Color(0xFF1C1C27),
                            rangePickerHeaderForegroundColor: AppColors.colorOffWhite,
                            rangePickerSurfaceTintColor: Colors.transparent,
                            rangeSelectionBackgroundColor: AppColors.colorPurple.withOpacity(0.18),
                            rangeSelectionOverlayColor: WidgetStateProperty.all(AppColors.colorPurple.withOpacity(0.12)),
                            surfaceTintColor: Colors.transparent,
                            dividerColor: Colors.white.withOpacity(0.06),
                            yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) return Colors.white;
                              return AppColors.colorOffWhite;
                            }),
                            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) return AppColors.colorPurple;
                              return Colors.transparent;
                            }),
                            yearOverlayColor: WidgetStateProperty.all(AppColors.colorPurple.withOpacity(0.15)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.colorPurple,
                              textStyle: TextStyle(
                                fontFamily: StringUtils.fontFamilyHeading,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    provider.setDateRange(picked);
                    final selected = provider.selectedProfile;
                    provider.fetchAnalytics(
                      profileId: selected?.id,
                      profileType: selected?.type,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSheetItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.colorPurple.withOpacity(0.2) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.colorPurple.withOpacity(0.4) : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? AppColors.colorPurple : AppColors.colorTextMuted,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.colorOffWhite : AppColors.colorOffWhite.withOpacity(0.8),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontFamily: StringUtils.fontFamilyHeading,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    bool isWide = false,
  }) {
    return GlassContainer(
      borderRadius: 20,
      blur: 18,
      opacity: 0.05,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.colorPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.colorPurple.withOpacity(0.35),
              ),
            ),
            child: Icon(icon, color: AppColors.colorPurple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.colorTextMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: StringUtils.fontFamilyPara,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.colorOffWhite,
                    fontSize: isWide ? 26 : 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringUtils.fontFamilyHeading,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<ChartDataPoint> points) {
    final provider = Provider.of<AnalyticsProvider>(context, listen: false);
    final range = provider.selectedDateRange;
    String dateLabel;
    if (range != null) {
      final start = '${range.start.day} ${_monthAbbr(range.start.month)}';
      final end = '${range.end.day} ${_monthAbbr(range.end.month)}';
      dateLabel = '$start – $end'.toUpperCase();
    } else {
      dateLabel = 'LAST 7 DAYS';
    }

    return GlassContainer(
      borderRadius: 20,
      blur: 18,
      opacity: 0.05,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassUi.sectionLabel(dateLabel),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildLegendDot(AppColors.colorPurple, 'Views'),
              const SizedBox(width: 16),
              _buildLegendDot(AppColors.colorPurpleLight, 'Clicks'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'No activity history yet.',
                      style: TextStyle(
                        color: AppColors.colorTextMuted,
                        fontSize: 13,
                        fontFamily: StringUtils.fontFamilyPara,
                      ),
                    ),
                  )
                : CustomPaint(
                    size: Size.infinite,
                    painter: TapzyLineChartPainter(points: points),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.colorTextMuted,
            fontSize: 12,
            fontFamily: StringUtils.fontFamilyPara,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(List<ClicksBreakdown> breakdown) {
    return GlassContainer(
      borderRadius: 20,
      blur: 18,
      opacity: 0.05,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassUi.sectionLabel('LINK CLICKS'),
          const SizedBox(height: 16),
          if (breakdown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No click interactions yet.',
                  style: TextStyle(
                    color: AppColors.colorTextMuted,
                    fontSize: 13,
                    fontFamily: StringUtils.fontFamilyPara,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = breakdown[index];
                final maxClicks = breakdown.first.clicks ?? 1;
                final ratio =
                    (item.clicks ?? 0) / (maxClicks == 0 ? 1 : maxClicks);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.colorPurple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.colorPurple.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            _iconForChannel(item.name),
                            size: 16,
                            color: AppColors.colorPurple,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.name ?? 'Channel',
                            style: TextStyle(
                              color: AppColors.colorOffWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: StringUtils.fontFamilyHeading,
                            ),
                          ),
                        ),
                        Text(
                          '${item.clicks ?? 0}',
                          style: TextStyle(
                            color: AppColors.colorTextMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: StringUtils.fontFamilyHeading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: Colors.white.withOpacity(0.06),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.colorPurple,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }

  IconData _iconForChannel(String? name) {
    final key = (name ?? '').toLowerCase();
    if (key.contains('instagram')) return Icons.camera_alt_outlined;
    if (key.contains('linkedin')) return Icons.work_outline_rounded;
    if (key.contains('facebook')) return Icons.facebook_outlined;
    if (key.contains('twitter') || key.contains('x')) {
      return Icons.alternate_email_rounded;
    }
    if (key.contains('youtube')) return Icons.play_circle_outline_rounded;
    if (key.contains('website') || key.contains('web')) {
      return Icons.language_rounded;
    }
    if (key.contains('whatsapp')) return Icons.chat_outlined;
    return Icons.link_rounded;
  }
}

class TapzyLineChartPainter extends CustomPainter {
  final List<ChartDataPoint> points;

  TapzyLineChartPainter({required this.points});

  static const Color _viewsColor = AppColors.colorPurple;
  static const Color _clicksColor = AppColors.colorPurpleLight;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double width = size.width;
    final double height = size.height - 20;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    int maxVal = 5;
    for (final p in points) {
      if ((p.views ?? 0) > maxVal) maxVal = p.views!;
      if ((p.clicks ?? 0) > maxVal) maxVal = p.clicks!;
    }
    maxVal = ((maxVal / 5).ceil() * 5).clamp(5, 999999);

    final double xStep =
        points.length > 1 ? width / (points.length - 1) : width;

    final viewOffsets = <Offset>[];
    final clickOffsets = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = i * xStep;
      var yView = height - ((points[i].views ?? 0) / maxVal * height);
      var yClick = height - ((points[i].clicks ?? 0) / maxVal * height);

      yView = yView.clamp(0.0, height);
      yClick = yClick.clamp(0.0, height);

      viewOffsets.add(Offset(x, yView));
      clickOffsets.add(Offset(x, yClick));

      final textPainter = TextPainter(
        text: TextSpan(
          text: points[i].label ?? '',
          style: TextStyle(
            color: AppColors.colorTextMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: StringUtils.fontFamilyHeading,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - (textPainter.width / 2), height + 8),
      );
    }

    _drawChartPath(canvas, size, viewOffsets, _viewsColor, height);
    _drawChartPath(canvas, size, clickOffsets, _clicksColor, height);
  }

  void _drawChartPath(
    Canvas canvas,
    Size size,
    List<Offset> offsets,
    Color accentColor,
    double chartHeight,
  ) {
    if (offsets.length < 2) return;

    final linePath = Path()..moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 1; i < offsets.length; i++) {
      final pPrev = offsets[i - 1];
      final pCurr = offsets[i];
      final controlPoint1 =
          Offset(pPrev.dx + (pCurr.dx - pPrev.dx) / 2, pPrev.dy);
      final controlPoint2 =
          Offset(pPrev.dx + (pCurr.dx - pPrev.dx) / 2, pCurr.dy);

      linePath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        pCurr.dx,
        pCurr.dy,
      );
    }

    final fillPath = Path.from(linePath)
      ..lineTo(size.width, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withOpacity(0.22),
          accentColor.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final outerDotPaint = Paint()
      ..color = AppColors.colorOffWhite
      ..style = PaintingStyle.fill;

    for (final offset in offsets) {
      canvas.drawCircle(offset, 4.0, outerDotPaint);
      canvas.drawCircle(offset, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _OrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.shader = RadialGradient(colors: [
      AppColors.colorPurple.withOpacity(0.18),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.06), radius: 180));
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.06), 180, paint);

    paint.shader = RadialGradient(colors: [
      AppColors.colorPurpleLight.withOpacity(0.12),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.08, size.height * 0.2), radius: 140));
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.2), 140, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) => false;
}
