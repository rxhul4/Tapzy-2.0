import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/common/commonBackground.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/common/glass_ui.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/models/login_model.dart';
import 'package:tapzy/models/otp_verify_model.dart';
import 'package:tapzy/providers/login_provider.dart';
import 'package:tapzy/screens/dashboard_screens/dashboard_screen.dart';
import 'package:tapzy/screens/login_screen/user_detail_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final int isNew;

  const OtpVerificationScreen({
    Key? key,
    required this.email,
    required this.isNew,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  String? otpValue;
  String errorText = '';

  OtpVerifyModel? otpVerifyModel;
  LoginModel? loginModel;

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOutCubic,
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _callLoginApi(LoginProvider provider) async {
    final value = await provider.callLoginApi(widget.email);

    loginModel = value;

    if (!mounted) return;

    if (loginModel?.isSuccessful == 1) {
      AppUtils.showSnackBarWithColor(
        context: context,
        message: 'OTP sent successfully',
      );
    } else {
      AppUtils.showSnackBarWithColor(
        context: context,
        message: loginModel?.message ?? '',
        giveColor: Colors.redAccent,
      );
    }
  }

  Future<void> _callOtpVerifyApi(LoginProvider provider) async {
    final value = await provider.callOtpVerifyApi(
      otpValue ?? '',
      widget.email,
    );

    otpVerifyModel = value;

    if (!mounted) return;

    if (otpVerifyModel?.isSuccessful == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => widget.isNew == 1
              ? UserDetailScreen()
              : DashboardScreen(),
        ),
            (r) => false,
      );
    } else {
      AppUtils.showSnackBarWithColor(
        context: context,
        message: otpVerifyModel?.message ?? '',
        giveColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();
    final size = MediaQuery.of(context).size;

    return CommonBackGround(
      body: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const GlassAmbientOrb(
              size: 200,
              alignment: Alignment(0.95, -0.8),
              opacity: 0.14,
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 12, bottom: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GlassUi.backButton(
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                        ),

                        GlassContainer(
                          borderRadius: 999,
                          blur: 18,
                          opacity: 0.08,
                          width: 72,
                          height: 72,
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.colorPurple,
                            size: 32,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Verify Your Email',
                          style: TextStyle(
                            color: AppColors.colorOffWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily:
                            StringUtils.fontFamilyHeading,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Enter the 4-digit code sent to',
                          style: TextStyle(
                            color: AppColors.colorTextMuted,
                            fontSize: 13,
                            fontFamily: StringUtils.fontFamilyPara,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.email,
                          style: TextStyle(
                            color: AppColors.colorPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily:
                            StringUtils.fontFamilyHeading,
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        GlassContainer(
                          borderRadius: 24,
                          blur: 20,
                          opacity: 0.06,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 24,
                          ),
                          child: MaterialPinField(
                            length: 4,
                            mainAxisSize: MainAxisSize.max,
                            keyboardType: TextInputType.number,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            enableAutofill: true,
                            autofillHints: const [
                              AutofillHints.oneTimeCode,
                            ],
                            theme: MaterialPinTheme(
                              shape: MaterialPinShape.outlined,
                              cellSize: const Size(56, 56),
                              borderRadius:
                              BorderRadius.circular(14),
                              borderWidth: 1,
                              focusedBorderWidth: 1.5,
                              borderColor:
                              Colors.white.withOpacity(0.12),
                              focusedBorderColor:
                              AppColors.colorPurple,
                              filledBorderColor:
                              AppColors.colorPurple,
                              fillColor:
                              Colors.white.withOpacity(0.04),
                              focusedFillColor:
                              AppColors.colorPurple
                                  .withOpacity(0.18),
                              filledFillColor:
                              AppColors.colorPurple
                                  .withOpacity(0.12),
                              cursorColor:
                              AppColors.colorPurple,
                              cursorWidth: 1.5,
                              entryAnimation:
                              MaterialPinAnimation.scale,
                              textStyle: const TextStyle(
                                color: AppColors.colorWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            onChanged: (v) {
                              setState(() {
                                otpValue = v;

                                if (v.isNotEmpty) {
                                  errorText = '';
                                }
                              });
                            },
                            onCompleted: (_) {
                              _callOtpVerifyApi(provider);
                            },
                          ),
                        ),

                        if (errorText.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          GlassUi.errorText(errorText),
                        ],

                        const Spacer(),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code? ",
                              style: TextStyle(
                                color:
                                AppColors.colorTextMuted,
                                fontSize: 12,
                                fontFamily:
                                StringUtils.fontFamilyPara,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _callLoginApi(provider),
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  color:
                                  AppColors.colorPurple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: StringUtils
                                      .fontFamilyHeading,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        GlassUi.primaryButton(
                          label: 'Verify OTP',
                          isLoading: provider.isFetching ||
                              provider.isLoading,
                          onTap: () {
                            if ((otpValue?.length ?? 0) == 4) {
                              _callOtpVerifyApi(provider);
                            } else {
                              setState(() {
                                errorText =
                                'Please enter the complete OTP';
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}