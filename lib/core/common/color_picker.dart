import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/stringUtils.dart';

class AppColorPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const AppColorPicker({
    Key? key,
    required this.initialColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  State<AppColorPicker> createState() => _AppColorPickerState();
}

class _AppColorPickerState extends State<AppColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: GlassContainer(
            borderRadius: 24,
            blur: 22,
            opacity: 0.08,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pick a color',
                  style: TextStyle(
                    color: AppColors.colorOffWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringUtils.fontFamilyHeading,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  child: Theme(
                    data: ThemeData.dark().copyWith(
                      inputDecorationTheme: InputDecorationTheme(
                        labelStyle:
                            const TextStyle(color: AppColors.colorOffWhite),
                        hintStyle: TextStyle(
                          color: AppColors.colorTextMuted,
                        ),
                      ),
                    ),
                    child: ColorPicker(
                      pickerColor: _currentColor,
                      onColorChanged: (color) =>
                          setState(() => _currentColor = color),
                      enableAlpha: true,
                      displayThumbColor: true,
                      hexInputBar: true,
                      pickerAreaHeightPercent: 0.65,
                      labelTypes: const [],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.colorTextMuted,
                            fontFamily: StringUtils.fontFamilyHeading,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colorPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          widget.onColorChanged(_currentColor);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Select',
                          style: TextStyle(
                            fontFamily: StringUtils.fontFamilyHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
