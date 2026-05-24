import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/capitlize_string.dart';
import 'package:tapzy/core/common/custom_upgrader_message.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/common/glass_ui.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/core/common/commonBackground.dart';
import 'package:tapzy/models/login_model.dart';
import 'package:tapzy/providers/login_provider.dart';
import 'package:tapzy/screens/login_screen/otp_verification_screen.dart';
import 'package:upgrader/upgrader.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  LoginModel? loginModel;
  String errorText = '';
  final TextEditingController _emailCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _callLoginApi(LoginProvider provider) {
    provider.callLoginApi(_emailCtrl.text).then((value) {
      loginModel = value;
      if (loginModel?.isSuccessful == 1 && loginModel?.data != null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              isNew: loginModel?.data?.isNew ?? 1,
              email: _emailCtrl.text,
            )));
      } else {
        AppUtils.showSnackBarWithColor(
            context: context,
            message: loginModel?.message ?? '',
            giveColor: Colors.redAccent);
      }
    });
  }

  void _submit(LoginProvider provider) {
    setState(() => errorText = '');
    if (_emailCtrl.text.isEmpty) {
      setState(() => errorText = 'Enter your email address');
    } else if (!StringCasingExtension.validateEmail(_emailCtrl.text)) {
      setState(() => errorText = 'Enter a valid email address');
    } else {
      focusNode.unfocus();
      _callLoginApi(provider);
    }
  }

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();
    final size = MediaQuery.of(context).size;

    final content = Stack(
      children: [
        const GlassAmbientOrb(
          size: 220,
          alignment: Alignment(-0.9, -0.85),
          opacity: 0.16,
        ),
        const GlassAmbientOrb(
          size: 180,
          alignment: Alignment(1.05, 0.3),
          opacity: 0.1,
        ),
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.05),
                              GlassContainer(
                                borderRadius: 999,
                                blur: 20,
                                opacity: 0.08,
                                width: 140,
                                height: 140,
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/images/ic_tran_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Welcome to Tapzy',
                                style: TextStyle(
                                  color: AppColors.colorOffWhite,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: StringUtils.fontFamilyHeading,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sign in or create your account',
                                style: TextStyle(
                                  color: AppColors.colorTextMuted,
                                  fontSize: 13,
                                  fontFamily: StringUtils.fontFamilyPara,
                                ),
                              ),
                              SizedBox(height: size.height * 0.05),
                              GlassContainer(
                                borderRadius: 28,
                                blur: 26,
                                opacity: 0.07,
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    GlassUi.fieldLabel('Email Address'),
                                    const SizedBox(height: 8),
                                    GlassUi.textField(
                                      controller: _emailCtrl,
                                      focusNode: focusNode,
                                      hintText: 'you@example.com',
                                      prefixIcon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      hasError: errorText.isNotEmpty,
                                      onChanged: (_) {
                                        if (errorText.isNotEmpty) {
                                          setState(() => errorText = '');
                                        }
                                      },
                                    ),
                                    if (errorText.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      GlassUi.errorText(errorText),
                                    ],
                                    const SizedBox(height: 28),
                                    Text(
                                      'Take your interactions to the next level with NFC-powered digital business cards',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.colorTextSubtle,
                                        fontSize: 11,
                                        height: 1.5,
                                        fontFamily: StringUtils.fontFamilyPara,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              GlassUi.primaryButton(
                                label: 'Continue with OTP',
                                isLoading: provider.isFetching,
                                onTap: () => _submit(provider),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );

    return CommonBackGround(
      body: Scaffold(
        backgroundColor: Colors.transparent,
        body: kDebugMode
            ? content
            : UpgradeAlert(
          upgrader: Upgrader(messages: CustomUpgraderMessage()),
          child: content,
        ),
      ),
    );
  }
}
