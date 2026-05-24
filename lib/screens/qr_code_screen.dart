// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:tapzy/core/common/commonBackground.dart';
// import 'package:tapzy/core/constants/appColors.dart';
// import 'package:tapzy/core/utils/appUtils.dart';
//
// class QrCodeScreen extends StatefulWidget {
//   String? imageUrl;
//
//   QrCodeScreen({Key? key, this.imageUrl}) : super(key: key);
//
//   @override
//   State<QrCodeScreen> createState() => _QrCodeScreenState();
// }
//
// class _QrCodeScreenState extends State<QrCodeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     print("gggggggggggjjgjjg ${widget.imageUrl}");
//     return CommonBackGround(
//       body: Scaffold(
//         appBar: AppBar(
//             actions: [
//               IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: Icon(
//                     Icons.close,
//                     size: 25,
//                   ))
//             ],
//             elevation: 0,
//             shadowColor: Colors.transparent,
//             backgroundColor: Colors.transparent,
//             centerTitle: true,
//             automaticallyImplyLeading: false,
//             title: Image.asset(
//               "assets/images/ic_tran_name_white.png",
//               height: 70,
//             )),
//         backgroundColor: AppColors.colorTransparent,
//         body: Center(
//           child: AppUtils.commonContainer(
//             decoration: AppUtils.commonBoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     AppColors.colorPurple.withOpacity(0.5),
//                     AppColors.colorPurpleLight.withOpacity(0.4),
//                     AppColors.colorBlueAccent.withOpacity(0.2),
//                   ]),
//             ),
//             // child: widget.imageUrl == null
//             //     ? AppUtils.commonTextWidget(
//             //         text: "Something went wrong",
//             //         margin: AppUtils.edgeInsetsOnly(
//             //             left: 10, right: 10, top: 10, bottom: 10))
//             //     : ClipRRect(
//             //   borderRadius: BorderRadius.circular(12),
//             //       child: CachedNetworkImage(
//             //           height: 200,
//             //           width: 200,
//             //           imageUrl: widget.imageUrl ?? '',
//             //           imageBuilder: (context, imageProvider) => Container(
//             //             decoration: BoxDecoration(
//             //               image: DecorationImage(
//             //                   image: imageProvider, fit: BoxFit.cover),
//             //             ),
//             //           ),
//             //           placeholder: (context, url) => Center(
//             //               child: CircularProgressIndicator(
//             //             color: AppColors.colorPurple,
//             //             strokeWidth: 1.5,
//             //           )),
//             //           errorWidget: (context, url, error) => Icon(Icons.error),
//             //         ),
//             //     ),
//             child: QrImageView(
//               data: widget.imageUrl ?? '',
//               eyeStyle: QrEyeStyle(
//                   eyeShape: QrEyeShape.square,
//                   color: AppColors.colorWhite.withOpacity(0.8)),
//               dataModuleStyle: QrDataModuleStyle(
//                   dataModuleShape: QrDataModuleShape.square,
//                   color: AppColors.colorWhite.withOpacity(0.8)),
//               backgroundColor: AppColors.colorTransparent,
//               version: QrVersions.auto,
//               size: 200.0,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
