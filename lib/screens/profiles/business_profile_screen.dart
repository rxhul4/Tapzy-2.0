import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tapzy/core/capitlize_string.dart';
import 'package:tapzy/core/common/commonBackground.dart';
import 'package:tapzy/core/common/glass_ui.dart';
import 'package:tapzy/core/constants/appColors.dart';
import 'package:tapzy/core/constants/appConstants.dart';
import 'package:tapzy/core/constants/stringUtils.dart';
import 'package:tapzy/core/utils/appUtils.dart';
import 'package:tapzy/models/add_business_model.dart';
import 'package:tapzy/models/edit_business_card_model.dart';
import 'package:tapzy/models/get_business_card_by_id_model.dart';
import 'package:tapzy/providers/profiles_provider.dart';
import 'package:tapzy/screens/dashboard_screens/dashboard_screen.dart';
import 'package:tapzy/screens/profiles/image_crop_screen.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/common/color_picker.dart';

class BusinessProfileScreen extends StatefulWidget {
  bool? isNew;
  bool? isView;
  String? businessId;
  Function? showmessage;
  int? selectedIndex;

  BusinessProfileScreen(
      {Key? key,
      this.showmessage,
      this.isNew = false,
      this.businessId,
      this.selectedIndex,
      this.isView})
      : super(key: key);

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen>
    with SingleTickerProviderStateMixin{
  GetBusinessCardByIdModel? getBusinessCardByIdModel;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postMdl = Provider.of<ProfilesProvider>(context, listen: false);
      if (widget.isNew == false) {
        postMdl
            .callGetBusinessCardsByIdApi(widget.businessId ?? '')
            .then((value) {
          print("ddddddd $value");
          getBusinessCardByIdModel = value;
          if (getBusinessCardByIdModel?.isSuccessful == 1) {
            cardLabeController.text =
                getBusinessCardByIdModel?.data?.cardLabel ?? '';
            if (getBusinessCardByIdModel?.data?.profilePrimaryColor != null &&
                getBusinessCardByIdModel!.data!.profilePrimaryColor!.isNotEmpty) {
              setState(() {
                selectedColor = Color(int.parse('0xFF' + getBusinessCardByIdModel!.data!.profilePrimaryColor!.replaceAll('#', '')));
              });
            }
            fullNameController.text =
                getBusinessCardByIdModel?.data?.businessUserName ?? '';
            cardLabeController.text =
                getBusinessCardByIdModel?.data?.cardLabel ?? '';
            designationController.text =
                getBusinessCardByIdModel?.data?.designation ?? '';
            companyController.text =
                getBusinessCardByIdModel?.data?.company ?? '';
            industryController.text =
                getBusinessCardByIdModel?.data?.industry ?? '';
            bioController.text = getBusinessCardByIdModel?.data?.bio ?? '';
            servicesController.text =
                getBusinessCardByIdModel?.data?.services ?? '';
            if (getBusinessCardByIdModel?.data?.businessContact1 != null) {
              number1Controller.text =
                  getBusinessCardByIdModel?.data?.businessContact1.toString() ??
                      '';
            }
            if (getBusinessCardByIdModel?.data?.businessContact2 != null) {
              number2Controller.text =
                  getBusinessCardByIdModel?.data?.businessContact2.toString() ??
                      '';
            }
            if (getBusinessCardByIdModel?.data?.businessContact3 != null) {
              number3Controller.text =
                  getBusinessCardByIdModel?.data?.businessContact3.toString() ??
                      '';
            }

            email1Controller.text =
                getBusinessCardByIdModel?.data?.businessEmail ?? '';
            email2Controller.text =
                getBusinessCardByIdModel?.data?.businessEmail2 ?? '';

            if (getBusinessCardByIdModel?.data?.businessWpNumber != null) {
              whatsappNumberController.text =
                  getBusinessCardByIdModel?.data?.businessWpNumber.toString() ??
                      '';
            }

            messengerController.text =
                getBusinessCardByIdModel?.data?.businessMessangerId ?? '';
            webController.text =
                getBusinessCardByIdModel?.data?.websiteLinks ?? '';
            driveController.text =
                getBusinessCardByIdModel?.data?.driveLink ?? '';
            docController.text = getBusinessCardByIdModel?.data?.docLink ?? '';
            cloudController.text =
                getBusinessCardByIdModel?.data?.cloudLink ?? '';
            customLinkLabelController.text =
                getBusinessCardByIdModel?.data?.customLinkLabel ?? '';
            customLinkController.text =
                getBusinessCardByIdModel?.data?.customLink ?? '';
            twitterController.text =
                getBusinessCardByIdModel?.data?.twitterUsername ?? '';
            linkedInController.text =
                getBusinessCardByIdModel?.data?.linkedinUsername ?? '';
            fbController.text =
                getBusinessCardByIdModel?.data?.facebookUsername ?? '';
            instaController.text =
                getBusinessCardByIdModel?.data?.instagramUsername ?? '';
            gpayController.text =
                getBusinessCardByIdModel?.data?.gpayNumberUpi ?? '';
            // paypalController.text =
            //     getBusinessCardByIdModel?.data?.paypalNumberUpi ?? '';
            paytmController.text =
                getBusinessCardByIdModel?.data?.paytmNumberUpi ?? '';
            address1Controller.text =
                getBusinessCardByIdModel?.data?.addressLine1 ?? '';
            address2Controller.text =
                getBusinessCardByIdModel?.data?.addressLine2 ?? '';
            address3Controller.text =
                getBusinessCardByIdModel?.data?.addressLine3 ?? '';
            eduController.text =
                getBusinessCardByIdModel?.data?.educationDetail ?? '';
            expController.text =
                getBusinessCardByIdModel?.data?.experienceDetail ?? '';
            hobController.text =
                getBusinessCardByIdModel?.data?.hobbiesDetail ?? '';
            infoController.text =
                getBusinessCardByIdModel?.data?.infoDetail ?? '';
            usernameController.text =
                getBusinessCardByIdModel?.data?.username ?? '';
            googleReviewLinkController.text =
                getBusinessCardByIdModel?.data?.googleReviewLink ?? '';
          }
          print("Cards are here ${getBusinessCardByIdModel?.toJson()}");
        });
      }
    });
  }

  TextEditingController fullNameController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController industryController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController servicesController = TextEditingController();
  TextEditingController number1Controller = TextEditingController();
  TextEditingController number2Controller = TextEditingController();
  TextEditingController number3Controller = TextEditingController();
  TextEditingController email1Controller = TextEditingController();
  TextEditingController email2Controller = TextEditingController();
  TextEditingController whatsappNumberController = TextEditingController();
  TextEditingController messengerController = TextEditingController();
  TextEditingController webController = TextEditingController();
  TextEditingController driveController = TextEditingController();
  TextEditingController docController = TextEditingController();
  TextEditingController cloudController = TextEditingController();
  TextEditingController customLinkLabelController = TextEditingController();
  TextEditingController customLinkController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController linkedInController = TextEditingController();
  TextEditingController fbController = TextEditingController();
  TextEditingController instaController = TextEditingController();
  TextEditingController gpayController = TextEditingController();
  // TextEditingController paypalController = TextEditingController();
  TextEditingController paytmController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController address3Controller = TextEditingController();
  TextEditingController eduController = TextEditingController();
  TextEditingController expController = TextEditingController();
  TextEditingController hobController = TextEditingController();
  TextEditingController infoController = TextEditingController();

  TextEditingController cardLabeController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController googleReviewLinkController = TextEditingController();

  File? _image;
  File? _companyLogo;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<void> _pickAndCropImage({
    required double aspectRatio,
    required String title,
    required Function(File) onSelect,
    required Permission permission,
    required String permissionMsg,
  }) async {
    bool hasPermission = false;
    if (Platform.isIOS) {
      var status = await permission.request();
      hasPermission = !status.isDenied && !status.isPermanentlyDenied;
    } else {
      final deviceInformation = await deviceInfo.androidInfo;
      if (deviceInformation.version.sdkInt > 32 && permission == Permission.storage) {
        var status = await Permission.photos.request();
        hasPermission = status.isGranted;
      } else {
        var status = await permission.request();
        hasPermission = status.isGranted;
      }
    }

    if (hasPermission) {
      var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      if (image?.path != null) {
        final bytes = await File(image!.path).readAsBytes();
        if (!mounted) return;
        final croppedBytes = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageCropScreen(
              imageBytes: bytes,
              aspectRatio: aspectRatio,
              title: title,
            ),
          ),
        );
        if (croppedBytes != null) {
          final tempDir = await getTemporaryDirectory();
          final file = await File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg').create();
          await file.writeAsBytes(croppedBytes);
          onSelect(file);
        }
      }
    } else {
      AppUtils.openAppSettingsPermissionDialog(
        ctxx: context,
        msg: permissionMsg,
      );
    }
  }

  Future getImage() async {
    final androidSdk = Platform.isAndroid ? (await deviceInfo.androidInfo).version.sdkInt : 0;
    final perm = Platform.isIOS ? Permission.photos : (androidSdk > 32 ? Permission.photos : Permission.storage);
    final msg = Platform.isIOS ? 
        "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Photos' and enable access for our app" :
        (androidSdk > 32 ? 
            "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Photos' and enable access for our app" :
            "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Storage' and enable access for our app");
            
    await _pickAndCropImage(
      aspectRatio: 3 / 4,
      title: "Crop Profile Photo",
      onSelect: (file) {
        setState(() {
          _image = file;
        });
      },
      permission: perm,
      permissionMsg: msg,
    );
  }

  Future getCompanyLogo() async {
    final androidSdk = Platform.isAndroid ? (await deviceInfo.androidInfo).version.sdkInt : 0;
    final perm = Platform.isIOS ? Permission.photos : (androidSdk > 32 ? Permission.photos : Permission.storage);
    final msg = Platform.isIOS ? 
        "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Photos' and enable access for our app" :
        (androidSdk > 32 ? 
            "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Photos' and enable access for our app" :
            "To access your photos, please go to your device's settings, find 'Privacy' or 'Permissions' locate 'Storage' and enable access for our app");
            
    await _pickAndCropImage(
      aspectRatio: 1.0,
      title: "Crop Company Logo",
      onSelect: (file) {
        setState(() {
          _companyLogo = file;
        });
      },
      permission: perm,
      permissionMsg: msg,
    );
  }

  AddBusinessModel? addBusinessModel;
  EditBusinessCardModel? editBusinessCardModel;



  callAddBusinessApi(BuildContext ctx, ProfilesProvider postMdl1) async {
    if (_image == null && _companyLogo == null) {
      postMdl1
          .callAddBusinessApiWithoutImage(
        card_label: cardLabeController.text,
        designation: designationController.text,
        addressLine1: address1Controller.text,
        addressLine2: address2Controller.text,
        addressLine3: address3Controller.text,
        bio: bioController.text,
        business_contact_1: number1Controller.text,
        business_contact_2: number2Controller.text,
        business_contact_3: number3Controller.text,
        business_email: email1Controller.text,
        business_email_2: email2Controller.text,
        business_messanger_id: messengerController.text,
        business_user_name: fullNameController.text,
        business_wp_number: whatsappNumberController.text,
        cloud_link: cloudController.text,
        company: companyController.text,
        custom_link: customLinkController.text,
        custom_link_label: customLinkLabelController.text,
        doc_link: docController.text,
        drive_link: driveController.text,
        education_detail: eduController.text,
        experience_detail: expController.text,
        facebook_username: fbController.text,
        gpay_number_upi: gpayController.text,
        hangouts_username: "",
        hobbies_detail: hobController.text,
        industry: industryController.text,
        info_detail: infoController.text,
        instagram_username: instaController.text,
        linkedin_username: linkedInController.text,
        // paypal_number_upi: paypalController.text,
        paytm_number_upi: paytmController.text,
        services: servicesController.text,
        skype_username: "",
        twitter_username: twitterController.text,
        website_links: webController.text,
        profile_primary_color: '#' + selectedColor.value.toRadixString(16).substring(2).toUpperCase(),
        username: usernameController.text,
        google_review_link: googleReviewLinkController.text,
      )
          .then((value) {
        addBusinessModel = value;
        print("print ${addBusinessModel?.toJson()}");
        if (addBusinessModel?.isSuccessful == 1) {
          if (widget.showmessage != null) {
            widget.showmessage!(addBusinessModel?.message);
            AppUtils.showSnackBarWithColor(
                context: context, message: addBusinessModel?.message ?? '');
          }
          // Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                        selectedIndex: widget.selectedIndex,
                      )),
              (route) => false);
        } else {
          AppUtils.showSnackBarWithColor(
              context: context,
              message: addBusinessModel?.message ?? '',
              giveColor: Colors.redAccent);
        }
      });
    } else {
      postMdl1
          .callAddBusinessApi(
        card_label: cardLabeController.text,
        imageFile: _image,
        companyLogoFile: _companyLogo,
        designation: designationController.text,
        addressLine1: address1Controller.text,
        addressLine2: address2Controller.text,
        addressLine3: address3Controller.text,
        bio: bioController.text,
        business_contact_1: number1Controller.text,
        business_contact_2: number2Controller.text,
        business_contact_3: number3Controller.text,
        business_email: email1Controller.text,
        business_email_2: email2Controller.text,
        business_messanger_id: messengerController.text,
        business_user_name: fullNameController.text,
        business_wp_number: whatsappNumberController.text,
        cloud_link: cloudController.text,
        company: companyController.text,
        custom_link: customLinkController.text,
        custom_link_label: customLinkLabelController.text,
        doc_link: docController.text,
        drive_link: driveController.text,
        education_detail: eduController.text,
        experience_detail: expController.text,
        facebook_username: fbController.text,
        gpay_number_upi: gpayController.text,
        hangouts_username: "",
        hobbies_detail: hobController.text,
        industry: industryController.text,
        info_detail: infoController.text,
        instagram_username: instaController.text,
        linkedin_username: linkedInController.text,
        // paypal_number_upi: paypalController.text,
        paytm_number_upi: paytmController.text,
        services: servicesController.text,
        skype_username: "",
        twitter_username: twitterController.text,
        website_links: webController.text,
        profile_primary_color: '#' + selectedColor.value.toRadixString(16).substring(2).toUpperCase(),
        username: usernameController.text,
        google_review_link: googleReviewLinkController.text,
      )
          .then((value) {
        addBusinessModel = value;
        print("print ${addBusinessModel?.toJson()}");
        if (addBusinessModel?.isSuccessful == 1) {
          if (widget.showmessage != null) {
            widget.showmessage!(addBusinessModel?.message);
            AppUtils.showSnackBarWithColor(
                context: context, message: addBusinessModel?.message ?? '');
          }
          // Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                        selectedIndex: widget.selectedIndex,
                      )),
              (route) => false);
        } else {
          AppUtils.showSnackBarWithColor(
              context: context,
              message: addBusinessModel?.message ?? '',
              giveColor: Colors.redAccent);
        }
      });
    }
  }


  Color selectedColor = AppColors.colorPurple;

  void openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AppColorPicker(
          initialColor: selectedColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
        );
      },
    );
  }

  callEditBusinessApiWithoutImage(
      BuildContext ctx, ProfilesProvider postMdl1, String business_id) async {
    if (_image == null && _companyLogo == null) {
      postMdl1
          .callEditBusinessApiWithoutImage(
        card_label: cardLabeController.text,
        business_id: business_id,
        designation: designationController.text,
        addressLine3: address3Controller.text,
        addressLine2: address2Controller.text,
        addressLine1: address1Controller.text,
        bio: bioController.text,
        business_contact_1: number1Controller.text,
        business_contact_2: number2Controller.text,
        business_contact_3: number3Controller.text,
        business_email: email1Controller.text,
        business_email_2: email2Controller.text,
        business_messanger_id: messengerController.text,
        business_user_name: fullNameController.text,
        business_wp_number: whatsappNumberController.text,
        cloud_link: cloudController.text,
        company: companyController.text,
        custom_link: customLinkController.text,
        custom_link_label: customLinkLabelController.text,
        doc_link: docController.text,
        drive_link: driveController.text,
        education_detail: eduController.text,
        experience_detail: expController.text,
        facebook_username: fbController.text,
        gpay_number_upi: gpayController.text,
        hangouts_username: "",
        hobbies_detail: hobController.text,
        industry: industryController.text,
        info_detail: infoController.text,
        instagram_username: instaController.text,
        linkedin_username: linkedInController.text,
        // paypal_number_upi: paypalController.text,
        paytm_number_upi: paytmController.text,
        services: servicesController.text,
        skype_username: "",
        twitter_username: twitterController.text,
        website_links: webController.text,
        profile_primary_color: '#' + selectedColor.value.toRadixString(16).substring(2).toUpperCase(),
        username: usernameController.text,
        google_review_link: googleReviewLinkController.text,
      )
          .then((value) {
        editBusinessCardModel = value;
        print("print ${editBusinessCardModel?.toJson()}");
        if (editBusinessCardModel?.isSuccessful == 1) {
          if (widget.showmessage != null) {
            widget.showmessage!(editBusinessCardModel?.message);
            AppUtils.showSnackBarWithColor(
                context: context,
                message: editBusinessCardModel?.message ?? '');
          }
          // Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                        selectedIndex: widget.selectedIndex,
                      )),
              (route) => false);
        } else {
          AppUtils.showSnackBarWithColor(
              context: context,
              message: editBusinessCardModel?.message ?? '',
              giveColor: Colors.redAccent);
        }
      });
    } else {
      postMdl1
          .callEditBusinessApi(
        imageFile: _image,
        companyLogoFile: _companyLogo,
        card_label: cardLabeController.text,
        business_id: business_id,
        designation: designationController.text,
        addressLine1: address1Controller.text,
        addressLine2: address2Controller.text,
        addressLine3: address3Controller.text,
        bio: bioController.text,
        business_contact_1: number1Controller.text,
        business_contact_2: number2Controller.text,
        business_contact_3: number3Controller.text,
        business_email: email1Controller.text,
        business_email_2: email2Controller.text,
        business_messanger_id: messengerController.text,
        business_user_name: fullNameController.text,
        business_wp_number: whatsappNumberController.text,
        cloud_link: cloudController.text,
        company: companyController.text,
        custom_link: customLinkController.text,
        custom_link_label: customLinkLabelController.text,
        doc_link: docController.text,
        drive_link: driveController.text,
        education_detail: eduController.text,
        experience_detail: expController.text,
        facebook_username: fbController.text,
        gpay_number_upi: gpayController.text,
        hangouts_username: "",
        hobbies_detail: hobController.text,
        industry: industryController.text,
        info_detail: infoController.text,
        instagram_username: instaController.text,
        linkedin_username: linkedInController.text,
        // paypal_number_upi: paypalController.text,
        paytm_number_upi: paytmController.text,
        services: servicesController.text,
        skype_username: "",
        twitter_username: twitterController.text,
        website_links: webController.text,
        profile_primary_color: '#' + selectedColor.value.toRadixString(16).substring(2).toUpperCase(),
        username: usernameController.text,
        google_review_link: googleReviewLinkController.text,
      )
          .then((value) {
        editBusinessCardModel = value;
        print("print ${editBusinessCardModel?.toJson()}");
        if (editBusinessCardModel?.isSuccessful == 1) {
          if (widget.showmessage != null) {
            widget.showmessage!(editBusinessCardModel?.message);
            AppUtils.showSnackBarWithColor(
                context: context,
                message: editBusinessCardModel?.message ?? '');
          }
          // Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                        selectedIndex: widget.selectedIndex,
                      )),
              (route) => false);
        } else {
          AppUtils.showSnackBarWithColor(
              context: context,
              message: editBusinessCardModel?.message ?? '',
              giveColor: Colors.redAccent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<ProfilesProvider>(context);
    return postMdl.isFetching
        ? AppUtils.loaderWidget()
        : CommonBackGround(
            body: SafeArea(
              child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                actions: widget.isView == true
                    ? null
                    : [
                        TextButton(
                            onPressed: () {
                              if (cardLabeController.text.isEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message: "Please enter card label");
                              } else if (fullNameController.text.isEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message: "Please enter full name");
                              }
                              /*else if (designationController.text.isEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message: "Please enter designation");
                              } */
                              else if (!Uri.parse(webController.text).isAbsolute &&
                                  webController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Website link");
                              } else if (!Uri.parse(driveController.text).isAbsolute &&
                                  driveController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message: "Please enter a valid Drive link");
                              } else if (!Uri.parse(docController.text).isAbsolute &&
                                  docController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Document link");
                              } else if (!Uri.parse(cloudController.text).isAbsolute &&
                                  cloudController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message: "Please enter a valid Cloud link");
                              } else if (!Uri.parse(customLinkController.text)
                                      .isAbsolute &&
                                  customLinkController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Custom link");
                              } else if (Uri.parse(twitterController.text).isAbsolute &&
                                  twitterController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Twitter (X) username");
                              } else if (Uri.parse(linkedInController.text)
                                      .isAbsolute &&
                                  linkedInController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid LinkedIn username");
                              } else if (Uri.parse(fbController.text).isAbsolute &&
                                  fbController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Facebook username");
                              } else if (Uri.parse(instaController.text).isAbsolute &&
                                  instaController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Instagram username");
                              } else if (!StringCasingExtension.validateUPI(gpayController.text) &&
                                  gpayController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid GPay UPI ID");
                              } /*else if (!StringCasingExtension.validateUPI(
                                      paypalController.text) &&
                                  paypalController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Paypal UPI ID");
                              } */else if (!StringCasingExtension.validateUPI(paytmController.text) &&
                                  paytmController.text.isNotEmpty) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Paytm UPI ID");
                              } else if (usernameController.text.isNotEmpty &&
                                  !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usernameController.text)) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Username must contain only alphanumeric characters and underscores");
                              } else if (googleReviewLinkController.text.isNotEmpty &&
                                  !Uri.parse(googleReviewLinkController.text).isAbsolute) {
                                AppUtils.showSnackBarWithColor(
                                    giveColor: Colors.redAccent,
                                    context: context,
                                    message:
                                        "Please enter a valid Google Review link");
                              } else {
                                if (widget.isNew == true) {
                                  callAddBusinessApi(context, postMdl);
                                } else {
                                  callEditBusinessApiWithoutImage(context,
                                      postMdl, widget.businessId ?? '');
                                }
                              }
                            },
                            child: AppUtils.commonTextWidget(
                                text: "Save",
                                fontFamily: StringUtils.fontFamilyHeading,
                                letterSpacing: 1,
                                fontSize: 16,
                                textColor: AppColors.colorPurple))
                      ],
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: AppUtils.commonTextWidget(
                    text: "Business Profile",
                    fontWeight: FontWeight.w700,
                    fontFamily: StringUtils.fontFamilyHeading,
                    fontSize: 14),
                // title: Image.asset(
                //   "assets/images/ic_tran_name_white.png",
                //   height: 70,
                // ),
                leadingWidth: 56,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Center(
                    child: GlassUi.backButton(
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              body: Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    child: CustomPaint(painter: _OrbPainter()),
                  ),
                  Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          children: [
                            _buildGlassCard(
                              title: "Primary Information",
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: textField(
                                          controller: cardLabeController,
                                          hintText: "Card Label",
                                          enabledBorderColor: AppColors.colorWhite.withOpacity(0.8)),
                                    ),
                                  ],
                                ),
                                AppUtils.commonSizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        AppUtils.commonContainer(
                                          decoration: AppUtils.commonBoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.colorWhite, width: 1)),
                                          child: _image != null
                                              ? CircleAvatar(
                                                  backgroundColor: AppColors.colorTransparent,
                                                  radius: 40,
                                                  child: ClipOval(
                                                    child: Image.file(
                                                      File(_image?.path ?? ''),
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                              : ClipOval(
                                                  child: widget.isNew ?? false
                                                      ? AppUtils.commonContainer(
                                                          height: 75,
                                                          width: 75,
                                                          child: Icon(Icons.camera_alt, size: 40, color: Colors.white),
                                                        )
                                                      : CachedNetworkImage(
                                                          height: 75,
                                                          width: 75,
                                                          imageUrl: getBusinessCardByIdModel?.data?.profileImage ?? '',
                                                          imageBuilder: (context, imageProvider) => Padding(
                                                            padding: EdgeInsets.all(
                                                                getBusinessCardByIdModel?.data?.isImageSet == 1 ? 0 : 15),
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
                                                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                                                        ),
                                                ),
                                        ),
                                        Visibility(
                                          visible: widget.isView ?? false ? false : true,
                                          child: TextButton(
                                            onPressed: () {
                                              getImage();
                                            },
                                            child: AppUtils.commonTextWidget(
                                                text: widget.isNew ?? false ? "Upload Image" : "Change Image",
                                                fontFamily: StringUtils.fontFamilyHeading,
                                                fontSize: AppConstants.ten,
                                                letterSpacing: AppConstants.zeroPointFive,
                                                textColor: AppColors.colorWhite),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        AppUtils.commonContainer(
                                          decoration: AppUtils.commonBoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.colorWhite, width: 1)),
                                          child: _companyLogo != null
                                              ? CircleAvatar(
                                                  backgroundColor: AppColors.colorTransparent,
                                                  radius: 40,
                                                  child: ClipOval(
                                                    child: Image.file(
                                                      File(_companyLogo?.path ?? ''),
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                              : ClipOval(
                                                  child: (widget.isNew ?? false) || getBusinessCardByIdModel?.data?.companyLogo == null || getBusinessCardByIdModel!.data!.companyLogo!.isEmpty
                                                      ? AppUtils.commonContainer(
                                                          height: 75,
                                                          width: 75,
                                                          child: Icon(Icons.business, size: 40, color: Colors.white),
                                                        )
                                                      : CachedNetworkImage(
                                                          height: 75,
                                                          width: 75,
                                                          imageUrl: getBusinessCardByIdModel?.data?.companyLogo ?? '',
                                                          imageBuilder: (context, imageProvider) => Container(
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                            ),
                                                          ),
                                                          placeholder: (context, url) => Center(
                                                              child: CircularProgressIndicator(
                                                            color: AppColors.colorPurple,
                                                            strokeWidth: 1.5,
                                                          )),
                                                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                                                        ),
                                                ),
                                        ),
                                        Visibility(
                                          visible: widget.isView ?? false ? false : true,
                                          child: TextButton(
                                            onPressed: () {
                                              getCompanyLogo();
                                            },
                                            child: AppUtils.commonTextWidget(
                                                text: (widget.isNew ?? false) || getBusinessCardByIdModel?.data?.companyLogo == null || getBusinessCardByIdModel!.data!.companyLogo!.isEmpty ? "Upload Logo" : "Change Logo",
                                                fontFamily: StringUtils.fontFamilyHeading,
                                                fontSize: AppConstants.ten,
                                                letterSpacing: AppConstants.zeroPointFive,
                                                textColor: AppColors.colorWhite),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                    hintText: "Full name", controller: fullNameController),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                    hintText: "Username (E.g. john_doe)", controller: usernameController),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: usernameController,
                                  builder: (context, value, _) {
                                    final username = value.text.trim();
                                    final webBaseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
                                    final previewUrl = username.isNotEmpty 
                                        ? "$webBaseUrl/$username" 
                                        : "$webBaseUrl/your_username";
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6.0, left: 4, right: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "ⓘ This username creates a direct link to your digital profile:",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.5),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.04),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: username.isNotEmpty 
                                                    ? AppColors.colorPurpleLight.withOpacity(0.3)
                                                    : Colors.white.withOpacity(0.08)
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.link,
                                                  size: 14,
                                                  color: username.isNotEmpty 
                                                      ? AppColors.colorPurpleLight 
                                                      : Colors.white.withOpacity(0.4),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    previewUrl,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: username.isNotEmpty 
                                                          ? AppColors.colorPurpleLight 
                                                          : Colors.white.withOpacity(0.4),
                                                      fontSize: 11,
                                                      fontWeight: username.isNotEmpty 
                                                          ? FontWeight.w600 
                                                          : FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                    hintText: "Designation", controller: designationController),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                    hintText: "Company", controller: companyController),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                    hintText: "Industry", controller: industryController),
                                AppUtils.commonSizedBox(height: 20),
                                InkWell(
                                  onTap: () {
                                    openColorPicker(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                "Pick Color",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "ⓘ This color will be used as primary color on this profile web page",
                                                style: TextStyle(color: Colors.white, fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        AnimatedBuilder(
                                          animation: _shimmerAnimation,
                                          builder: (context, child) {
                                            return Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: selectedColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: selectedColor.withOpacity(0.7),
                                                    blurRadius: _shimmerAnimation.value,
                                                    spreadRadius: _shimmerAnimation.value / 2,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _buildGlassCard(
                              title: "About",
                              children: [
                                textField(hintText: "Bio", maxLines: 5, controller: bioController),
                                AppUtils.commonSizedBox(height: 10),
                                textField(hintText: "Services", maxLines: 5, controller: servicesController),
                              ],
                            ),
                            _buildGlassCard(
                              title: "Address",
                              children: [
                                textField(
                                  textInputType: TextInputType.streetAddress,
                                  controller: address1Controller,
                                  hintText: "Address line 1",
                                  suffixIcon: commonSuffixIcon(icon: Icons.location_on),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  textInputType: TextInputType.streetAddress,
                                  controller: address2Controller,
                                  hintText: "Address line 2",
                                  suffixIcon: commonSuffixIcon(icon: Icons.add_location_alt),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  textInputType: TextInputType.streetAddress,
                                  controller: address3Controller,
                                  hintText: "Address line 3",
                                  suffixIcon: commonSuffixIcon(icon: Icons.add_location_alt),
                                ),
                              ],
                            ),
                            _buildGlassCard(
                              title: "Phone messenger & Emails",
                              children: [
                                textField(
                                  hintText: "Contact number",
                                  controller: number1Controller,
                                  textInputType: TextInputType.phone,
                                  suffixIcon: commonSuffixIcon(icon: Icons.call),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Contact number 2",
                                  controller: number2Controller,
                                  textInputType: TextInputType.phone,
                                  suffixIcon: commonSuffixIcon(icon: Icons.add_call),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Contact number 3",
                                  controller: number3Controller,
                                  textInputType: TextInputType.phone,
                                  suffixIcon: commonSuffixIcon(icon: Icons.add_call),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Email address",
                                  controller: email1Controller,
                                  textInputType: TextInputType.emailAddress,
                                  suffixIcon: commonSuffixIcon(icon: Icons.email),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Alternate email address",
                                  controller: email2Controller,
                                  textInputType: TextInputType.emailAddress,
                                  suffixIcon: commonSuffixIcon(icon: Icons.alternate_email),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Whatsapp number",
                                  textInputType: TextInputType.phone,
                                  controller: whatsappNumberController,
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.whatsapp),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Messenger user id",
                                  controller: messengerController,
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.facebookMessenger),
                                ),
                              ],
                            ),
                            _buildGlassCard(
                              title: "Websites & Links",
                              children: [
                                textField(
                                  hintText: "Website link (E.g. https://tapzy.in)",
                                  controller: webController,
                                  textInputType: TextInputType.url,
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.link),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Google Review Link (E.g. https://g.page/r/...)",
                                  controller: googleReviewLinkController,
                                  textInputType: TextInputType.url,
                                  suffixIcon: commonSuffixIcon(icon: Icons.star_rounded),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Drive link (E.g. https://drive.google.com)",
                                  controller: driveController,
                                  textInputType: TextInputType.url,
                                  suffixIcon: commonSuffixIcon(icon: Icons.add_to_drive_rounded),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  controller: docController,
                                  hintText: "Document link (E.g. https://doc.google.com)",
                                  textInputType: TextInputType.url,
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.fileCode),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Cloud link (E.g. https://cloud.example.com)",
                                  controller: cloudController,
                                  textInputType: TextInputType.url,
                                  suffixIcon: commonSuffixIcon(icon: Icons.cloud),
                                ),
                                AppUtils.commonSizedBox(height: 20),
                                const Text(
                                  "Make your custom link",
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Custom link label (E.g. Rediff)",
                                  controller: customLinkLabelController,
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.tag),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Custom link (E.g. https://www.rediff.com)",
                                  controller: customLinkController,
                                  textInputType: TextInputType.url,
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.link),
                                ),
                              ],
                            ),
                            _buildGlassCard(
                              title: "Social Media",
                              children: [
                                textField(
                                  hintText: "Twitter (X) username",
                                  controller: twitterController,
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.xTwitter),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  controller: linkedInController,
                                  hintText: "LinkedIn username",
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.linkedinIn),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Facebook username",
                                  controller: fbController,
                                  suffixIcon: commonSuffixIcon(icon: Icons.facebook),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  hintText: "Instagram username",
                                  controller: instaController,
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.instagram),
                                ),
                              ],
                            ),
                            _buildGlassCard(
                              title: "Payment",
                              children: [
                                textField(
                                  controller: gpayController,
                                  hintText: "GPay UPI ID",
                                  suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.googlePay),
                                ),
                                AppUtils.commonSizedBox(height: 10),
                                textField(
                                  controller: paytmController,
                                  hintText: "Paytm UPI ID",
                                  suffixIcon: commonSuffixIcon(isSvg: true, svgPath: "assets/svgs/paytm.svg"),
                                ),
                              ],
                            ),
                            // _buildGlassCard(
                            //   title: "Other Information",
                            //   children: [
                            //     textField(
                            //       controller: eduController,
                            //       hintText: "Education",
                            //       suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.book),
                            //     ),
                            //     AppUtils.commonSizedBox(height: 10),
                            //     textField(
                            //       hintText: "Experience",
                            //       controller: expController,
                            //       suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.peopleGroup),
                            //     ),
                            //     AppUtils.commonSizedBox(height: 10),
                            //     textField(
                            //       hintText: "Hobbies",
                            //       controller: hobController,
                            //       suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.puzzlePiece),
                            //     ),
                            //     AppUtils.commonSizedBox(height: 10),
                            //     textField(
                            //       controller: infoController,
                            //       hintText: "Info",
                            //       suffixIcon: commonSuffixIcon(icon: FontAwesomeIcons.info),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      postMdl.isLoading
                          ? AppUtils.loaderWidget(
                              color: AppColors.colorPurpleLight)
                          : AppUtils.commonSizedBox()
                    ],
                  ),
                  postMdl.isLoading
                      ? AppUtils.loaderWidget()
                      : AppUtils.commonSizedBox()
                ],
              ),
            ),
            ),
          );
  }

  Widget commonSuffixIcon({dynamic icon, bool? isSvg, String? svgPath}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.colorPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: isSvg ?? false
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                svgPath ?? '',
                height: 12,
                width: 12,
                clipBehavior: Clip.antiAlias,
                fit: BoxFit.cover,
                color: AppColors.colorPurpleLight,
              ),
            )
          : (icon?.fontPackage == 'font_awesome_flutter'
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FaIcon(icon, size: 14, color: AppColors.colorPurpleLight),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon, size: 14, color: AppColors.colorPurpleLight),
                )),
    );
  }

  Widget _buildGlassCard({String? title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12), blurRadius: 12)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.colorWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: StringUtils.fontFamilyHeading,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textField({
    String? labelText,
    double? labelFontSize,
    int? minLines,
    int? maxLines,
    double? hintFontSize,
    double? inputTextFontSize,
    Color? labelTextColor,
    Color? hintTextColor,
    Widget? suffixIcon,
    Color? cursorColor,
    Color? enabledBorderColor,
    Color? inputTextColor,
    TextInputType? textInputType,
    String? fontFamily,
    String? labelFontFamily,
    String? hintFontFamily,
    TextEditingController? controller,
    Function(String)? onChanged,
    String? hintText,
    double? letterSpacing,
    BoxConstraints? suffixIconConstraints,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        readOnly: widget.isView ?? false ? true : false,
        maxLines: maxLines ?? 1,
        minLines: minLines ?? 1,
        onChanged: onChanged,
        controller: controller,
        style: TextStyle(
          letterSpacing: letterSpacing,
          color: inputTextColor ?? Colors.white,
          fontSize: inputTextFontSize ?? 14,
          fontFamily: fontFamily,
        ),
        keyboardType: textInputType ?? TextInputType.text,
        cursorColor: cursorColor ?? AppColors.colorPurple,
        decoration: InputDecoration(
          suffixIconConstraints: suffixIconConstraints ?? BoxConstraints(minHeight: 40, minWidth: 40),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          alignLabelWithHint: true,
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(
              color: hintTextColor ?? Colors.white.withOpacity(0.4),
              fontSize: hintFontSize ?? 13,
              fontFamily: hintFontFamily),
          labelStyle: TextStyle(
              color: labelTextColor ?? Colors.white.withOpacity(0.7),
              fontSize: labelFontSize ?? 13,
              fontFamily: labelFontFamily),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top-left orb
    paint.color = AppColors.colorPurple.withOpacity(0.2);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.15),
      size.width * 0.4,
      paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
    );

    // Bottom-right orb
    paint.color = AppColors.colorPurple.withOpacity(0.15);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.8),
      size.width * 0.5,
      paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100),
    );

    // Center-left orb
    paint.color = AppColors.colorPurpleLight.withOpacity(0.1);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.5),
      size.width * 0.3,
      paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
