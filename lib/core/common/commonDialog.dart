import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tapzy/core/common/commonProfileScreen.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/screens/profiles/business_profile_screen.dart';

class CommonDialog extends StatefulWidget {
  final int? selectedIndex;
  final Widget? dialogWidget;
  final Function? showmessage;
  final EdgeInsets? insetPadding;

  const CommonDialog({
    super.key,
    this.dialogWidget,
    this.showmessage,
    this.selectedIndex,
    this.insetPadding,
  });

  @override
  State<CommonDialog> createState() => _CommonDialogState();
}

class _CommonDialogState extends State<CommonDialog> {
  final List<FaIconData> icons = [
    FontAwesomeIcons.briefcase,
    FontAwesomeIcons.solidUser,
    FontAwesomeIcons.instagram,
    FontAwesomeIcons.spotify,
    FontAwesomeIcons.youtube,
    FontAwesomeIcons.linkedinIn,
  ];

  final List<String> iconNames = [
    'Business',
    'Personal',
    'Instagram',
    'Spotify',
    'Youtube',
    'Linkedin',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: widget.insetPadding ??
          const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: widget.dialogWidget ?? _buildProfileTypePicker(context),
    );
  }

  Widget _buildProfileTypePicker(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: GlassContainer(
          borderRadius: 28,
          blur: 24,
          opacity: 0.08,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 36),
                  Text(
                    'SELECT PROFILE TYPE',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.colorOffWhite,
                      fontFamily: StringUtils.fontFamilyHeading,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.colorTextMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Create your profile and start connecting',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.colorTextMuted,
                  fontSize: 12,
                  fontFamily: StringUtils.fontFamilyPara,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (iconNames[index] == 'Business') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessProfileScreen(
                                showmessage: widget.showmessage,
                                isNew: true,
                                selectedIndex: widget.selectedIndex,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommonProfileScreen(
                                isPersonal: iconNames[index] == 'Personal',
                                titleName: iconNames[index],
                                selectedIndex: widget.selectedIndex,
                              ),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: GlassContainer(
                        borderRadius: 16,
                        blur: 12,
                        opacity: 0.05,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.colorPurple
                                    .withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FaIcon(
                                icons[index],
                                size: 18,
                                color: AppColors.colorPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              iconNames[index],
                              style: TextStyle(
                                fontFamily: StringUtils.fontFamilyHeading,
                                fontSize: 10,
                                color: AppColors.colorOffWhite,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
