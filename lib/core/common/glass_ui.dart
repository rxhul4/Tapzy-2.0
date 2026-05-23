import 'package:flutter/material.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';

/// Shared glass form / validation widgets for auth & profile flows.
class GlassUi {
  GlassUi._();

  static Widget backButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 12,
        blur: 16,
        opacity: 0.05,
        width: 40,
        height: 40,
        padding: EdgeInsets.zero,
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.colorOffWhite,
          size: 18,
        ),
      ),
    );
  }

  static Widget fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.colorOffWhite.withOpacity(0.85),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: StringUtils.fontFamilyHeading,
        letterSpacing: 0.3,
      ),
    );
  }

  static Widget sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppColors.gradientPurple,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: AppColors.colorTextMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            fontFamily: StringUtils.fontFamilyHeading,
          ),
        ),
      ],
    );
  }

  static Widget errorText(String message) {
    return Row(
      children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.colorError, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: AppColors.colorError.withOpacity(0.95),
              fontSize: 12,
              fontFamily: StringUtils.fontFamilyPara,
            ),
          ),
        ),
      ],
    );
  }

  static Widget textField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool hasError = false,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
  }) {
    return GlassContainer(
      borderRadius: 16,
      blur: 14,
      opacity: 0.05,
      border: hasError
          ? Border.all(color: AppColors.colorError.withOpacity(0.55))
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon,
                size: 20, color: AppColors.colorPurple.withOpacity(0.85)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: TextStyle(
                color: readOnly
                    ? AppColors.colorTextMuted
                    : AppColors.colorOffWhite,
                fontSize: 14,
                fontFamily: StringUtils.fontFamilyHeading,
              ),
              cursorColor: AppColors.colorPurple,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.colorTextMuted.withOpacity(0.8),
                  fontSize: 13,
                  fontFamily: StringUtils.fontFamilyPara,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget primaryButton({
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isLoading
                ? LinearGradient(
                    colors: [
                      AppColors.colorPurple.withOpacity(0.4),
                      AppColors.colorPurpleLight.withOpacity(0.3),
                    ],
                  )
                : AppColors.gradientPurple,
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPurple.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Center(
              child: isLoading
                  ? AppUtils.loaderWidget(size: 22, color: AppColors.colorWhite)
                  : Text(
                      label,
                      style: TextStyle(
                        color: AppColors.colorWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: StringUtils.fontFamilyHeading,
                        letterSpacing: 0.4,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget noData({
    String title = 'Something went wrong',
    String subtitle = 'Pull to refresh or try again later',
    IconData icon = Icons.cloud_off_rounded,
  }) {
    return Center(
      child: GlassContainer(
        borderRadius: 24,
        blur: 20,
        opacity: 0.06,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.colorPurple.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorOffWhite,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: StringUtils.fontFamilyHeading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorTextMuted,
                fontSize: 12,
                fontFamily: StringUtils.fontFamilyPara,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
