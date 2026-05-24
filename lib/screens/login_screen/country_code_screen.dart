// import 'package:flutter/material.dart';
// import 'package:tapzy/core/constants/appColors.dart';
// import 'package:tapzy/core/constants/appConstants.dart';
// import 'package:tapzy/core/constants/stringUtils.dart';
// import 'package:tapzy/core/utils/appUtils.dart';
// import 'package:tapzy/core/common/commonBackground.dart';
// import 'package:tapzy/core/common/commonTextField.dart';
// import 'package:tapzy/core/constants/countryCodesConstants.dart';
//
// class CountryCodeScreen extends StatefulWidget {
//   Function? onCountrySelected;
//
//   CountryCodeScreen({Key? key, this.onCountrySelected}) : super(key: key);
//
//   @override
//   State<CountryCodeScreen> createState() => _CountryCodeScreenState();
// }
//
// class _CountryCodeScreenState extends State<CountryCodeScreen> {
//   var list;
//   String? searchValue;
//   final ValueNotifier<String> valueListenerSearch = ValueNotifier("");
//
//   TextEditingController searchController = TextEditingController();
//
//   Future<dynamic> _getData() async {
//     list = CountryCodes.countriesCodesList;
//     await Future.delayed(const Duration(seconds: 1));
//     return list;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = AppUtils.getMediaHeight(context);
//     final width = AppUtils.getMediaWidth(context);
//     return CommonBackGround(
//       body: Scaffold(
//         backgroundColor: Colors.white.withOpacity(0.03),
//         body: Column(
//           children: [
//             AppUtils.commonContainer(
//               margin: AppUtils.edgeInsetsOnly(
//                   left: AppConstants.ten,
//                   right: AppConstants.twenty,
//                   top: AppConstants.sixty,
//                   bottom: AppConstants.twenty),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back_ios,
//                       size: 20,
//                     ),
//                     color: Colors.white,
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   Expanded(
//                     child: AppUtils.commonContainer(
//                         height: AppConstants.fifty,
//                         child: CommonTextField(
//                           hintFontSize: AppConstants.twelve,
//                           hintText: 'Search',
//                           hintTextColor: AppColors.colorWhite,
//                           controller: searchController,
//                           onChanged: (value) {
//                             valueListenerSearch.value = value;
//                           },
//
//                           textInputType: TextInputType.text,
//                           // labelText: 'Search',
//                           inputTextFontSize: AppConstants.fourteen,
//                         )),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: AppUtils.commonContainer(
//                 height: height,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       AppUtils.commonContainer(
//                         margin: AppUtils.edgeInsetsOnly(left: AppConstants.ten),
//                         child: FutureBuilder<dynamic>(
//                           future: _getData(),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return AppUtils.commonContainer(
//                                   height: height / 1.35,
//                                   width: width,
//                                   child: Center(
//                                     child: AppUtils.loaderWidget(color: AppColors.colorPurpleLight),
//                                   ));
//                             }
//                             /* else if (snapshot.hasError) {
//                                     return Text('Error: ${snapshot.error}');
//                                   }*/
//                             else if (snapshot.data != null) {
//                               return ListView.builder(
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: snapshot.data.length,
//                                 shrinkWrap: true,
//                                 padding: EdgeInsets.zero,
//                                 itemBuilder: (BuildContext context, int index) {
//                                   return ValueListenableBuilder<String>(
//                                       valueListenable: valueListenerSearch,
//                                       builder: (context, value, child) {
//                                         return Visibility(
//                                           visible: snapshot.data[index]["name"].toString().toLowerCase() .contains(valueListenerSearch.value.toLowerCase()) ||
//                                               snapshot.data[index]["code"]
//                                                   .contains(valueListenerSearch
//                                                           .value ??
//                                                       ''),
//                                           child: InkWell(
//                                             onTap: () {
//                                               if (widget.onCountrySelected !=
//                                                   null) {
//                                                 widget.onCountrySelected!(
//                                                     snapshot.data[index]
//                                                         ["code"]);
//                                               }
//                                               Navigator.pop(context);
//                                             },
//                                             child: ListTile(
//                                               title: Row(
//                                                 children: [
//                                                   AppUtils.commonTextWidget(
//                                                       text: snapshot.data[index]
//                                                               ["code"] ??
//                                                           '',
//                                                       textColor: AppColors.colorPurple,
//                                                       fontFamily: StringUtils.fontFamilyHeading,
//
//                                                       fontSize: AppConstants
//                                                           .twelve),
//                                                   AppUtils.commonSizedBox(
//                                                       width: AppConstants.ten),
//                                                   Flexible(
//                                                     child: AppUtils
//                                                         .commonTextWidget(
//                                                       fontFamily: StringUtils.fontFamilyHeading,
//                                                             text: snapshot.data[
//                                                                         index]
//                                                                     ["name"] ??
//                                                                 '',
//                                                             textColor:
//                                                                 Colors.white,
//                                                             fontSize:
//                                                                 AppConstants
//                                                                     .thirteen),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       });
//                                 },
//                               );
//                             } else {
//                               return AppUtils.commonTextWidget(
//                                   text: 'Something went wrong');
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
