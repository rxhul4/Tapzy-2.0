import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tapzy/core/utils/confirmation_dialog.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/appConstants.dart';
import 'package:tapzy/core/constants/stringUtils.dart';


class AppUtils {


  static final List<String> filters = [
    'All',
    'Today',
    'Yesterday',
    'This Week',
  ];


  static Widget commonTextWidget({
    required String text,
    Color? textColor,
    double? fontSize,
    double? letterSpacing,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    TextAlign? textAlign,
    EdgeInsets? margin,
    EdgeInsets? padding,
    TextDecoration? decoration,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return commonContainer(
      padding: padding,
      margin: margin,
      child: Text(
        softWrap: softWrap,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        text,
        style: TextStyle(
          decoration: decoration,
          color: textColor ?? Colors.white,
          fontSize: fontSize ?? AppConstants.fourteen,
          letterSpacing: letterSpacing ?? AppConstants.two,
          fontWeight: fontWeight,
          height: height,
          fontFamily: fontFamily ?? StringUtils.fontFamilyPara,
        ),
      ),
    );
  }

  static Widget noListWidget(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            color: AppColors.colorPurple,
            "assets/images/noList.png",
            fit: BoxFit.cover,
            height: 150,
            // width: 80,
          ),
          AppUtils.commonTextWidget(
            text: "No Profile Found",
            textColor: AppColors.colorGrey,
          ),
          // AppUtils.commonSizedBox(height: 5),
          // AppUtils.commonTextWidget(
          //     text: "Pull to refresh.",
          //     textColor: AppColors.colorGrey,
          //     fontSize: AppConstants.twelve,
          //     fontFamily: StringUtils.fontFamilyHeading,
          //     letterSpacing: AppConstants.one
          // ),
        ],
      ),
    );
  }

  static Widget noDataFound(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/404.png",
            fit: BoxFit.cover,
            height: 120,
          ),
          const SizedBox(height: 16),
          AppUtils.commonTextWidget(
            text: "Something went wrong",
            textColor: AppColors.colorOffWhite,
            fontFamily: StringUtils.fontFamilyHeading,
            fontWeight: FontWeight.w600,
          ),
          AppUtils.commonSizedBox(height: 6),
          AppUtils.commonTextWidget(
            text: "Pull to refresh",
            textColor: AppColors.colorTextMuted,
            fontSize: 12,
            fontFamily: StringUtils.fontFamilyPara,
          ),
          // AppUtils.commonSizedBox(height: 5),
          // AppUtils.commonTextWidget(
          //     text: "Pull to refresh.",
          //     textColor: AppColors.colorGrey,
          //     fontSize: AppConstants.twelve,
          //     fontFamily: StringUtils.fontFamilyHeading,
          //     letterSpacing: AppConstants.one
          // ),
        ],
      ),
    );
  }

  static Widget commonSizedBox({
    double? height,
    double? width,
    Widget? child,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: child,
    );
  }

  static EdgeInsets edgeInsetsOnly({
    double? bottom,
    double? top,
    double? right,
    double? left,
  }) {
    return EdgeInsets.only(
        bottom: bottom ?? AppConstants.zero,
        top: top ?? AppConstants.zero,
        right: right ?? AppConstants.zero,
        left: left ?? AppConstants.zero);
  }

  static double getMediaHeight(BuildContext uiContext) {
    return MediaQuery.of(uiContext).size.height;
  }

  static double getMediaWidth(BuildContext uiContext) {
    return MediaQuery.of(uiContext).size.width;
  }

  static Widget commonContainer({
    double? height,
    double? width,
    BoxDecoration? decoration,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Widget? child,
    Color? color,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: decoration,
      margin: margin,
      padding: padding,
      color: color,
      child: child,
    );
  }

  static Widget commonInkWell({
    Widget? child,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
    Color? highlightColor,
  }) {
    return InkWell(
      highlightColor: highlightColor,
      borderRadius: borderRadius,
      onTap: onTap,
      child: child,
    );
  }

  static BoxDecoration commonBoxDecoration(
      {Color? color,
      BoxBorder? border,
      Gradient? gradient,
      BoxShape? shape,
      DecorationImage? image,
      BorderRadiusGeometry? borderRadius}) {
    return BoxDecoration(
      image: image,
      shape: shape ?? BoxShape.rectangle,
      color: color,
      border: border,
      gradient: gradient,
      borderRadius: borderRadius,
    );
  }

  static BorderRadiusGeometry borderRadiusAll({double? raduis}) {
    return BorderRadius.all(Radius.circular(raduis ?? AppConstants.twelve));
  }

  /// Returns username/handle only (no URL) for API storage on social cards.
  static String extractSocialUsername(String type, String fieldVal) {
    if (fieldVal.isEmpty) return '';
    final formatted = formatSocialUsername(type, fieldVal);
    var value = formatted.replaceAll('@', '').trim();
    if (value.contains('/')) {
      final parts = value.split('/').where((s) => s.isNotEmpty).toList();
      if (parts.isNotEmpty) value = parts.last;
    }
    return value;
  }

  static bool socialTypeUsesUsernameOnly(String type) {
    final t = type.toLowerCase();
    return t != 'personal' && t != 'youtube';
  }

  static String socialUsernameHint(String type) {
    switch (type.toLowerCase()) {
      case 'instagram':
        return 'e.g. johndoe';
      case 'linkedin':
        return 'e.g. johndoe';
      case 'youtube':
        return 'e.g. youtube.com/c/channel or full URL';
      case 'spotify':
        return 'e.g. spotifyusername';
      case 'personal':
        return 'e.g. tapzy.in or full URL';
      default:
        return 'e.g. username';
    }
  }

  static String formatSocialUsername(String type, String fieldVal) {
    if (fieldVal.isEmpty) return '';
    final cleaned = fieldVal.trim();
    final lowerType = type.toLowerCase();
    
    try {
      Uri uri = Uri.parse(cleaned);
      if (uri.pathSegments.isNotEmpty) {
        for (int i = uri.pathSegments.length - 1; i >= 0; i--) {
          final seg = uri.pathSegments[i].trim();
          if (seg.isNotEmpty) {
            if (lowerType == 'instagram' || lowerType == 'twitter' || lowerType == 'tiktok') {
              return '@$seg';
            }
            return seg;
          }
        }
      }
    } catch (_) {}

    if (lowerType == 'instagram') {
      final match = RegExp(r'(?:instagram\.com/|ig:|insta:)\s*([a-zA-Z0-9_.]+)').firstMatch(cleaned);
      if (match != null && match.groupCount >= 1) {
        return '@${match.group(1)}';
      }
    } else if (lowerType == 'linkedin') {
      final match = RegExp(r'(?:linkedin\.com/in/|linkedin\.com/company/)\s*([a-zA-Z0-9_-]+)').firstMatch(cleaned);
      if (match != null && match.groupCount >= 1) {
        return match.group(1) ?? cleaned;
      }
    } else if (lowerType == 'spotify') {
      final match = RegExp(r'(?:spotify\.com/user/|spotify\.com/artist/|spotify:user:|spotify:artist:)\s*([a-zA-Z0-9_-]+)').firstMatch(cleaned);
      if (match != null && match.groupCount >= 1) {
        return match.group(1) ?? cleaned;
      }
    }

    String result = cleaned;
    if (result.startsWith('https://')) result = result.substring(8);
    if (result.startsWith('http://')) result = result.substring(7);
    if (result.startsWith('www.')) result = result.substring(4);
    if (result.endsWith('/')) result = result.substring(0, result.length - 1);
    
    if (lowerType == 'instagram' || lowerType == 'twitter' || lowerType == 'tiktok') {
      if (!result.startsWith('@') && !result.contains('/')) {
        return '@$result';
      }
    }
    return result;
  }

  static String setImageByType(String type) {
    print("typetypetypetype $type");
    String imageString = 'assets/images/card2.jpg';
    if (type.toLowerCase() == "business") {
      imageString = 'assets/images/card2.jpg';
    } else if (type.toLowerCase() == "personal") {
      imageString = 'assets/images/card2.jpg';
    } else if (type.toLowerCase() == "instagram") {
      imageString = 'assets/images/card1.jpg';
    } else if (type.toLowerCase() == "spotify") {
      imageString = 'assets/images/card5.jpg';
    } else if (type.toLowerCase() == "youtube") {
      imageString = 'assets/images/card3.jpg';
    } else if (type.toLowerCase() == "linkedin") {
      imageString = 'assets/images/card4.jpg';
    } else {
      imageString = 'assets/images/card2.jpg';
    }
    return imageString;
  }

  static String setIconByType(String type) {
    print("typetypetypetype $type");
    String imageString = 'assets/images/account.png';
    if (type.toLowerCase() == "business") {
      imageString = 'assets/images/briefcase.png';
    } else if (type.toLowerCase() == "personal") {
      imageString = 'assets/images/account.png';
    } else if (type.toLowerCase() == "instagram") {
      imageString = 'assets/images/instagram.png';
    } else if (type.toLowerCase() == "spotify") {
      imageString = 'assets/images/spotify.png';
    } else if (type.toLowerCase() == "youtube") {
      imageString = 'assets/images/youtube.png';
    } else if (type.toLowerCase() == "linkedin") {
      imageString = 'assets/images/linkedin.png';
    } else {
      imageString = 'assets/images/account.png';
    }
    return imageString;
  }

  static Widget commonElevatedBtn({
    double? width,
    Color? bgColor,
    double? borderRadiusAll,
    double? bottomMargin,
    double? topMargin,
    double? rightMargin,
    double? leftMargin,
    VoidCallback? onPressed,
    String? text,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    Color? textColor,
    double? height,
    BoxBorder? border,
    Gradient? gradient,
    DecorationImage? image,
    EdgeInsetsGeometry? padding,
  }) {
    return AppUtils.commonContainer(
      height: height,
      width: width,
      decoration: AppUtils.commonBoxDecoration(
        color: bgColor,
        gradient: gradient,
        image: image,
        border: border,
        borderRadius: BorderRadius.circular(borderRadiusAll ?? 10),
      ),
      margin: AppUtils.edgeInsetsOnly(
          bottom: bottomMargin ?? AppConstants.forty,
          top: topMargin ?? AppConstants.thirty,
          right: rightMargin ?? AppConstants.twenty,
          left: leftMargin ?? AppConstants.twenty),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusAll ?? 10),
          ),
        ),
        child: AppUtils.commonTextWidget(
          text: text ?? '',
          textColor: textColor,
          fontFamily: fontFamily ?? StringUtils.fontFamilyHeading,
          fontSize: fontSize ?? AppConstants.fourteen,
          letterSpacing: letterSpacing ?? AppConstants.zero,
        ),
      ),
    );
  }

  static showSnackBarWithColor(
      {required BuildContext context,
      required String message,
      Color? giveColor}) {
    final color = giveColor ?? AppColors.colorSuccess;
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2200),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.colorCard.withOpacity(0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.45)),
        ),
        content: Row(
          children: [
            Icon(
              color == Colors.redAccent || color == AppColors.colorError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.colorOffWhite,
                  fontSize: 13,
                  fontFamily: StringUtils.fontFamilyPara,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static loaderWidget({Color? color,double? size}) {
    return Center(
      child: SpinKitWave(
        size: size ?? 50,
        color: color ?? AppColors.colorPurple,
      ),
    );
  }
  static openAppSettingsPermissionDialog(
      {required String msg, required BuildContext ctxx}) {
    ConfirmationDialog.showPermission(context: ctxx, message: msg);
  }
}
