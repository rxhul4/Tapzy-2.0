import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';

class ImageCropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final double aspectRatio;
  final String title;

  const ImageCropScreen({
    Key? key,
    required this.imageBytes,
    required this.aspectRatio,
    this.title = "Crop Image",
  }) : super(key: key);

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final _cropController = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorMainBlack,
      appBar: AppBar(
        backgroundColor: AppColors.colorCardDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppUtils.commonTextWidget(
          text: widget.title,
          fontWeight: FontWeight.w700,
          fontFamily: StringUtils.fontFamilyHeading,
          fontSize: 15,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Crop(
                    image: widget.imageBytes,
                    controller: _cropController,
                    onCropped: (croppedData) {
                      setState(() {
                        _isCropping = false;
                      });
                      Navigator.pop(context, croppedData);
                    },
                    aspectRatio: widget.aspectRatio,
                    withAreaScale: true,
                    initialAreaScale: 0.9,
                    baseColor: Colors.black.withOpacity(0.8),
                    maskColor: Colors.black.withOpacity(0.5),
                    cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: AppColors.colorPurple),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.colorCardDark,
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: AppUtils.commonTextWidget(
                          text: "Cancel",
                          textColor: AppColors.colorOffWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPurple,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.colorPurple.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isCropping
                              ? null
                              : () {
                                  setState(() {
                                    _isCropping = true;
                                  });
                                  _cropController.crop();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCropping
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : AppUtils.commonTextWidget(
                                  text: "Crop & Save",
                                  textColor: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isCropping)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: AppUtils.loaderWidget(color: AppColors.colorPurpleLight),
            ),
        ],
      ),
    );
  }
}
