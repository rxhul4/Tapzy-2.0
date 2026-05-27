import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tapzy/core/common/add_card_dialog.dart';
import 'package:tapzy/core/common/commonDialog.dart';
import 'package:tapzy/core/common/glass_container.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/appConstants.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/core/utils/confirmation_dialog.dart';
import 'package:tapzy/models/disable_enable_card_model.dart';
import 'package:tapzy/models/get_digital_card_model.dart';
import 'package:tapzy/models/link_card_model.dart';
import 'package:tapzy/providers/dashboard_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/preference_helper.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({Key? key}) : super(key: key);

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  DisableEnableCardModel? disableEnableCardModel;
  GetDigitalCardModel? getDigitalCardModel;
  LinkCardModel? linkCardModel;

  Map<int, String>? disableCardLabelAndIdMap = {};

  ValueNotifier<String> cardIdNoti = ValueNotifier<String>('');
  ValueNotifier<bool> showNoData = ValueNotifier<bool>(false);

  final PageController _pageController = PageController(viewportFraction: 0.95);

  List colors = [
    Colors.redAccent.withOpacity(0.5),
    Colors.blueAccent.withOpacity(0.5),
    Colors.greenAccent.withOpacity(0.5),
    Colors.cyanAccent.withOpacity(0.5),
  ];

  List icons = [
    Icons.work,
    Icons.person,
    Icons.perm_media,
    Icons.facebook,
    Icons.youtube_searched_for,
    Icons.linked_camera
  ];
  List iconNames = [
    "Business",
    "Personal",
    "Instagram",
    "Facebook",
    "Youtube",
    "Linkedin"
  ];

  int _currentIndex = 0;

  // var isActiveCardList;
  // List<CardData>? isDisableCardList;
  void fillDisableCardLabelAndIdMap(String? label, int? cardId) {
    print("call");
    if (label != null && cardId != null) {
      print('++++ disableCardLabelAndIdMap $disableCardLabelAndIdMap');
      disableCardLabelAndIdMap?[cardId] = label;
      print('++++ disableCardLabelAndIdMap $disableCardLabelAndIdMap');
    }
  }

  getDigitalCard(postMdl) {
    postMdl.callGetDigitalCardsApi().then((value) {
      print("ddddddd $value");
      getDigitalCardModel = value;
      if (getDigitalCardModel?.isSuccessful == 1) {
        print("lllllllllll");
        disableCardLabelAndIdMap?.clear();
        for (int i = 0;
            i <
                (getDigitalCardModel?.data?.cardData
                        ?.where((element) => element.isActive == 0)
                        .length ??
                    0);
            i++) {
          print("kkkkkkkkk");
          fillDisableCardLabelAndIdMap(
              getDigitalCardModel?.data?.cardData
                  ?.where((element) => element.isActive == 0)
                  .toList()[i]
                  .cardLabel,
              getDigitalCardModel?.data?.cardData
                  ?.where((element) => element.isActive == 0)
                  .toList()[i]
                  .id);
        }
        // isActiveCardList = getDigitallCardModel?.data?.cardData?.where((element) => element.isActive == 1);
        // isDisableCardList?.addAll(getDigitalCardModel?.data?.cardData?.where((element) => element.isActive == 0) ?? []);
        // print("dataaaaaaaaaaa ${isDisableCardList}");
        showNoData.value = false;
      } else {
        showNoData.value = true;
      }
      print("Cards are here ${getDigitalCardModel?.toJson()}");
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postMdl = Provider.of<DashboardProvider>(context, listen: false);
      getDigitalCard(postMdl);
      // _pageController.addListener(() {
      //   setState(() {
      //     print("fffffff");
      //     _currentIndex = _pageController.page?.round() ?? 0;
      //   });
      // });
      addListenerToPageController();
    });
  }

  addListenerToPageController() {
    _pageController.addListener(() {
      final nextPage = _pageController.page?.round() ?? 0;
      if (_currentIndex != nextPage) {
        setState(() {
          _currentIndex = nextPage;
        });
      }
    });
  }

  Future<void> _updateActiveNfcUrl(int index) async {
    try {
      final cardList = getDigitalCardModel?.data?.cardData
              ?.where((element) => element.isActive == 1)
              .toList() ??
          [];
      if (cardList.isNotEmpty && index < cardList.length) {
        final cardUrl = cardList[index].qrImage ?? '';
        if (cardUrl.isNotEmpty) {
          await PreferenceHelper.load();
          await PreferenceHelper.setString("active_nfc_url", cardUrl);
          print("Saved active NFC URL to preferences: $cardUrl");
        }
      }
    } catch (e) {
      print("Error saving active NFC URL: $e");
    }
  }

  callDisableEnableApi({
    bool? isDisable,
    DashboardProvider? postMdl1,
    required BuildContext ctx,
    String? cardId,
    String? cardType,
  }) async {
    // if (isDisable ?? true) {
    postMdl1?.callDisableEnableApi(cardId ?? '', cardType ?? '').then((value) {
      disableEnableCardModel = value;
      print("print ${disableEnableCardModel?.toJson()}");
      if (disableEnableCardModel?.isSuccessful == 1) {
        AppUtils.showSnackBarWithColor(
            context: ctx, message: disableEnableCardModel?.message ?? '');
        getDigitalCard(postMdl1);
        setState(() {
          _currentIndex = 0;
        });
      } else {
        AppUtils.showSnackBarWithColor(
            context: ctx,
            message: disableEnableCardModel?.message ?? '',
            giveColor: Colors.redAccent);
      }
    });
    // }
  }

  callLinkCardApi({
    String? cardNo,
    String? cardType,
    String? cardLink,
    String? profileID,
    DashboardProvider? postMdl1,
  }) async {
    // if (isDisable ?? true) {
    postMdl1
        ?.callLinkQrPhysicalCardApi(
            cardNo ?? '', cardType ?? '', cardLink ?? '', profileID ?? '')
        .then((value) {
      linkCardModel = value;
      print("print ${linkCardModel?.toJson()}");
      if (linkCardModel?.isSuccessful == 1) {
        AppUtils.showSnackBarWithColor(
            context: context, message: linkCardModel?.message ?? '');
      } else {
        AppUtils.showSnackBarWithColor(
            context: context,
            message: linkCardModel?.message ?? '',
            giveColor: Colors.redAccent);
      }
    });
    // }
  }

  Future<void> scanQRCode(
      {String? cardType,
      DashboardProvider? postMdl1,
      String? profileID}) async {
    var status1 = await Permission.camera.request();
    if (status1.isDenied || status1.isPermanentlyDenied) {
      AppUtils.openAppSettingsPermissionDialog(
          ctxx: context,
          msg:
              "To access your camera, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Camera' and enable access for our app");
    } else {
      try {
        final String? barcodeScanRes = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => _QRScannerScreen()),
        );

        if (barcodeScanRes != null && barcodeScanRes.isNotEmpty) {
          print("result : $barcodeScanRes");
          if (!barcodeScanRes.contains('/business/')) {
            AppUtils.showSnackBarWithColor(
              context: context,
              message: 'Invalid QR Code. Please scan a valid Tapzy card QR.',
              giveColor: Colors.redAccent,
            );
            return;
          }
          var cleanedRes = barcodeScanRes.trim();
          if (cleanedRes.endsWith('/')) {
            cleanedRes = cleanedRes.substring(0, cleanedRes.length - 1);
          }
          var uId = cleanedRes.split('/').last;
          print("result : ${uId}");
          callLinkCardApi(
              cardType: cardType,
              postMdl1: postMdl1,
              cardLink: cleanedRes,
              cardNo: uId,
              profileID: profileID);
        }
      } catch (e) {
        print('Error scanning QR code: $e');
      }
    }
  }

  void _onShare(BuildContext context, String? text, String? link,
      {bool onlyAirDrop = false}) async {
    final box = context.findRenderObject() as RenderBox?;
    if (onlyAirDrop) {
      final uri = link != null ? Uri.tryParse(link) : null;
      final bool hasScheme = uri?.hasScheme ?? false;
      await SharePlus.instance.share(
        ShareParams(
          uri: hasScheme ? uri : null,
          text: hasScheme ? null : (link ?? ''),
          title: text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          excludedCupertinoActivities: [
            CupertinoActivityType.postToFacebook,
            CupertinoActivityType.postToTwitter,
            CupertinoActivityType.postToWeibo,
            CupertinoActivityType.message,
            CupertinoActivityType.mail,
            CupertinoActivityType.print,
            CupertinoActivityType.copyToPasteboard,
            CupertinoActivityType.assignToContact,
            CupertinoActivityType.saveToCameraRoll,
            CupertinoActivityType.addToReadingList,
            CupertinoActivityType.postToFlickr,
            CupertinoActivityType.postToVimeo,
            CupertinoActivityType.postToTencentWeibo,
            CupertinoActivityType.openInIBooks,
            CupertinoActivityType.markupAsPDF,
            CupertinoActivityType.sharePlay,
            CupertinoActivityType.collaborationInviteWithLink,
            CupertinoActivityType.collaborationCopyLink,
            CupertinoActivityType.addToHomeScreen,
          ],
        ),
      );
    } else {
      await SharePlus.instance.share(
        ShareParams(
          text: link ?? '',
          subject: text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    }
  }

  ValueNotifier<dynamic> result = ValueNotifier(null);
  ValueNotifier<String> nfcWritingString = ValueNotifier("Write to NFC");

  void _tagRead() {
    print("read");
    NfcManager.instance.startSession(
      pollingOptions: {},
      onDiscovered: (NfcTag tag) async {
        result.value = tag.data;
        print("read : ${result.value}");
        await NfcManager.instance.stopSession();
      },
    );
  }

  void _ndefWrite(String url, ctxSheet, ctxBuild) {
    if (url.isEmpty) {
      AppUtils.showSnackBarWithColor(
          context: ctxBuild,
          message: "URL is empty",
          giveColor: Colors.redAccent);
      return;
    }

    nfcWritingString.value = "Scanning NFC tag...";

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          nfcWritingString.value = "NFC Write Failed";
          AppUtils.showSnackBarWithColor(
              context: ctxBuild,
              message: "Tag is not NDEF writable",
              giveColor: Colors.redAccent);
          NfcManager.instance.stopSession(errorMessage: "Tag not writable");
          return;
        }

        NdefMessage message = NdefMessage([
          NdefRecord.createUri(Uri.parse(url)),
        ]);

        try {
          await ndef.write(message);
          nfcWritingString.value = "Write Successful!";
          AppUtils.showSnackBarWithColor(
              context: ctxBuild,
              message: "Write successful!",
              giveColor: AppColors.colorSuccess);
          NfcManager.instance.stopSession();
          if (Navigator.canPop(ctxSheet)) {
            Navigator.pop(ctxSheet);
          }
        } catch (e) {
          nfcWritingString.value = "NFC Write Failed";
          AppUtils.showSnackBarWithColor(
              context: ctxBuild,
              message: "Failed to write to NFC: $e",
              giveColor: Colors.redAccent);
          NfcManager.instance.stopSession(errorMessage: "Write failed");
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    NfcManager.instance.stopSession();
  }

  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<DashboardProvider>(context);
    final width = AppUtils.getMediaWidth(context);
    return postMdl.isLoading || postMdl.isFetching
        ? AppUtils.loaderWidget()
        : showNoData.value
            ? AppUtils.noDataFound()
            : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      getDigitalCard(postMdl);
                    },
                    color: AppColors.colorPurple,
                    backgroundColor: AppColors.colorSurface,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        _buildWelcomeHeader(postMdl),
                        _buildSectionTitle('My Cards'),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 268,
                            width: width,
                            child: PageView.builder(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              controller: _pageController,
                              itemCount: (getDigitalCardModel?.data?.cardData
                                              ?.where((element) =>
                                                  element.isActive == 1)
                                              .toList()
                                              .length ??
                                          0) <=
                                      0
                                  ? 1
                                  : getDigitalCardModel?.data?.cardData
                                      ?.where(
                                          (element) => element.isActive == 1)
                                      .length,
                              itemBuilder: (ctx, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(right: 10, left: 4),
                                  child: GlassContainer(
                                    hideBoxShadow: true,
                                    borderRadius: 20,
                                    blur: 18,
                                    opacity: 0.04,
                                    padding: EdgeInsets.zero,
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: AppColors.colorPurple
                                    //         .withOpacity(0.2),
                                    //     blurRadius: 28,
                                    //     offset: const Offset(0, 10),
                                    //   ),
                                    // ],
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: AppUtils.commonContainer(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.1)),
                                          image: DecorationImage(
                                            image: AssetImage(setImageByType(
                                                getDigitalCardModel
                                                            ?.data?.cardData
                                                            ?.map((e) =>
                                                                e.isActive)
                                                            .where((element) =>
                                                                element == 1)
                                                            .toList()
                                                            .length ==
                                                        0
                                                    ? ""
                                                    : getDigitalCardModel
                                                            ?.data?.cardData
                                                            ?.where((element) =>
                                                                element
                                                                    .isActive ==
                                                                1)
                                                            .toList()[index]
                                                            .type ??
                                                        '')),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child:
                                            (getDigitalCardModel?.data?.cardData
                                                            ?.where((element) =>
                                                                element
                                                                    .isActive ==
                                                                1)
                                                            .toList()
                                                            .length ??
                                                        0) <=
                                                    0
                                                ? Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .credit_card_rounded,
                                                          size: 48,
                                                          color: AppColors
                                                              .colorPurple
                                                              .withOpacity(0.6),
                                                        ),
                                                        AppUtils.commonSizedBox(
                                                            height: 12),
                                                        AppUtils.commonTextWidget(
                                                            text: "WELCOME",
                                                            fontFamily: StringUtils
                                                                .fontFamilyHeading,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            letterSpacing: 2,
                                                            textColor: AppColors
                                                                .colorOffWhite),
                                                        AppUtils.commonSizedBox(
                                                            height: 8),
                                                        AppUtils.commonTextWidget(
                                                            textColor: AppColors
                                                                .colorTextMuted,
                                                            text:
                                                                "Start by creating your profile",
                                                            fontSize: 11,
                                                            letterSpacing: 0.5),
                                                      ],
                                                    ),
                                                  )
                                                : Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Expanded(
                                                        child: Builder(
                                                          builder: (context) {
                                                            final cardList = getDigitalCardModel?.data?.cardData?.where((element) => element.isActive == 1).toList() ?? [];
                                                            final cardItem = cardList.isNotEmpty && index < cardList.length ? cardList[index] : null;
                                                            final cardType = cardItem?.type ?? '';
                                                            final cardLabel = cardItem?.cardLabel ?? '';
                                                            final cardImage = cardItem?.cardImage;
                                                            final isImageSet = cardItem?.isImageSet == 1;
                                                            final field1 = cardItem?.field1 ?? '';

                                                            final displayField = AppUtils.formatSocialUsername(cardType, field1);

                                                          return Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              AppUtils.commonTextWidget(
                                                                  margin: AppUtils.edgeInsetsOnly(
                                                                      bottom:
                                                                          AppConstants
                                                                              .ten,
                                                                      left: AppConstants
                                                                          .fifteen,
                                                                      top: AppConstants
                                                                          .ten),
                                                                  text:
                                                                      "${cardType.toUpperCase()} CARD",
                                                                  fontFamily:
                                                                      StringUtils
                                                                          .fontFamilyHeading,
                                                                  textColor: AppColors
                                                                      .colorWhite
                                                                      .withOpacity(
                                                                          0.8),
                                                                  letterSpacing:
                                                                      3,
                                                                  fontSize:
                                                                      AppConstants
                                                                          .fifteen),
                                                              AppUtils.commonTextWidget(
                                                                  margin: AppUtils
                                                                      .edgeInsetsOnly(
                                                                          left: AppConstants
                                                                              .fifteen),
                                                                  text:
                                                                      cardLabel,
                                                                  fontFamily:
                                                                      StringUtils
                                                                          .fontFamilyHeading,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap:
                                                                      false,
                                                                  letterSpacing:
                                                                      0.5,
                                                                  textColor: AppColors
                                                                      .colorWhite
                                                                      .withOpacity(
                                                                          0.5),
                                                                  fontSize:
                                                                      AppConstants
                                                                          .ten),
                                                              Container(
                                                                margin: AppUtils.edgeInsetsOnly(
                                                                    left: AppConstants
                                                                        .fifteen,
                                                                    top: AppConstants
                                                                        .fifteen),
                                                                child: Stack(
                                                                  clipBehavior:
                                                                      Clip.none,
                                                                  children: [
                                                                    AppUtils
                                                                        .commonContainer(
                                                                      decoration:
                                                                          AppUtils
                                                                              .commonBoxDecoration(
                                                                        color: AppColors
                                                                            .colorMainBlack,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                            color:
                                                                                AppColors.colorGrey,
                                                                            width: 1),
                                                                      ),
                                                                      child:
                                                                          ClipOval(
                                                                        child: cardImage ==
                                                                                null
                                                                            ? AppUtils.commonSizedBox()
                                                                            : CachedNetworkImage(
                                                                                fit: BoxFit.cover,
                                                                                height: 80,
                                                                                width: 80,
                                                                                imageUrl: cardImage,
                                                                                imageBuilder: (context, imageProvider) => Padding(
                                                                                  padding: EdgeInsets.all(isImageSet ? 0 : 18),
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                placeholder: (context, url) => Center(
                                                                                    child: CircularProgressIndicator(
                                                                                  color: AppColors.colorPurple,
                                                                                  strokeWidth: 1.5,
                                                                                )),
                                                                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                              ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      bottom:
                                                                          -2,
                                                                      right: -2,
                                                                      child:
                                                                          Container(
                                                                        padding: EdgeInsets.all(cardType.toLowerCase() == 'business' &&
                                                                                cardItem?.companyLogo != null &&
                                                                                cardItem!.companyLogo!.isNotEmpty
                                                                            ? 0
                                                                            : 5),
                                                                        clipBehavior:
                                                                            Clip.antiAlias,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              AppColors.colorMainBlack,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          border: Border.all(
                                                                              color: Colors.white.withOpacity(0.12),
                                                                              width: 1),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(0.3),
                                                                              blurRadius: 4,
                                                                              offset: const Offset(0, 2),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        width:
                                                                            30,
                                                                        height:
                                                                            30,
                                                                        child: cardType.toLowerCase() == 'business' &&
                                                                                cardItem?.companyLogo != null &&
                                                                                cardItem!.companyLogo!.isNotEmpty
                                                                            ? CachedNetworkImage(
                                                                                imageUrl: cardItem.companyLogo!,
                                                                                fit: BoxFit.cover,
                                                                                placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 1),
                                                                                errorWidget: (context, url, error) => Image.asset(
                                                                                  AppUtils.setIconByType(cardType),
                                                                                  // width: 16,
                                                                                  // height: 16,
                                                                                ),
                                                                              )
                                                                            : Image.asset(
                                                                                AppUtils.setIconByType(cardType),
                                                                                fit: BoxFit.cover,
                                                                                // width: 16,
                                                                                // height: 16,
                                                                              ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              AppUtils.commonSizedBox(
                                                                  height:
                                                                      AppConstants
                                                                          .ten),
                                                              AppUtils.commonTextWidget(
                                                                  margin: AppUtils.edgeInsetsOnly(
                                                                      left: AppConstants
                                                                          .fifteen,
                                                                      top: AppConstants
                                                                          .twenty),
                                                                  text:
                                                                      displayField,
                                                                  letterSpacing:
                                                                      1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap:
                                                                      false,
                                                                  fontSize:
                                                                      AppConstants
                                                                          .fourteen),
                                                            ],
                                                          );
                                                        }),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              commonBtn(
                                                                  text:
                                                                      "Disable",
                                                                  imageHeight:
                                                                      22,
                                                                  imagePath:
                                                                      "assets/images/ic_disable_card.png",
                                                                  isImage: true,
                                                                  onTap: () {
                                                                    openDisableCardDialog(
                                                                        postMdl,
                                                                        getDigitalCardModel
                                                                            ?.data
                                                                            ?.cardData
                                                                            ?.where((element) =>
                                                                                element.isActive ==
                                                                                1)
                                                                            .toList()[
                                                                                index]
                                                                            .id
                                                                            .toString(),
                                                                        getDigitalCardModel
                                                                            ?.data
                                                                            ?.cardData
                                                                            ?.where((element) =>
                                                                                element.isActive ==
                                                                                1)
                                                                            .toList()[index]
                                                                            .type);
                                                                  }),
                                                              commonBtn(
                                                                  text: "Share",
                                                                  imageHeight:
                                                                      22,
                                                                  imagePath:
                                                                      "assets/images/ic_share.png",
                                                                  isImage: true,
                                                                  onTap: () {
                                                                    _onShare(
                                                                        context,
                                                                        getDigitalCardModel
                                                                            ?.data
                                                                            ?.cardData
                                                                            ?.where((element) =>
                                                                                element.isActive ==
                                                                                1)
                                                                            .toList()[
                                                                                index]
                                                                            .field1,
                                                                        getDigitalCardModel
                                                                            ?.data
                                                                            ?.cardData
                                                                            ?.where((element) =>
                                                                                element.isActive ==
                                                                                1)
                                                                            .toList()[index]
                                                                            .qrImage);
                                                                  }),
                                                              commonBtn(
                                                                  text:
                                                                      "Link QR",
                                                                  imageHeight:
                                                                      22,
                                                                  imagePath:
                                                                      "assets/images/ic_qr.png",
                                                                  isImage: true,
                                                                  onTap: () {
                                                                    scanQRCode(
                                                                        profileID: getDigitalCardModel
                                                                            ?.data
                                                                            ?.cardData
                                                                            ?.where((element) =>
                                                                                element.isActive ==
                                                                                1)
                                                                            .toList()[
                                                                                index]
                                                                            .id
                                                                            .toString(),
                                                                        postMdl1:
                                                                            postMdl,
                                                                        cardType: getDigitalCardModel
                                                                            ?.data
                                                                            ?.cardData
                                                                            ?.where((element) =>
                                                                                element.isActive ==
                                                                                1)
                                                                            .toList()[index]
                                                                            .type);
                                                                  }),
                                                              commonBtn(
                                                                  text: "NFC",
                                                                  imagePath:
                                                                      "assets/images/ic_nfc_icon.png",
                                                                  isImage: true,
                                                                  imageHeight:
                                                                      22,
                                                                  onTap:
                                                                      () async {
                                                                    bool
                                                                        isAvailable =
                                                                        await NfcManager
                                                                            .instance
                                                                            .isAvailable();
                                                                    if (isAvailable) {
                                                                      showModalBottomSheet(
                                                                        isScrollControlled:
                                                                        true,
                                                                        backgroundColor: Colors.transparent,
                                                                        elevation: 0,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                        sheetCtx) {
                                                                           return AppUtils.buildSheetWrapper(
                                                                             context: sheetCtx,
                                                                             child: Column(
                                                                               mainAxisSize: MainAxisSize.min,
                                                                               children: [
                                                                                 Divider(color: Colors.white.withOpacity(0.15), thickness: 3.5, endIndent: 150, indent: 150, height: 10),
                                                                                 AppUtils.commonSizedBox(height: 15),
                                                                                 AppUtils.commonTextWidget(textColor: AppColors.colorWhite, letterSpacing: 1, fontWeight: FontWeight.w700, fontFamily: StringUtils.fontFamilyHeading, text: "Write to NFC", fontSize: AppConstants.sixteen),
                                                                                 AppUtils.commonSizedBox(height: 15),
                                                                                 Divider(color: AppColors.colorPurple.withOpacity(0.3), indent: 0, endIndent: 0),
                                                                                 AppUtils.commonSizedBox(height: 15),
                                                                                 AppUtils.commonTextWidget(margin: AppUtils.edgeInsetsOnly(right: 20, left: 20), textColor: AppColors.colorWhite.withOpacity(0.8), letterSpacing: 1, textAlign: TextAlign.center, fontWeight: FontWeight.w500, fontFamily: StringUtils.fontFamilyHeading, text: "Hold the Tag to the back of your phone", fontSize: AppConstants.fourteen),
                                                                                 AppUtils.commonSizedBox(height: 20),
                                                                                 AppUtils.commonContainer(
                                                                                   padding: AppUtils.edgeInsetsOnly(top: 25, bottom: 25, right: 25, left: 25),
                                                                                   decoration: AppUtils.commonBoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04), border: Border.all(color: AppColors.colorPurpleLight.withOpacity(0.35))),
                                                                                   child: Image.asset(
                                                                                     "assets/images/nfc.png",
                                                                                     fit: BoxFit.cover,
                                                                                     height: 75,
                                                                                     width: 75,
                                                                                     color: AppColors.colorPurpleLight,
                                                                                   ),
                                                                                 ),
                                                                                 AppUtils.commonSizedBox(height: 15),
                                                                                 AppUtils.commonTextWidget(
                                                                                   margin: AppUtils.edgeInsetsOnly(right: 20, left: 20),
                                                                                   textColor: AppColors.colorWhite.withOpacity(0.8),
                                                                                   letterSpacing: 1,
                                                                                   textAlign: TextAlign.center,
                                                                                   fontWeight: FontWeight.w500,
                                                                                   fontFamily: StringUtils.fontFamilyHeading,
                                                                                   text: "URL to be added on the tag",
                                                                                 ),
                                                                                 AppUtils.commonSizedBox(height: 10),
                                                                                 AppUtils.commonTextWidget(
                                                                                   margin: AppUtils.edgeInsetsOnly(right: 20, left: 20),
                                                                                   textColor: AppColors.colorPurpleLight,
                                                                                   letterSpacing: 0.5,
                                                                                   textAlign: TextAlign.center,
                                                                                   fontWeight: FontWeight.w600,
                                                                                   fontFamily: StringUtils.fontFamilyHeading,
                                                                                   text: getDigitalCardModel?.data?.cardData?.where((element) => element.isActive == 1).toList()[index].qrImage ?? '',
                                                                                 ),
                                                                                 AppUtils.commonSizedBox(height: 20),
                                                                                 ValueListenableBuilder<String>(
                                                                                   builder: (BuildContext context, String value, Widget? child) {
                                                                                     return AppUtils.commonElevatedBtn(
                                                                                         width: double.infinity,
                                                                                         onPressed: () {
                                                                                           _ndefWrite(getDigitalCardModel?.data?.cardData?.where((element) => element.isActive == 1).toList()[index].qrImage ?? '', sheetCtx, context);
                                                                                         },
                                                                                         height: 44,
                                                                                         text: value,
                                                                                         gradient: AppColors.gradientPurple);
                                                                                   },
                                                                                   valueListenable: nfcWritingString,
                                                                                 ),
                                                                                 AppUtils.commonSizedBox(height: 5),
                                                                               ],
                                                                             ),
                                                                           );
                                                                        },
                                                                      ).whenComplete(
                                                                          () {
                                                                        NfcManager
                                                                            .instance
                                                                            .stopSession();
                                                                        nfcWritingString.value =
                                                                            "Write to NFC";
                                                                      });
                                                                    } else {
                                                                      AppUtils.showSnackBarWithColor(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              "NFC is not enabled on your device",
                                                                          giveColor:
                                                                              AppColors.colorBlueAccent);
                                                                    }
                                                                  }),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                        pageIndicator(),
                        _buildQrFooter(),
                      ],
                    ),
                  ),
                  postMdl.isUploading
                      ? AppUtils.loaderWidget()
                      : AppUtils.commonSizedBox(),
                ],
              );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: AppColors.gradientPurple,
              boxShadow: [
                BoxShadow(
                  color: AppColors.colorPurple.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              letterSpacing: 1.2,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.colorOffWhite,
              fontFamily: StringUtils.fontFamilyHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(DashboardProvider postMdl) {
    final firstName = getDigitalCardModel?.data?.userData?.firstName ?? '';
    final lastName = getDigitalCardModel?.data?.userData?.lastName ?? '';
    final profileUrl = getDigitalCardModel?.data?.userData?.profileImage ?? '';

    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      borderRadius: 24,
      blur: 24,
      opacity: 0.07,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        fontFamily: StringUtils.fontFamilyHeading,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.colorTextMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '$firstName $lastName'.trim(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: StringUtils.fontFamilyHeading,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: AppColors.colorOffWhite,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.waving_hand_rounded,
                          color: AppColors.colorPurple.withOpacity(0.9),
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your digital cards',
                      style: TextStyle(
                        fontFamily: StringUtils.fontFamilyPara,
                        fontSize: 11,
                        color: AppColors.colorTextMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              GlassContainer(
                borderRadius: 16,
                blur: 12,
                opacity: 0.05,
                padding: EdgeInsets.zero,
                width: 58,
                height: 58,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: getDigitalCardModel?.data?.userData == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: AppColors.colorPurpleLight,
                        )
                      : CachedNetworkImage(
                          height: 58,
                          width: 58,
                          fit: BoxFit.cover,
                          imageUrl: profileUrl,
                          placeholder: (_, __) => Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.colorPurple,
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: AppColors.colorPurpleLight,
                          ),
                        ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _glassChipButton(
                  label: 'Create Profile',
                  icon: Icons.add_rounded,
                  onTap: openCreateProfileDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _glassChipButton(
                  label: 'Add Card',
                  icon: Icons.credit_card_rounded,
                  filled: true,
                  onTap: () {
                    openAddCardDialog(
                      disableCardMap: disableCardLabelAndIdMap,
                      onTapLabel: (ctx99, cardId, postMdl4) {
                        Navigator.pop(ctx99);
                        callDisableEnableApi(
                          ctx: context,
                          cardId: cardId,
                          isDisable: false,
                          postMdl1: postMdl4,
                          cardType: getDigitalCardModel?.data?.cardData
                              ?.firstWhere(
                                  (e) => e.id.toString() == cardIdNoti.value)
                              .type,
                        );
                      },
                      postMdl2: postMdl,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassChipButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: filled
                ? LinearGradient(
                    colors: [
                      AppColors.colorPurple.withOpacity(0.55),
                      AppColors.colorPurpleLight.withOpacity(0.4),
                    ],
                  )
                : null,
            color: filled ? null : Colors.white.withOpacity(0.04),
            border: Border.all(
              color: filled
                  ? AppColors.colorPurple.withOpacity(0.5)
                  : Colors.white.withOpacity(0.12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: AppColors.colorOffWhite),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.colorOffWhite,
                      fontFamily: StringUtils.fontFamilyHeading,
                      letterSpacing: 0.3,
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

  Widget _buildQrFooter() {
    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      borderRadius: 20,
      blur: 20,
      opacity: 0.06,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text(
            Theme.of(context).platform == TargetPlatform.android
                ? 'Tap below to share your active card via QR code or NFC.'
                : 'Tap below to share your active card via QR code or AirDrop.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.colorTextMuted,
              fontSize: 11,
              height: 1.5,
              letterSpacing: 0.4,
              fontFamily: StringUtils.fontFamilyPara,
            ),
          ),
          const SizedBox(height: 14),
          Theme.of(context).platform == TargetPlatform.android
              ? Row(
                  children: [
                    Expanded(
                      child: _buildFooterButton(
                        icon: Icons.qr_code_2_rounded,
                        label: 'Open QR',
                        onTap: () => openQRPage(_currentIndex),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFooterButton(
                        icon: Icons.nfc_rounded,
                        label: 'NFC Share',
                        onTap: () => openNfcSharePage(_currentIndex),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildFooterButton(
                        icon: Icons.qr_code_2_rounded,
                        label: 'Open QR',
                        onTap: () => openQRPage(_currentIndex),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFooterButton(
                        icon: Icons.ios_share_rounded,
                        label: 'AirDrop Share',
                        onTap: () {
                          final cardList = getDigitalCardModel?.data?.cardData
                                  ?.where((element) => element.isActive == 1)
                                  .toList() ??
                              [];
                          if (cardList.isNotEmpty && _currentIndex < cardList.length) {
                            final card = cardList[_currentIndex];
                            _onShare(context, card.field1, card.qrImage, onlyAirDrop: true);
                          } else {
                            AppUtils.showSnackBarWithColor(
                              context: context,
                              message: "No active profile found",
                              giveColor: AppColors.colorGreyLatest,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                AppColors.colorPurple.withOpacity(0.35),
                AppColors.colorPurpleLight.withOpacity(0.25),
              ],
            ),
            border: Border.all(
              color: AppColors.colorPurple.withOpacity(0.45),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AppColors.colorOffWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.colorOffWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringUtils.fontFamilyHeading,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  openQRPage(int index) {
    // Clear NFC trigger when opening QR code modal
    PreferenceHelper.load().then((_) {
      PreferenceHelper.setString("active_nfc_url", "");
    });

    var imageUrl1;
    try {
      imageUrl1 = getDigitalCardModel?.data?.cardData
          ?.where((element) => element.isActive == 1)
          .toList()[index]
          .qrImage;
    } catch (e) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "No Active Profile Found",
          giveColor: AppColors.colorGreyLatest);
    }

    if (imageUrl1 != null) {
      showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        context: context,
        builder: (sheetCtx) {
          return AppUtils.buildSheetWrapper(
            context: sheetCtx,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: Colors.white.withOpacity(0.15), thickness: 3.5, endIndent: 150, indent: 150, height: 10),
                AppUtils.commonSizedBox(height: 20),
                AppUtils.commonTextWidget(
                    text: "Scan and share your card with a QR code",
                    margin: AppUtils.edgeInsetsOnly(right: 20, left: 20),
                    textColor: AppColors.colorWhite.withOpacity(0.8),
                    letterSpacing: 1,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringUtils.fontFamilyHeading,
                    fontSize: AppConstants.sixteen),
                AppUtils.commonSizedBox(height: 24),
                Center(
                  child: AppUtils.commonContainer(
                    decoration: AppUtils.commonBoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.colorPurple.withOpacity(0.25),
                            AppColors.colorPurpleLight.withOpacity(0.15),
                          ]),
                      border: Border.all(color: AppColors.colorPurpleLight.withOpacity(0.3), width: 1),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(
                      data: imageUrl1,
                      eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.colorWhite.withOpacity(0.9)),
                      dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.colorWhite.withOpacity(0.9)),
                      backgroundColor: AppColors.colorTransparent,
                      version: QrVersions.auto,
                      size: 180.0,
                    ),
                  ),
                ),
                AppUtils.commonSizedBox(height: 24),
                AppUtils.commonTextWidget(
                    margin: AppUtils.edgeInsetsOnly(right: 20, left: 20),
                    textColor: AppColors.colorWhite.withOpacity(0.5),
                    letterSpacing: 0.5,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w400,
                    fontFamily: StringUtils.fontFamilyHeading,
                    text: "Your Digital Profile Link:",
                    fontSize: AppConstants.twelve),
                AppUtils.commonSizedBox(height: 8),
                AppUtils.commonInkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    _launchInBrowser(Uri.parse(getDigitalCardModel
                            ?.data?.cardData
                            ?.where((element) => element.isActive == 1)
                            .toList()[index]
                            .qrImage ??
                        ''));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Text(
                      getDigitalCardModel?.data?.cardData
                              ?.where((element) => element.isActive == 1)
                              .toList()[index]
                              .qrImage ??
                          '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.colorPurpleLight,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: StringUtils.fontFamilyHeading,
                        fontSize: AppConstants.fourteen,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                AppUtils.commonSizedBox(height: 16),
              ],
            ),
          );
        },
      );
    }
  }

  openNfcSharePage(int index) async {
    var cardUrl;
    try {
      cardUrl = getDigitalCardModel?.data?.cardData
          ?.where((element) => element.isActive == 1)
          .toList()[index]
          .qrImage;
    } catch (e) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "No Active Profile Found",
          giveColor: AppColors.colorGreyLatest);
      return;
    }

    if (cardUrl != null && cardUrl.isNotEmpty) {
      // Trigger NFC to NFC transfer by saving URL to shared preferences
      await PreferenceHelper.load();
      await PreferenceHelper.setString("active_nfc_url", cardUrl);
      print("NFC Transfer triggered: Saved active NFC URL to preferences: $cardUrl");

      showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        context: context,
        builder: (sheetCtx) {
          return AppUtils.buildSheetWrapper(
            context: sheetCtx,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: Colors.white.withOpacity(0.15), thickness: 3.5, endIndent: 150, indent: 150, height: 10),
                AppUtils.commonSizedBox(height: 20),
                AppUtils.commonTextWidget(
                    text: "Tap Phones to Share",
                    textColor: AppColors.colorWhite,
                    letterSpacing: 1,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w700,
                    fontFamily: StringUtils.fontFamilyHeading,
                    fontSize: AppConstants.eighteen),
                AppUtils.commonSizedBox(height: 10),
                AppUtils.commonTextWidget(
                    text: "Hold the back of your phone close to their phone",
                    textColor: AppColors.colorTextMuted,
                    letterSpacing: 0.5,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w400,
                    fontFamily: StringUtils.fontFamilyPara,
                    fontSize: AppConstants.twelve),
                AppUtils.commonSizedBox(height: 30),
                
                // Phone-to-phone contact animation
                const _PhoneToPhoneAnimation(),

                AppUtils.commonSizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      _buildInstructionStep(
                        icon: Icons.lock_open_rounded,
                        title: "Keep phones unlocked & screens on",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        icon: Icons.contactless_rounded,
                        title: "Tap the backs together to share instantly",
                      ),
                    ],
                  ),
                ),
                AppUtils.commonSizedBox(height: 24),
                AppUtils.commonElevatedBtn(
                  width: double.infinity,
                  onPressed: () => Navigator.pop(sheetCtx),
                  height: 46,
                  text: "Done",
                  gradient: AppColors.gradientPurple,
                ),
                AppUtils.commonSizedBox(height: 10),
              ],
            ),
          );
        },
      ).whenComplete(() async {
        // Remove NFC trigger when modal is closed
        await PreferenceHelper.load();
        await PreferenceHelper.setString("active_nfc_url", "");
        print("NFC Transfer stopped: Cleared active NFC URL from preferences.");
      });
    }
  }

  Widget _buildInstructionStep({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.colorPurple.withOpacity(0.15),
            border: Border.all(color: AppColors.colorPurple.withOpacity(0.4), width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.colorPurpleLight,
            size: 15,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.colorOffWhite.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: StringUtils.fontFamilyHeading,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Widget commonBtn(
      {IconData? icon,
      bool? isImage,
      required VoidCallback onTap,
      String? imagePath,
      String? text,
      double? imageHeight}) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppUtils.commonInkWell(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          onTap: onTap,
          child: Container(
            width: 62,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.colorMainBlack.withOpacity(0.85),
                  AppColors.colorPurple.withOpacity(0.25),
                ],
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.12)),
                left: BorderSide(color: Colors.white.withOpacity(0.12)),
                bottom: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: isImage ?? false
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        imagePath ?? '',
                        fit: BoxFit.cover,
                        height: imageHeight ?? AppConstants.twenty,
                        color: AppColors.colorOffWhite,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        text ?? '',
                        style: TextStyle(
                          color: AppColors.colorOffWhite,
                          fontSize: 7.5,
                          fontFamily: StringUtils.fontFamilyHeading,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  )
                : Icon(icon, color: AppColors.colorOffWhite, size: 20),
          ),
        ),
      ),
    );
  }

  openDisableCardDialog(
      DashboardProvider? postMdl1, String? cardId, String? cardType) {
    ConfirmationDialog.show(
      context: context,
      title: 'Disable this card?',
      message: 'Are you sure you want to disable this card?',
      confirmText: 'Disable',
      isDestructive: true,
      onConfirm: () {
        callDisableEnableApi(
            cardType: cardType,
            cardId: cardId,
            ctx: context,
            isDisable: true,
            postMdl1: postMdl1);
      },
    );
  }

  openCreateProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CommonDialog(
          showmessage: showmessage,
          selectedIndex: 0,
        );
      },
    );
  }

  showmessage(message) {
    AppUtils.showSnackBarWithColor(context: context, message: message);
  }

  openAddCardDialog({
    Map<int, String>? disableCardMap,
    required Function onTapLabel,
    required DashboardProvider postMdl2,
  }) {
    AddCardDialog.show(
      context,
      disableCardMap: disableCardMap,
      postMdl: postMdl2,
      onSelect: (ctx99, cardId, postMdl4) {
        cardIdNoti.value = cardId;
        onTapLabel(ctx99, cardIdNoti.value, postMdl4);
      },
    );
  }

  Widget pageIndicator() {
    final count = (getDigitalCardModel?.data?.cardData
                    ?.where((e) => e.isActive == 1)
                    .length ??
                0) <=
            0
        ? 1
        : getDigitalCardModel?.data?.cardData
                ?.where((e) => e.isActive == 1)
                .length ??
            0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final active = _currentIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 7,
            width: active ? 28 : 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: active ? AppColors.gradientPurple : null,
              color: active ? null : Colors.white.withOpacity(0.2),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.colorPurple.withOpacity(0.45),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }

  String setImageByType(String type) {
    print("typetypetypetype $type");
    String imageString = 'assets/images/card2.jpg';
    if (type.toLowerCase() == "business") {
      imageString = 'assets/images/card2.jpg';
    } else if (type.toLowerCase() == "personal") {
      imageString = 'assets/images/card2.jpg';
    } else if (type.toLowerCase() == "instagram") {
      imageString = 'assets/images/card1.jpg';
    } else if (type.toLowerCase() == "spotify") {
      imageString = 'assets/images/card5.jpg';
    } else if (type.toLowerCase() == "youtube") {
      imageString = 'assets/images/card3.jpg';
    } else if (type.toLowerCase() == "linkedin") {
      imageString = 'assets/images/card4.jpg';
    } else {
      imageString = 'assets/images/card2.jpg';
    }
    return imageString;
  }
}

// QR Scanner screen using mobile_scanner package
class _QRScannerScreen extends StatefulWidget {
  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scanAreaSize = 250.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.colorMainBlack,
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          backgroundColor: AppColors.colorPurpleLight,
          foregroundColor: AppColors.colorOffWhite,
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _controller.toggleTorch(),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_hasScanned) return;
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  _hasScanned = true;
                  Navigator.pop(context, barcodes.first.rawValue);
                }
              },
            ),
            CustomPaint(
              size: Size.infinite,
              painter: QRScannerOverlayPainter(scanAreaSize: scanAreaSize),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.colorPurple,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.colorPurple.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.5 + (scanAreaSize / 2) + 24,
              left: 20,
              right: 20,
              child: const Center(
                child: Text(
                  'Align QR Code within the frame to scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
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

class QRScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;

  const QRScannerOverlayPainter({required this.scanAreaSize});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: scanAreaSize,
        height: scanAreaSize,
      ),
      const Radius.circular(16),
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cutoutRect);

    final path =
        Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(path, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant QRScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanAreaSize != scanAreaSize;
  }
}

class _PhoneToPhoneAnimation extends StatefulWidget {
  const _PhoneToPhoneAnimation({Key? key}) : super(key: key);

  @override
  State<_PhoneToPhoneAnimation> createState() => _PhoneToPhoneAnimationState();
}

class _PhoneToPhoneAnimationState extends State<_PhoneToPhoneAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPhoneWidget({required bool isSender}) {
    return Container(
      width: 36,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.colorMainBlack.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSender
              ? AppColors.colorPurpleLight.withOpacity(0.8)
              : Colors.white.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSender ? AppColors.colorPurple : Colors.white)
                .withOpacity(0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Notch
          Positioned(
            top: 3,
            child: Container(
              width: 10,
              height: 1.8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // Screen Details
          Container(
            margin: const EdgeInsets.fromLTRB(2, 6, 2, 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Icon(
              isSender ? Icons.nfc_rounded : Icons.contactless_rounded,
              color: isSender
                  ? AppColors.colorPurpleLight.withOpacity(0.8)
                  : AppColors.colorOffWhite.withOpacity(0.35),
              size: 14,
            ),
          ),
          // Home Indicator
          Positioned(
            bottom: 3,
            child: Container(
              width: 12,
              height: 1.2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          
          // Phase 1 (0.0 to 0.3): slide in
          // Phase 2 (0.3 to 0.85): touching / ripple
          // Phase 3 (0.85 to 1.0): slide out
          double slideProgress = 0.0;
          if (t < 0.3) {
            slideProgress = t / 0.3; // 0.0 -> 1.0
          } else if (t >= 0.3 && t < 0.85) {
            slideProgress = 1.0;
          } else {
            slideProgress = (1.0 - t) / 0.15; // 1.0 -> 0.0
          }

          // Ripple Progress (0.0 to 1.0 during Phase 2)
          double rippleProgress = 0.0;
          if (t >= 0.3 && t < 0.85) {
            rippleProgress = (t - 0.3) / 0.55; // 0.0 -> 1.0
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              // Contact point ripple waves
              if (rippleProgress > 0.0) ...[
                // Ripple 1
                Container(
                  width: 90 * rippleProgress,
                  height: 90 * rippleProgress,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.colorPurpleLight.withOpacity(0.5 * (1 - rippleProgress)),
                      width: 1.5,
                    ),
                  ),
                ),
                // Ripple 2
                if (rippleProgress > 0.3)
                  Container(
                    width: 90 * (rippleProgress - 0.3) / 0.7,
                    height: 90 * (rippleProgress - 0.3) / 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.colorPurple.withOpacity(0.3 * (1 - (rippleProgress - 0.3) / 0.7)),
                        width: 1.5,
                      ),
                    ),
                  ),
              ],

              // Left Phone (Sender)
              Transform.translate(
                offset: Offset(-50 * (1 - slideProgress) - 18, 0),
                child: Transform.rotate(
                  angle: -0.15 * (1 - slideProgress),
                  child: _buildPhoneWidget(isSender: true),
                ),
              ),

              // Right Phone (Receiver)
              Transform.translate(
                offset: Offset(50 * (1 - slideProgress) + 18, 0),
                child: Transform.rotate(
                  angle: 0.15 * (1 - slideProgress),
                  child: _buildPhoneWidget(isSender: false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
