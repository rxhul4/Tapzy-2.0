import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/utils/appUtils.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({Key? key}) : super(key: key);

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isPermissionDenied = false;
  FlashMode _flashMode = FlashMode.off;
  bool _isCapturing = false;
  bool _isVertical = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before camera was initialized or was disposed
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Check camera permission first
      var status = await Permission.camera.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.camera.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          setState(() => _isPermissionDenied = true);
          return;
        }
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _isPermissionDenied = true);
        return;
      }

      // Pick first rear camera
      CameraDescription? rearCam;
      for (var cam in _cameras) {
        if (cam.lensDirection == CameraLensDirection.back) {
          rearCam = cam;
          break;
        }
      }
      rearCam ??= _cameras.first;

      final controller = CameraController(
        rearCam,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _controller = controller;

      await controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPermissionDenied = false;
        });
      }
    } on CameraException catch (e) {
      print("CameraException: $e");
      if (e.code == 'CameraAccessDenied') {
        if (mounted) {
          setState(() => _isPermissionDenied = true);
        }
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    try {
      if (_flashMode == FlashMode.off) {
        await _controller!.setFlashMode(FlashMode.torch);
        setState(() => _flashMode = FlashMode.torch);
      } else {
        await _controller!.setFlashMode(FlashMode.off);
        setState(() => _flashMode = FlashMode.off);
      }
    } catch (e) {
      print("Error setting flash mode: $e");
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      // Ensure flash/torch stays set if configured
      if (_flashMode == FlashMode.torch) {
        await _controller!.setFlashMode(FlashMode.torch);
      }

      final XFile file = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      print("Error taking picture: $e");
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to capture photo. Please try again.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPermissionDenied) {
      return SafeArea(
        child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.colorPurple.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.colorPurple, size: 52),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Camera Access Required',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tapzy needs permission to use your camera so you can capture and scan physical business cards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => openAppSettings(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPurple,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Open Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AppUtils.loaderWidget(color: AppColors.colorPurple, size: 40),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final double targetWidth = _isVertical ? size.width * 0.62 : size.width * 0.85;
    final double targetHeight = _isVertical ? targetWidth * 1.58 : targetWidth / 1.58;

    return TweenAnimationBuilder<Size>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      tween: Tween<Size>(
        begin: Size(targetWidth, targetHeight),
        end: Size(targetWidth, targetHeight),
      ),
      builder: (context, animSize, child) {
        final double cardWidth = animSize.width;
        final double cardHeight = animSize.height;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── Camera Preview ──
              ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: size.width,
                      height: size.width * _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
              ),

              // ── Custom Paint Dark Overlay with a Hole Cutout ──
              CustomPaint(
                size: Size.infinite,
                painter: CardCutoutPainter(
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              ),

              // ── Glowing Border around the Hole ──
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.colorPurple,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorPurple.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Guideline Instruction Label ──
              Positioned(
                top: size.height * 0.5 - (cardHeight / 2) - 44,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'Align business card within frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Actions Overlay (Top Action Bar & Bottom Shutter Bar) ──
              SafeArea(
                child: Column(
                  children: [
                    // Top Action Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Close Button
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          // Right Action Buttons
                          Row(
                            children: [
                              // Orientation Switcher Toggle
                              IconButton(
                                icon: Icon(
                                  _isVertical
                                      ? Icons.crop_landscape_rounded
                                      : Icons.crop_portrait_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isVertical = !_isVertical;
                                  });
                                },
                                tooltip: _isVertical
                                    ? 'Switch to Horizontal'
                                    : 'Switch to Vertical',
                              ),
                              const SizedBox(width: 8),
                              // Flash Toggle Button
                              IconButton(
                                icon: Icon(
                                  _flashMode == FlashMode.torch
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                                  color: _flashMode == FlashMode.torch
                                      ? Colors.yellowAccent
                                      : Colors.white,
                                  size: 26,
                                ),
                                onPressed: _toggleFlash,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Bottom Shutter Bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _takePicture,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: _isCapturing
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.colorPurple,
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorPurple),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardCutoutPainter extends CustomPainter {
  final double cardWidth;
  final double cardHeight;

  const CardCutoutPainter({
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: cardWidth,
        height: cardHeight,
      ),
      const Radius.circular(16),
    );

    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cutoutRect);

    final path = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(path, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CardCutoutPainter oldDelegate) {
    return oldDelegate.cardWidth != cardWidth || oldDelegate.cardHeight != cardHeight;
  }
}
