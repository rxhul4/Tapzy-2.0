import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';

/// Glass-styled confirmation & permission dialogs app-wide.
class ConfirmationDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String confirmText,
    required VoidCallback onConfirm,
    String cancelText = 'Cancel',
    VoidCallback? onCancel,
    String? message,
    IconData? icon,
    Color? confirmColor,
    bool isDestructive = false,
  }) {
    final accent = confirmColor ??
        (isDestructive ? AppColors.colorError : AppColors.colorPurple);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: GlassContainer(
            borderRadius: 24,
            blur: 24,
            opacity: 0.08,
            tintColor: accent,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.15),
                    border: Border.all(color: accent.withOpacity(0.35)),
                  ),
                  child: Icon(
                    icon ??
                        (isDestructive
                            ? Icons.warning_amber_rounded
                            : Icons.help_outline_rounded),
                    color: accent,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.colorOffWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringUtils.fontFamilyHeading,
                    height: 1.3,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.colorTextMuted,
                      fontSize: 13,
                      height: 1.45,
                      fontFamily: StringUtils.fontFamilyPara,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _cancelBtn(ctx, cancelText, onCancel)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _confirmBtn(ctx, confirmText, accent, onConfirm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showPermission({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      title: 'Permission required',
      message: message,
      confirmText: 'Settings',
      cancelText: 'Cancel',
      icon: Icons.settings_outlined,
      onConfirm: () => openAppSettings(),
    );
  }

  static void showDeleteProfile({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    show(
      context: context,
      title: 'Delete profile?',
      message:
          'Are you sure you want to delete this profile? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
      onConfirm: onConfirm,
    );
  }

  static Widget _cancelBtn(
      BuildContext ctx, String text, VoidCallback? onCancel) {
    return OutlinedButton(
      onPressed: () {
        Navigator.pop(ctx);
        onCancel?.call();
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.colorTextMuted,
          fontSize: 13,
          fontFamily: StringUtils.fontFamilyHeading,
        ),
      ),
    );
  }

  static Widget _confirmBtn(
    BuildContext ctx,
    String text,
    Color accent,
    VoidCallback onConfirm,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(ctx);
        onConfirm();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: accent.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.colorWhite,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: StringUtils.fontFamilyHeading,
        ),
      ),
    );
  }
}
