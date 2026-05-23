import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/common/commonBackground.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/models/add_social_profile_model.dart';
import 'package:tapzy/providers/profiles_provider.dart';
import 'package:tapzy/screens/dashboard_screens/dashboard_screen.dart';

class CommonProfileScreen extends StatefulWidget {
  final String? titleName;
  final int? selectedIndex;
  final bool? isPersonal;

  const CommonProfileScreen({
    Key? key,
    this.titleName,
    this.selectedIndex,
    this.isPersonal,
  }) : super(key: key);

  @override
  State<CommonProfileScreen> createState() => _CommonProfileScreenState();
}

class _CommonProfileScreenState extends State<CommonProfileScreen> {
  AddSocialSocialModel? addSocialSocialModel;
  final TextEditingController linkController = TextEditingController();
  final TextEditingController labelController = TextEditingController();

  void callAddSocialProfileApi(
    BuildContext ctx,
    ProfilesProvider postMdl1,
    String socialType,
    String enteredLink,
    String cardLabel,
  ) {
    postMdl1
        .callAddSocialProfile(enteredLink, socialType, cardLabel)
        .then((value) {
      addSocialSocialModel = value;
      if (addSocialSocialModel?.isSuccessful == 1) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              selectedIndex: widget.selectedIndex,
            ),
          ),
          (route) => false,
        );
        AppUtils.showSnackBarWithColor(
          context: ctx,
          message: addSocialSocialModel?.message ?? '',
        );
      } else {
        AppUtils.showSnackBarWithColor(
          context: ctx,
          message: addSocialSocialModel?.message ?? '',
          giveColor: Colors.redAccent,
        );
      }
    });
  }

  void _onSubmit(ProfilesProvider postMdl) {
    if (labelController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
        context: context,
        message: 'Enter card label',
        giveColor: Colors.redAccent,
      );
      return;
    }
    final socialType = widget.titleName ?? '';
    final usesUsername = AppUtils.socialTypeUsesUsernameOnly(socialType);
    String valueToSend = linkController.text.trim();

    if (usesUsername) {
      valueToSend = AppUtils.extractSocialUsername(socialType, valueToSend);
      if (valueToSend.isEmpty) {
        AppUtils.showSnackBarWithColor(
          context: context,
          message: 'Enter username',
          giveColor: Colors.redAccent,
        );
        return;
      }
    } else {
      if (!valueToSend.startsWith('http://') && !valueToSend.startsWith('https://')) {
        valueToSend = 'https://$valueToSend';
      }
      if (!Uri.parse(valueToSend).isAbsolute) {
        AppUtils.showSnackBarWithColor(
          context: context,
          message: 'Please enter a valid link',
          giveColor: Colors.redAccent,
        );
        return;
      }
    }

    callAddSocialProfileApi(
      context,
      postMdl,
      socialType,
      valueToSend,
      labelController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<ProfilesProvider>(context);
    final title = widget.titleName ?? 'Card';

    return CommonBackGround(
      body: Stack(
        children: [
          const GlassAmbientOrb(
            size: 220,
            alignment: Alignment(-0.95, -0.9),
            opacity: 0.16,
          ),
          const GlassAmbientOrb(
            size: 180,
            alignment: Alignment(1.05, 0.5),
            opacity: 0.1,
          ),
          SafeArea(
            child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Center(
                  child: _GlassBackButton(onTap: () => Navigator.pop(context)),
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: StringUtils.fontFamilyHeading,
                  fontSize: 16,
                  color: AppColors.colorOffWhite,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: GlassContainer(
                    borderRadius: 28,
                    blur: 26,
                    opacity: 0.07,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCardPreview(title),
                        const SizedBox(height: 28),
                        _buildFieldLabel('Card Label'),
                        const SizedBox(height: 8),
                        _glassTextField(
                          controller: labelController,
                          hintText: 'e.g. My Personal Card',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 20),
                        _buildFieldLabel(
                          AppUtils.socialTypeUsesUsernameOnly(title)
                              ? 'Username'
                              : 'Profile Link',
                        ),
                        const SizedBox(height: 8),
                        _glassTextField(
                          controller: linkController,
                          hintText: AppUtils.socialUsernameHint(title),
                          keyboardType: AppUtils.socialTypeUsesUsernameOnly(title)
                              ? TextInputType.text
                              : TextInputType.url,
                        ),
                        const SizedBox(height: 28),
                        _buildSubmitButton(() => _onSubmit(postMdl)),
                      ],
                    ),
                  ),
                ),
                if (postMdl.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.35),
                    child: AppUtils.loaderWidget(
                      color: AppColors.colorPurple,
                    ),
                  ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview(String title) {
    return GlassContainer(
      borderRadius: 20,
      blur: 16,
      opacity: 0.04,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 168,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppUtils.setImageByType(title),
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassContainer(
                      borderRadius: 999,
                      blur: 14,
                      opacity: 0.12,
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        AppUtils.setIconByType(title),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.colorOffWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                        fontFamily: StringUtils.fontFamilyHeading,
                        shadows: [
                          Shadow(
                            color: AppColors.colorPurple.withOpacity(0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Card preview',
                      style: TextStyle(
                        color: AppColors.colorTextMuted,
                        fontSize: 10,
                        fontFamily: StringUtils.fontFamilyPara,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: StringUtils.fontFamilyHeading,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return GlassContainer(
      borderRadius: 16,
      blur: 12,
      opacity: 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: AppColors.colorOffWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppColors.gradientPurple,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPurple.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Center(
              child: Text(
                'Create Card',
                style: TextStyle(
                  color: AppColors.colorWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: StringUtils.fontFamilyHeading,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          Icons.arrow_back_rounded,
          color: AppColors.colorOffWhite,
          size: 20,
        ),
      ),
    );
  }
}
