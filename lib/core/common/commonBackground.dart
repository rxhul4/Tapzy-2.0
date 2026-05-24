import 'package:flutter/material.dart';
import 'package:tapzy/core/constants/appColors.dart';

class CommonBackGround extends StatelessWidget {
  final Widget? body;
  const CommonBackGround({Key? key, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF120A1C),
              Color(0xFF0D0A14),
              Color(0xFF0A0A0F),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: body,
      ),
    );
  }
}
