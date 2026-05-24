import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/providers/dashboard_provider.dart';

/// Glass popup — pick an inactive profile to re-enable as a card.
class AddCardDialog extends StatelessWidget {
  final Map<int, String>? disableCardMap;
  final DashboardProvider postMdl;
  final void Function(BuildContext ctx, String cardId, DashboardProvider postMdl)
      onSelect;

  const AddCardDialog({
    super.key,
    required this.disableCardMap,
    required this.postMdl,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<int, String>? disableCardMap,
    required DashboardProvider postMdl,
    required void Function(
            BuildContext ctx, String cardId, DashboardProvider postMdl)
        onSelect,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) => AddCardDialog(
        disableCardMap: disableCardMap,
        postMdl: postMdl,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = disableCardMap?.entries.toList() ?? [];
    final maxH = MediaQuery.of(context).size.height * 0.55;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: GlassContainer(
            borderRadius: 28,
            blur: 24,
            opacity: 0.08,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.colorSurface.withOpacity(0.75),
                AppColors.colorCardDark.withOpacity(0.85),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.colorPurple.withOpacity(0.35),
                            AppColors.colorPurpleLight.withOpacity(0.2),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.colorPurple.withOpacity(0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.credit_card_rounded,
                        color: AppColors.colorPurple,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Card',
                            style: TextStyle(
                              color: AppColors.colorOffWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: StringUtils.fontFamilyHeading,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            'Select an inactive profile',
                            style: TextStyle(
                              color: AppColors.colorTextMuted,
                              fontSize: 11,
                              fontFamily: StringUtils.fontFamilyPara,
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
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AppColors.colorOffWhite.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.white.withOpacity(0.06),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxH),
                  child: entries.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return _ProfileTile(
                              label: entry.value,
                              onTap: () => onSelect(
                                context,
                                entry.key.toString(),
                                postMdl,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: AppColors.colorTextMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No inactive profiles',
            style: TextStyle(
              color: AppColors.colorOffWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: StringUtils.fontFamilyHeading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a new profile first, or disable an existing card to add it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.colorTextMuted,
              fontSize: 11,
              height: 1.5,
              fontFamily: StringUtils.fontFamilyPara,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.colorPurple.withOpacity(0.15),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.colorPurple.withOpacity(0.22),
                AppColors.colorPurpleLight.withOpacity(0.12),
              ],
            ),
            border: Border.all(
              color: AppColors.colorPurple.withOpacity(0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.label_outline_rounded,
                    color: AppColors.colorOffWhite,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile label',
                        style: TextStyle(
                          color: AppColors.colorTextMuted,
                          fontSize: 10,
                          fontFamily: StringUtils.fontFamilyPara,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.colorOffWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: StringUtils.fontFamilyHeading,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.colorPurple.withOpacity(0.9),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
