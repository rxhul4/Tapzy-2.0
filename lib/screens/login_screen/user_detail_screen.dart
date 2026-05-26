import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/common/commonBackground.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/common/glass_ui.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/models/update_user_profile_model.dart';
import 'package:tapzy/providers/user_profile_provider.dart';
import 'package:tapzy/screens/dashboard_screens/dashboard_screen.dart';
import 'package:tapzy/screens/login_screen/login_screen.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({Key? key}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  UpdateUserProfileModel? updateUserProfileModel;

  Future<void> callUpdateUSerProfileWithoutImageApi(
      BuildContext ctx, UserProfilesProvider postMdl1) async {
    updateUserProfileModel = await postMdl1.callUpdateUserProfileApi(
      first_name: firstNameController.text,
      last_name: lastNameController.text,
    );
    if (updateUserProfileModel?.isSuccessful == 1) {
      await PreferenceHelper.setBool(PreferenceHelper.IS_NEW, false);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
        (route) => false,
      );
    } else {
      AppUtils.showSnackBarWithColor(
        context: ctx,
        message: updateUserProfileModel?.message ?? '',
        giveColor: Colors.redAccent,
      );
    }
  }

  void _submit(UserProfilesProvider postMdl) {
    if (firstNameController.text.trim().isEmpty) {
      AppUtils.showSnackBarWithColor(
        context: context,
        message: 'Enter first name',
        giveColor: Colors.redAccent,
      );
      return;
    }
    if (lastNameController.text.trim().isEmpty) {
      AppUtils.showSnackBarWithColor(
        context: context,
        message: 'Enter last name',
        giveColor: Colors.redAccent,
      );
      return;
    }
    callUpdateUSerProfileWithoutImageApi(context, postMdl);
  }

  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<UserProfilesProvider>(context);

    return CommonBackGround(
      body: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const GlassAmbientOrb(
              size: 200,
              alignment: Alignment(-0.9, -0.85),
              opacity: 0.14,
            ),
            const GlassAmbientOrb(
              size: 160,
              alignment: Alignment(1.0, 0.4),
              opacity: 0.1,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Image.asset(
                      'assets/images/ic_tran_main_white.png',
                      height: 56,
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: GlassContainer(
                          borderRadius: 28,
                          blur: 26,
                          opacity: 0.07,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Last step',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.colorOffWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: StringUtils.fontFamilyHeading,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tell us your name to finish setup',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.colorTextMuted,
                                  fontSize: 12,
                                  fontFamily: StringUtils.fontFamilyPara,
                                ),
                              ),
                              const SizedBox(height: 28),
                              GlassUi.sectionLabel('YOUR NAME'),
                              const SizedBox(height: 12),
                              GlassUi.textField(
                                controller: firstNameController,
                                hintText: 'First name',
                                prefixIcon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 12),
                              GlassUi.textField(
                                controller: lastNameController,
                                hintText: 'Last name',
                                prefixIcon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'You only need to fill this once.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.colorTextMuted,
                                  fontSize: 11,
                                  fontFamily: StringUtils.fontFamilyPara,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GlassUi.primaryButton(
                                label: 'Submit',
                                isLoading: postMdl.isLoading,
                                onTap: () => _submit(postMdl),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'You can always edit this from your profile.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.colorTextSubtle,
                                  fontSize: 11,
                                  fontFamily: StringUtils.fontFamilyPara,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await PreferenceHelper.clear();
                                  if (!context.mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  'Go to Log In',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontFamily: StringUtils.fontFamilyHeading,
                                    fontSize: 12,
                                    color: AppColors.colorPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (postMdl.isLoading)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: AppUtils.loaderWidget(color: AppColors.colorPurple),
              ),
          ],
        ),
      ),
    );
  }
}
