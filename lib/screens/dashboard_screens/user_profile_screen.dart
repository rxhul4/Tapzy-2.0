import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/models/get_user_profile_model.dart';
import 'package:tapzy/models/update_user_profile_model.dart';
import 'package:tapzy/providers/user_profile_provider.dart';
import 'package:tapzy/core/utils/confirmation_dialog.dart';
import 'package:tapzy/screens/login_screen/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _image;
  var imageFull;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  UpdateUserProfileModel? updateUserProfileModel;
  GetUserProfileModel? getUserProfileModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postMdl = Provider.of<UserProfilesProvider>(context, listen: false);
      callGetUserProfileApi(postMdl);
    });
  }

  Future<void> getImage() async {
    if (Platform.isIOS) {
      var status1 = await Permission.photos.request();
      if (status1.isDenied || status1.isPermanentlyDenied) {
        AppUtils.openAppSettingsPermissionDialog(
          ctxx: context,
          msg:
              "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Photos' and enable access for our app",
        );
      } else {
        imageFull =
            await ImagePicker.platform.pickImage(source: ImageSource.gallery);
        if (imageFull?.path != null) {
          setState(() => _image = File(imageFull?.path ?? ''));
        }
      }
    } else {
      final deviceInformation = await deviceInfo.androidInfo;
      if (deviceInformation.version.sdkInt > 32) {
        var status = await Permission.photos.request();
        if (status.isGranted) {
          imageFull =
              await ImagePicker.platform.pickImage(source: ImageSource.gallery);
          if (imageFull?.path != null) {
            setState(() => _image = File(imageFull?.path ?? ''));
          }
        } else {
          AppUtils.openAppSettingsPermissionDialog(
            ctxx: context,
            msg:
                "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Photos' and enable access for our app",
          );
        }
      } else {
        var status1 = await Permission.storage.request();
        if (status1.isGranted) {
          imageFull =
              await ImagePicker.platform.pickImage(source: ImageSource.gallery);
          if (imageFull?.path != null) {
            setState(() => _image = File(imageFull?.path ?? ''));
          }
        } else {
          AppUtils.openAppSettingsPermissionDialog(
            ctxx: context,
            msg:
                "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Storage' and enable access for our app",
          );
        }
      }
    }
  }

  void callGetUserProfileApi(UserProfilesProvider postMdl) {
    postMdl.callGetUserProfileApi().then((value) {
      getUserProfileModel = value;
      if (getUserProfileModel?.isSuccessful == 1) {
        firstNameController.text = getUserProfileModel?.data?.firstName ?? '';
        lastNameController.text = getUserProfileModel?.data?.lastName ?? '';
        emailController.text = getUserProfileModel?.data?.email ?? '';
        phoneController.text =
            getUserProfileModel?.data?.phoneNumber.toString() == 'null'
                ? ''
                : getUserProfileModel?.data?.phoneNumber.toString() ?? '';
        if (mounted) setState(() {});
      }
    });
  }

  void callUpdateUSerProfileWithoutImageApi(
      BuildContext ctx, UserProfilesProvider postMdl1) async {
    postMdl1
        .callUpdateUserProfileApi(
          phoneNumber: phoneController.text,
          first_name: firstNameController.text,
          last_name: lastNameController.text,
        )
        .then((value) {
      updateUserProfileModel = value;
      if (updateUserProfileModel?.isSuccessful == 1) {
        AppUtils.showSnackBarWithColor(
          context: ctx,
          message: updateUserProfileModel?.message ?? '',
        );
        callGetUserProfileApi(postMdl1);
      } else {
        AppUtils.showSnackBarWithColor(
          context: ctx,
          message: updateUserProfileModel?.message ?? '',
          giveColor: Colors.redAccent,
        );
      }
    });
  }

  void callUpdateUSerProfileApi(
      BuildContext ctx, UserProfilesProvider postMdl1) async {
    postMdl1
        .callUpdateUserProfile(
          context: context,
          phoneNumber: phoneController.text,
          first_name: firstNameController.text,
          imageFile: _image,
          last_name: lastNameController.text,
        )
        .then((value) {
      updateUserProfileModel = value;
      if (updateUserProfileModel?.isSuccessful == 1) {
        AppUtils.showSnackBarWithColor(
          context: ctx,
          message: updateUserProfileModel?.message ?? '',
        );
        setState(() => _image = null);
        callGetUserProfileApi(postMdl1);
      } else {
        AppUtils.showSnackBarWithColor(
          context: ctx,
          message: updateUserProfileModel?.message ?? '',
          giveColor: Colors.redAccent,
        );
      }
    });
  }

  void _onUpdateProfile(UserProfilesProvider postMdl) {
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
    if (emailController.text.trim().isEmpty) {
      AppUtils.showSnackBarWithColor(
        context: context,
        message: 'Enter email address',
        giveColor: Colors.redAccent,
      );
      return;
    }
    if (_image == null) {
      callUpdateUSerProfileWithoutImageApi(context, postMdl);
    } else {
      callUpdateUSerProfileApi(context, postMdl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<UserProfilesProvider>(context);
    final displayName =
        '${firstNameController.text} ${lastNameController.text}'.trim();

    if (postMdl.isFetching) {
      return AppUtils.loaderWidget();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const GlassAmbientOrb(
          size: 200,
          alignment: Alignment(0.95, -0.85),
          opacity: 0.16,
        ),
        const GlassAmbientOrb(
          size: 160,
          alignment: Alignment(-0.95, 0.2),
          opacity: 0.1,
        ),
        RefreshIndicator(
          onRefresh: () async => callGetUserProfileApi(postMdl),
          color: AppColors.colorPurple,
          backgroundColor: AppColors.colorSurface,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              _buildProfileHeader(displayName),
              const SizedBox(height: 16),
              GlassContainer(
                borderRadius: 28,
                blur: 26,
                opacity: 0.07,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: 8),
                    _buildChangeImageButton(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('PERSONAL INFO'),
                    const SizedBox(height: 12),
                    _glassTextField(
                      controller: firstNameController,
                      hintText: 'First name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _glassTextField(
                      controller: lastNameController,
                      hintText: 'Last name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('CONTACT'),
                    const SizedBox(height: 12),
                    _glassTextField(
                      controller: emailController,
                      hintText: 'Email address',
                      icon: Icons.email_outlined,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _glassTextField(
                      controller: phoneController,
                      hintText: 'Phone number (optional)',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildUpdateButton(postMdl),
              const SizedBox(height: 12),
              _buildLogoutButton(),
            ],
          ),
        ),
        if (postMdl.isLoading || postMdl.isUploading)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: AppUtils.loaderWidget(color: AppColors.colorPurple),
          ),
      ],
    );
  }

  Widget _buildProfileHeader(String displayName) {
    return GlassContainer(
      borderRadius: 20,
      blur: 20,
      opacity: 0.06,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  AppColors.colorPurple.withOpacity(0.35),
                  AppColors.colorPurpleLight.withOpacity(0.2),
                ],
              ),
              border: Border.all(
                color: AppColors.colorPurple.withOpacity(0.4),
              ),
            ),
            child: const Icon(
              Icons.account_circle_rounded,
              color: AppColors.colorPurple,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: TextStyle(
                    color: AppColors.colorOffWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringUtils.fontFamilyHeading,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName.isEmpty ? 'Manage your account' : displayName,
                  style: TextStyle(
                    color: AppColors.colorTextMuted,
                    fontSize: 12,
                    fontFamily: StringUtils.fontFamilyPara,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPurple.withOpacity(0.4),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        GlassContainer(
          borderRadius: 999,
          blur: 18,
          opacity: 0.1,
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(3),
          gradient: AppColors.gradientPurple,
          child: GlassContainer(
            borderRadius: 999,
            blur: 12,
            opacity: 0.05,
            padding: EdgeInsets.zero,
            child: ClipOval(
              child: SizedBox(
                width: 88,
                height: 88,
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl:
                            getUserProfileModel?.data?.profileImage ?? '',
                        placeholder: (_, __) => const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.colorPurple,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.colorCard,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 44,
                            color: AppColors.colorPurpleLight,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeImageButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: getImage,
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          borderRadius: 20,
          blur: 14,
          opacity: 0.06,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt_rounded,
                size: 15,
                color: AppColors.colorPurple.withOpacity(0.95),
              ),
              const SizedBox(width: 8),
              Text(
                'Change Image',
                style: TextStyle(
                  color: AppColors.colorOffWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: StringUtils.fontFamilyHeading,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
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
              letterSpacing: 1.8,
              fontFamily: StringUtils.fontFamilyHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return GlassContainer(
      borderRadius: 16,
      blur: 12,
      opacity: 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          _fieldIcon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: TextStyle(
                color: readOnly
                    ? AppColors.colorTextMuted
                    : AppColors.colorOffWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: StringUtils.fontFamilyHeading,
              ),
              cursorColor: AppColors.colorPurple,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.colorTextMuted.withOpacity(0.85),
                  fontSize: 13,
                  fontFamily: StringUtils.fontFamilyPara,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.colorPurple.withOpacity(0.2),
            AppColors.colorPurpleLight.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.colorPurple.withOpacity(0.3),
        ),
      ),
      child: Icon(icon, size: 15, color: AppColors.colorPurple),
    );
  }

  Widget _buildUpdateButton(UserProfilesProvider postMdl) {
    final isBusy = postMdl.isLoading || postMdl.isUploading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : () => _onUpdateProfile(postMdl),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isBusy
                ? LinearGradient(
                    colors: [
                      AppColors.colorPurple.withOpacity(0.4),
                      AppColors.colorPurpleLight.withOpacity(0.3),
                    ],
                  )
                : AppColors.gradientPurple,
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
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
              child: isBusy
                  ? AppUtils.loaderWidget(size: 22, color: AppColors.colorWhite)
                  : Text(
                      'Update Profile',
                      style: TextStyle(
                        color: AppColors.colorWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: StringUtils.fontFamilyHeading,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: confirmLogoutDialog,
        borderRadius: BorderRadius.circular(16),
        child: GlassContainer(
          borderRadius: 16,
          blur: 16,
          opacity: 0.05,
          tintColor: AppColors.colorError,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppColors.colorError.withOpacity(0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Log out',
                style: TextStyle(
                  color: AppColors.colorError.withOpacity(0.95),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: StringUtils.fontFamilyHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmLogoutDialog() {
    ConfirmationDialog.show(
      context: context,
      title: 'Log out?',
      message: 'Are you sure you want to log out of your account?',
      confirmText: 'Log out',
      isDestructive: true,
      icon: Icons.logout_rounded,
      onConfirm: () async {
        await PreferenceHelper.clear();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }
}
