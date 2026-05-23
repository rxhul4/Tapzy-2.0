import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/screens/dashboard_screens/dashboard_screen.dart';
import 'package:tapzy/screens/login_screen/login_screen.dart';
import 'package:tapzy/screens/login_screen/user_detail_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main stagger controller
  late AnimationController _staggerCtrl;
  // Ring pulse controller (loops)
  late AnimationController _ringCtrl;
  // Particle drift controller (loops)
  late AnimationController _particleCtrl;
  // Shimmer sweep controller (loops)
  late AnimationController _shimmerCtrl;

  // Staggered animations
  late Animation<double> _bgReveal;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _bottomFade;

  // Continuous animations
  late Animation<double> _ringPulse;
  late Animation<double> _shimmerValue;

  // Particle data
  final List<_Particle> _particles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();

    // Generate particles
    for (int i = 0; i < 35; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 3 + 1,
        speed: _rng.nextDouble() * 0.3 + 0.1,
        opacity: _rng.nextDouble() * 0.4 + 0.05,
        phase: _rng.nextDouble() * 2 * pi,
      ));
    }

    // Main stagger — 2 seconds total
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Ring pulse loop
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Particle drift loop
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    // Shimmer sweep loop
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // --- Staggered sequence ---
    // 0.0→0.3: background gradient reveal
    _bgReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );

    // 0.1→0.45: ring scale in
    _ringScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.1, 0.45, curve: Curves.elasticOut)),
    );
    _ringOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.1, 0.35, curve: Curves.easeOut)),
    );

    // 0.25→0.55: logo fade + scale
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.25, 0.55, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.25, 0.55, curve: Curves.easeOutBack)),
    );

    // 0.45→0.7: brand text
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.45, 0.7, curve: Curves.easeOut)),
    );
    _textSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.45, 0.7, curve: Curves.easeOutCubic)),
    );

    // 0.6→0.85: tagline
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.6, 0.85, curve: Curves.easeOut)),
    );

    // 0.7→1.0: bottom bar
    _bottomFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    // Continuous
    _ringPulse = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut),
    );
    _shimmerValue = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    _staggerCtrl.forward();
    Timer(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    final isNew = PreferenceHelper.getBool(PreferenceHelper.IS_NEW);
    Widget dest;
    if (userId == null) {
      dest = const LoginScreen();
    } else if (isNew == false) {
      dest = DashboardScreen();
    } else {
      dest = UserDetailScreen();
    }
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => dest,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
      (r) => false,
    );
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _ringCtrl.dispose();
    _particleCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.colorMainBlack,
      body: AnimatedBuilder(
        animation: Listenable.merge([_staggerCtrl, _ringCtrl, _particleCtrl, _shimmerCtrl]),
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF000000), const Color(0xFF0A0A0F), _bgReveal.value)!,
                  Color.lerp(const Color(0xFF000000), const Color(0xFF120A1C), _bgReveal.value)!,
                  Color.lerp(const Color(0xFF000000), const Color(0xFF1A0A2E), _bgReveal.value)!,
                  Color.lerp(const Color(0xFF000000), const Color(0xFF0D0A14), _bgReveal.value)!,
                ],
                stops: const [0.0, 0.35, 0.65, 1.0],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Floating particles
                CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleCtrl.value,
                    globalOpacity: _bgReveal.value,
                  ),
                ),

                // Large ambient orb top-left
                Positioned(
                  top: -size.width * 0.3,
                  left: -size.width * 0.2,
                  child: Opacity(
                    opacity: _bgReveal.value * 0.8,
                    child: Container(
                      width: size.width * 0.8,
                      height: size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.colorPurple.withOpacity(0.2),
                          AppColors.colorPurpleLight.withOpacity(0.05),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),

                // Orb bottom-right
                Positioned(
                  bottom: -size.width * 0.25,
                  right: -size.width * 0.15,
                  child: Opacity(
                    opacity: _bgReveal.value * 0.6,
                    child: Container(
                      width: size.width * 0.65,
                      height: size.width * 0.65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.colorPurpleLight.withOpacity(0.15),
                          AppColors.colorPurple.withOpacity(0.04),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),

                // Center content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing ring + logo
                      Transform.scale(
                        scale: _ringPulse.value,
                        child: Opacity(
                          opacity: _ringOpacity.value,
                          child: Transform.scale(
                            scale: _ringScale.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.colorPurple.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.colorPurple.withOpacity(0.25),
                                        blurRadius: 40,
                                        spreadRadius: 8,
                                      ),
                                      BoxShadow(
                                        color: AppColors.colorPurpleLight.withOpacity(0.12),
                                        blurRadius: 60,
                                        spreadRadius: 16,
                                      ),
                                    ],
                                  ),
                                ),

                                // Inner glassmorphic circle
                                ClipOval(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                    child: Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.12),
                                            AppColors.colorPurple.withOpacity(0.15),
                                            Colors.white.withOpacity(0.06),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                      // Logo inside
                                      child: Opacity(
                                        opacity: _logoFade.value,
                                        child: Transform.scale(
                                          scale: _logoScale.value,
                                          child: Padding(
                                            padding: const EdgeInsets.all(30),
                                            child: Image.asset(
                                              'assets/images/ic_tran_logo.png',
                                              fit: BoxFit.contain,
                                              color: Colors.white.withOpacity(0.95),
                                              colorBlendMode: BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Shimmer sweep over the ring
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: CustomPaint(
                                    painter: _RingShimmerPainter(
                                      progress: _shimmerValue.value,
                                      color: AppColors.colorPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Horizontal logo
                      Opacity(
                        opacity: _textFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: SizedBox(
                            width: 200,
                            child: Image.asset(
                              'assets/images/ic_tran_main_white.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Gradient divider line
                      Opacity(
                        opacity: _textFade.value,
                        child: Container(
                          width: 60,
                          height: 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: AppColors.gradientPurple,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.colorPurple.withOpacity(0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tagline
                      Opacity(
                        opacity: _taglineFade.value,
                        child: Text(
                          'DIGITAL BUSINESS CARDS',
                          style: TextStyle(
                            color: AppColors.colorTextMuted,
                            fontSize: 11,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w600,
                            fontFamily: StringUtils.fontFamilyHeading,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom section — loading bar + powered by
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: 52,
                  child: Opacity(
                    opacity: _bottomFade.value,
                    child: Column(
                      children: [
                        // Animated progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 3,
                            child: LinearProgressIndicator(
                              value: _staggerCtrl.value,
                              backgroundColor: Colors.white.withOpacity(0.06),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.colorPurple.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Powered by NFC Technology',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.colorTextSubtle,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontFamily: StringUtils.fontFamilyPara,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- Particle System ---

class _Particle {
  final double x;      // Normalized 0-1
  final double y;      // Normalized 0-1
  final double size;
  final double speed;
  final double opacity;
  final double phase;   // Random offset for sine wave

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final double globalOpacity;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.globalOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx = p.x * size.width + sin(progress * 2 * pi + p.phase) * 20;
      final dy = (p.y * size.height - progress * p.speed * size.height * 0.6) % size.height;
      final paint = Paint()
        ..color = AppColors.colorPurple.withOpacity(p.opacity * globalOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

// --- Ring Shimmer ---

class _RingShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0 || progress > 1) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angle = progress * 2 * pi;
    final shinePos = Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: shinePos, radius: 16));
    canvas.drawCircle(shinePos, 16, paint);
  }

  @override
  bool shouldRepaint(covariant _RingShimmerPainter old) => true;
}
