import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/models/add_business_model.dart';
import 'package:tapzy/models/add_social_profile_model.dart';
import 'package:tapzy/models/delete_card_model.dart';
import 'package:tapzy/models/edit_business_card_model.dart';
import 'package:tapzy/models/get_business_card_by_id_model.dart';
import 'package:tapzy/models/get_digital_card_model.dart';
import 'package:http/http.dart' as http;

class ProfilesProvider with ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  DeleteCardModel? deleteCardModel;
  AddSocialSocialModel? addSocialSocialModel;
  AddBusinessModel? addBusinessModel;
  EditBusinessCardModel? editBusinessCardModel;
  GetDigitalCardModel? getDigitalCardModel;
  GetBusinessCardByIdModel? getBusinessCardByIdModel;

  Future<GetDigitalCardModel?> callGetDigitalCardsApiProfiles() async {
    _isFetching = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {"user_id": userId, "profile_primary_color": ""};
    try {
      String endPoint = ApiConstants.getDigitalCard;
      var response = await callPostMethod(endPoint, body);
      getDigitalCardModel = GetDigitalCardModel.fromJson(json.decode(response));
      print("beforeIf ${getDigitalCardModel?.isSuccessful}");
      if (getDigitalCardModel != null &&
          getDigitalCardModel?.isSuccessful == 1) {
        print("InIf ${getDigitalCardModel?.isSuccessful}");
      } else {
        print("inElse ${getDigitalCardModel?.isSuccessful}");

        getDigitalCardModel = GetDigitalCardModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${getDigitalCardModel?.isSuccessful}");
      print("inCatchE ${e}");

      getDigitalCardModel = GetDigitalCardModel(
          isSuccessful: 0, message: 'Internal Server Issue');
    }
    _isFetching = false;
    notifyListeners();
    return getDigitalCardModel;
  }

  Future<DeleteCardModel?> callDeleteCardApi(String cardId, String card_type) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {"card_id": cardId, "card_type": card_type.toLowerCase()};
    try {
      String endPoint = ApiConstants.deleteCardApi;
      var response = await callPostMethod(endPoint, body);
      deleteCardModel = DeleteCardModel.fromJson(json.decode(response));
      print("beforeIf ${deleteCardModel?.isSuccessful}");
      if (deleteCardModel != null) {
        print("InIf ${deleteCardModel?.isSuccessful}");
      } else {
        print("inElse ${deleteCardModel?.isSuccessful}");

        deleteCardModel =
            DeleteCardModel(isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${deleteCardModel?.isSuccessful}");
      print("inCatchE ${e}");

      deleteCardModel =
          DeleteCardModel(isSuccessful: 0, message: 'Internal Server Issue');
    }
    _isLoading = false;
    notifyListeners();
    return deleteCardModel;
  }

  Future<AddSocialSocialModel?> callAddSocialProfile(
      String social_username_link,
      String social_type,
      String card_label) async {
    _isLoading = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      "user_id": userId,
      "social_type": social_type.toLowerCase(),
      "social_username_link": social_username_link,
      "card_label": card_label,
    };
    try {
      String endPoint = ApiConstants.addSocialProfile;
      var response = await callPostMethod(endPoint, body);
      addSocialSocialModel =
          AddSocialSocialModel.fromJson(json.decode(response));
      print("beforeIf ${addSocialSocialModel?.isSuccessful}");
      if (addSocialSocialModel != null) {
        print("InIf ${addSocialSocialModel?.isSuccessful}");
      } else {
        print("inElse ${addSocialSocialModel?.isSuccessful}");

        addSocialSocialModel = AddSocialSocialModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${addSocialSocialModel?.isSuccessful}");
      print("inCatchE ${e}");

      addSocialSocialModel = AddSocialSocialModel(
          isSuccessful: 0, message: 'Internal Server Issue');
    }
    _isLoading = false;
    notifyListeners();
    return addSocialSocialModel;
  }

  Future<EditBusinessCardModel?> callEditBusinessApiWithoutImage({
    String? business_user_name,
    String? industry,
    String? designation,
    String? company,
    String? bio,
    String? services,
    String? business_contact_1,
    String? business_contact_2,
    String? business_contact_3,
    String? business_email,
    String? business_wp_number,
    String? business_messanger_id,
    String? addressLine1,
    String? addressLine2,
    String? addressLine3,
    String? website_links,
    String? drive_link,
    String? doc_link,
    String? cloud_link,
    String? skype_username,
    String? hangouts_username,
    String? twitter_username,
    String? linkedin_username,
    String? facebook_username,
    String? instagram_username,
    String? custom_link,
    String? custom_link_label,
    String? gpay_number_upi,
    // String? paypal_number_upi,
    String? paytm_number_upi,
    String? education_detail,
    String? experience_detail,
    String? hobbies_detail,
    String? info_detail,
    String? business_email_2,
    String? business_id,
    String? card_label,
    String? profile_primary_color,
    String? username,
    String? google_review_link,
  }) async {
    _isLoading = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      'business_id': business_id,
      // 'profile_image':profile_image,
      'user_id': userId,
      "card_label": card_label,
      'business_user_name': business_user_name,
      'industry': industry,
      'designation': designation,
      'company': company,
      'bio': bio,
      'services': services,
      'business_contact_1': business_contact_1,
      'business_contact_2': business_contact_2,
      'business_contact_3': business_contact_3,
      'business_email': business_email,
      'business_email_2 ': business_email_2,
      'business_wp_number': business_wp_number,
      'business_messanger_id': business_messanger_id,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'address_line_3': addressLine3,
      'website_links': website_links,
      'drive_link': drive_link,
      'doc_link': doc_link,
      'cloud_link': cloud_link,
      'skype_username': skype_username,
      'hangouts_username': hangouts_username,
      'twitter_username': twitter_username,
      'linkedin_username': linkedin_username,
      'facebook_username': facebook_username,
      'instagram_username': instagram_username,
      'custom_link': custom_link,
      'custom_link_label': custom_link_label,
      'gpay_number_upi': gpay_number_upi,
      // 'paypal_number_upi': paypal_number_upi,
      'paytm_number_upi': paytm_number_upi,
      'education_detail': education_detail,
      'experience_detail': experience_detail,
      'hobbies_detail': hobbies_detail,
      'info_detail': info_detail,
      'profile_primary_color': profile_primary_color,
      'username': username,
      'google_review_link': google_review_link,
    };
    try {
      String endPoint = ApiConstants.editBusinessProfile;
      var response = await callPostMethod(endPoint, body);
      editBusinessCardModel =
          EditBusinessCardModel.fromJson(json.decode(response));
      print("beforeIf ${editBusinessCardModel?.isSuccessful}");
      if (editBusinessCardModel != null) {
        print("InIf ${editBusinessCardModel?.isSuccessful}");
      } else {
        print("inElse ${editBusinessCardModel?.isSuccessful}");

        editBusinessCardModel = EditBusinessCardModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${editBusinessCardModel?.isSuccessful}");
      print("inCatchE ${e}");

      editBusinessCardModel = EditBusinessCardModel(
          isSuccessful: 0, message: 'Internal Server Issue');
    }
    _isLoading = false;
    notifyListeners();
    return editBusinessCardModel;
  }

  Future<EditBusinessCardModel?> callEditBusinessApi({
    File? imageFile,
    File? companyLogoFile,
    String? business_user_name,
    String? industry,
    String? designation,
    String? company,
    String? bio,
    String? services,
    String? business_contact_1,
    String? business_contact_2,
    String? business_contact_3,
    String? business_email,
    String? business_wp_number,
    String? business_messanger_id,
    String? addressLine1,
    String? addressLine2,
    String? addressLine3,
    String? website_links,
    String? drive_link,
    String? doc_link,
    String? cloud_link,
    String? skype_username,
    String? hangouts_username,
    String? twitter_username,
    String? linkedin_username,
    String? facebook_username,
    String? instagram_username,
    String? custom_link,
    String? custom_link_label,
    String? gpay_number_upi,
    // String? paypal_number_upi,
    String? paytm_number_upi,
    String? education_detail,
    String? experience_detail,
    String? hobbies_detail,
    String? info_detail,
    String? business_email_2,
    String? business_id,
    String? card_label,
    String? profile_primary_color,
    String? username,
    String? google_review_link,
  }) async {
    //print('========sa==${imageFile?.path.toString()}');
    _isLoading = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse(ApiConstants.editBusinessProfile));
      String? token = PreferenceHelper.getString(PreferenceHelper.AUTH_TOKEN);
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (imageFile != null && imageFile.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
            "profile_image", imageFile.path));
      } else {
        request.fields['profile_image'] = '';
      }

      if (companyLogoFile != null && companyLogoFile.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
            "company_logo", companyLogoFile.path));
      }

      request.fields['user_id'] = userId ?? '';
      request.fields['business_user_name'] = business_user_name.toString();
      request.fields['industry'] = industry.toString();
      request.fields['card_label'] = card_label.toString();
      request.fields['company'] = company.toString();
      request.fields['designation'] = designation.toString();
      request.fields['business_id'] = business_id.toString();
      request.fields['bio'] = bio.toString();
      request.fields['services'] = services.toString();
      request.fields['business_contact_1'] = business_contact_1.toString();
      request.fields['business_contact_2'] = business_contact_2.toString();
      request.fields['business_contact_3'] = business_contact_3.toString();
      request.fields['business_email'] = business_email.toString();
      request.fields['business_wp_number'] = business_wp_number.toString();
      request.fields['business_messanger_id'] =
          business_messanger_id.toString();
      request.fields['address_line_1'] = addressLine1.toString();
      request.fields['address_line_2'] = addressLine2.toString();
      request.fields['address_line_3'] = addressLine3.toString();
      request.fields['website_links'] = website_links.toString();
      request.fields['drive_link'] = drive_link.toString();
      request.fields['doc_link'] = doc_link.toString();
      request.fields['cloud_link'] = cloud_link.toString();
      request.fields['skype_username'] = skype_username.toString();
      request.fields['hangouts_username'] = hangouts_username.toString();
      request.fields['twitter_username'] = twitter_username.toString();
      request.fields['linkedin_username'] = linkedin_username.toString();
      request.fields['facebook_username'] = facebook_username.toString();
      request.fields['instagram_username'] = instagram_username.toString();
      request.fields['custom_link'] = custom_link.toString();
      request.fields['custom_link_label'] = custom_link_label.toString();
      request.fields['gpay_number_upi'] = gpay_number_upi.toString();
      // request.fields['paypal_number_upi'] = paypal_number_upi.toString();
      request.fields['paytm_number_upi'] = paytm_number_upi.toString();
      request.fields['education_detail'] = education_detail.toString();
      request.fields['experience_detail'] = experience_detail.toString();
      request.fields['hobbies_detail'] = hobbies_detail.toString();
      request.fields['info_detail'] = info_detail.toString();
      request.fields['business_email_2'] = business_email_2.toString();
      request.fields['profile_primary_color'] = profile_primary_color.toString();
      request.fields['username'] = username ?? '';
      request.fields['google_review_link'] = google_review_link ?? '';

      print("request is ${request.fields}");
      var response = await request.send();
      print('---------response$response');
      var responsed = await http.Response.fromStream(response);
      print("SUCCESS  ${responsed.body}");
      // final responseData = json.decode(responsed.body);

      if (response.statusCode == 200) {
        editBusinessCardModel =
            EditBusinessCardModel.fromJson(json.decode(responsed.body));
      } else {
        print("inElse ${editBusinessCardModel?.isSuccessful}");

        editBusinessCardModel = EditBusinessCardModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${editBusinessCardModel?.isSuccessful}");
      print("inCatchE ${e}");

      editBusinessCardModel = EditBusinessCardModel(
          isSuccessful: 0, message: 'Internal Server Issue');
    }

    _isLoading = false;
    notifyListeners();
    return editBusinessCardModel;
  }

  Future<AddBusinessModel?> callAddBusinessApiWithoutImage({
    String? business_user_name,
    String? industry,
    String? designation,
    String? company,
    String? bio,
    String? services,
    String? business_contact_1,
    String? business_contact_2,
    String? business_contact_3,
    String? business_email,
    String? business_wp_number,
    String? business_messanger_id,
    String? addressLine1,
    String? addressLine2,
    String? addressLine3,
    String? website_links,
    String? drive_link,
    String? doc_link,
    String? cloud_link,
    String? skype_username,
    String? hangouts_username,
    String? twitter_username,
    String? linkedin_username,
    String? facebook_username,
    String? instagram_username,
    String? custom_link,
    String? custom_link_label,
    String? gpay_number_upi,
    // String? paypal_number_upi,
    String? paytm_number_upi,
    String? education_detail,
    String? experience_detail,
    String? hobbies_detail,
    String? info_detail,
    String? business_email_2,
    String? card_label,
    String? profile_primary_color,
    String? username,
    String? google_review_link,
  }) async {
    _isLoading = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      // 'profile_image':profile_image,
      'user_id': userId,
      "card_label": card_label,
      'business_user_name': business_user_name,
      'industry': industry,
      'designation': designation,
      'company': company,
      'bio': bio,
      'services': services,
      'business_contact_1': business_contact_1,
      'business_contact_2': business_contact_2,
      'business_contact_3': business_contact_3,
      'business_email': business_email,
      'business_email_2 ': business_email_2,
      'business_wp_number': business_wp_number,
      'business_messanger_id': business_messanger_id,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'address_line_3': addressLine3,
      'website_links': website_links,
      'drive_link': drive_link,
      'doc_link': doc_link,
      'cloud_link': cloud_link,
      'skype_username': skype_username,
      'hangouts_username': hangouts_username,
      'twitter_username': twitter_username,
      'linkedin_username': linkedin_username,
      'facebook_username': facebook_username,
      'instagram_username': instagram_username,
      'custom_link': custom_link,
      'custom_link_label': custom_link_label,
      'gpay_number_upi': gpay_number_upi,
      // 'paypal_number_upi': paypal_number_upi,
      'paytm_number_upi': paytm_number_upi,
      'education_detail': education_detail,
      'experience_detail': experience_detail,
      'hobbies_detail': hobbies_detail,
      'info_detail': info_detail,
      'profile_primary_color': profile_primary_color,
      'username': username,
      'google_review_link': google_review_link,
    };
    try {
      String endPoint = ApiConstants.addBusinessProfile;
      var response = await callPostMethod(endPoint, body);
      addBusinessModel = AddBusinessModel.fromJson(json.decode(response));
      print("beforeIf ${addBusinessModel?.isSuccessful}");
      if (addBusinessModel != null) {
        print("InIf ${addBusinessModel?.isSuccessful}");
      } else {
        print("inElse ${addBusinessModel?.isSuccessful}");

        addBusinessModel =
            AddBusinessModel(isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${addBusinessModel?.isSuccessful}");
      print("inCatchE ${e}");

      addBusinessModel =
          AddBusinessModel(isSuccessful: 0, message: 'Internal Server Issue');
    }
    _isLoading = false;
    notifyListeners();
    return addBusinessModel;
  }

  Future<AddBusinessModel?> callAddBusinessApi({
    File? imageFile,
    File? companyLogoFile,
    String? business_user_name,
    String? industry,
    String? designation,
    String? company,
    String? bio,
    String? services,
    String? business_contact_1,
    String? business_contact_2,
    String? business_contact_3,
    String? business_email,
    String? business_wp_number,
    String? business_messanger_id,
    String? addressLine1,
    String? addressLine2,
    String? addressLine3,
    String? website_links,
    String? drive_link,
    String? doc_link,
    String? cloud_link,
    String? skype_username,
    String? hangouts_username,
    String? twitter_username,
    String? linkedin_username,
    String? facebook_username,
    String? instagram_username,
    String? custom_link,
    String? custom_link_label,
    String? gpay_number_upi,
    // String? paypal_number_upi,
    String? paytm_number_upi,
    String? education_detail,
    String? experience_detail,
    String? hobbies_detail,
    String? info_detail,
    String? business_email_2,
    String? card_label,
    String? profile_primary_color,
    String? username,
    String? google_review_link,
  }) async {
    //print('========sa==${imageFile?.path.toString()}');
    _isLoading = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse(ApiConstants.addBusinessProfile));
      String? token = PreferenceHelper.getString(PreferenceHelper.AUTH_TOKEN);
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (imageFile != null && imageFile.path.toString().isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
            "profile_image", imageFile.path));
      } else {
        request.fields['profile_image'] = '';
      }

      if (companyLogoFile != null && companyLogoFile.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
            "company_logo", companyLogoFile.path));
      }

      request.fields['user_id'] = userId ?? '';
      request.fields['business_user_name'] = business_user_name.toString();
      request.fields['industry'] = industry.toString();
      request.fields['card_label'] = card_label.toString();
      request.fields['designation'] = designation.toString();
      request.fields['company'] = company.toString();
      request.fields['bio'] = bio.toString();
      request.fields['services'] = services.toString();
      request.fields['business_contact_1'] = business_contact_1.toString();
      request.fields['business_contact_2'] = business_contact_2.toString();
      request.fields['business_contact_3'] = business_contact_3.toString();
      request.fields['business_email'] = business_email.toString();
      request.fields['business_wp_number'] = business_wp_number.toString();
      request.fields['business_messanger_id'] =
          business_messanger_id.toString();
      request.fields['address_line_1'] = addressLine1.toString();
      request.fields['address_line_2'] = addressLine2.toString();
      request.fields['address_line_3'] = addressLine3.toString();
      request.fields['website_links'] = website_links.toString();
      request.fields['drive_link'] = drive_link.toString();
      request.fields['doc_link'] = doc_link.toString();
      request.fields['cloud_link'] = cloud_link.toString();
      request.fields['skype_username'] = skype_username.toString();
      request.fields['hangouts_username'] = hangouts_username.toString();
      request.fields['twitter_username'] = twitter_username.toString();
      request.fields['linkedin_username'] = linkedin_username.toString();
      request.fields['facebook_username'] = facebook_username.toString();
      request.fields['instagram_username'] = instagram_username.toString();
      request.fields['custom_link'] = custom_link.toString();
      request.fields['custom_link_label'] = custom_link_label.toString();
      request.fields['gpay_number_upi'] = gpay_number_upi.toString();
      // request.fields['paypal_number_upi'] = paypal_number_upi.toString();
      request.fields['paytm_number_upi'] = paytm_number_upi.toString();
      request.fields['education_detail'] = education_detail.toString();
      request.fields['experience_detail'] = experience_detail.toString();
      request.fields['hobbies_detail'] = hobbies_detail.toString();
      request.fields['info_detail'] = info_detail.toString();
      request.fields['business_email_2'] = business_email_2.toString();
      request.fields['profile_primary_color'] = profile_primary_color.toString();
      request.fields['username'] = username ?? '';
      request.fields['google_review_link'] = google_review_link ?? '';

      print("request is ${request.fields}");
      var response = await request.send();
      print('---------response$response');
      var responsed = await http.Response.fromStream(response);
      print("SUCCESS  ${responsed.body}");
      // final responseData = json.decode(responsed.body);

      if (response.statusCode == 200) {
        addBusinessModel =
            AddBusinessModel.fromJson(json.decode(responsed.body));
      } else {
        print("inElse ${addBusinessModel?.isSuccessful}");

        addBusinessModel =
            AddBusinessModel(isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${addBusinessModel?.isSuccessful}");
      print("inCatchE ${e}");

      addBusinessModel =
          AddBusinessModel(isSuccessful: 0, message: 'Internal Server Issue');
    }

    _isLoading = false;
    notifyListeners();
    return addBusinessModel;
  }

  Future<GetBusinessCardByIdModel?> callGetBusinessCardsByIdApi(
      String profile_id) async {
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {"profile_id": profile_id};
    try {
      String endPoint = ApiConstants.getBusinessProfile;
      var response = await callPostMethod(endPoint, body);
      getBusinessCardByIdModel =
          GetBusinessCardByIdModel.fromJson(json.decode(response));
      print("beforeIf ${getBusinessCardByIdModel?.isSuccessful}");
      if (getBusinessCardByIdModel != null &&
          getBusinessCardByIdModel?.isSuccessful == 1) {
        print("InIf ${getBusinessCardByIdModel?.isSuccessful}");
      } else {
        print("inElse ${getBusinessCardByIdModel?.isSuccessful}");

        getBusinessCardByIdModel = GetBusinessCardByIdModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${getBusinessCardByIdModel?.isSuccessful}");
      print("inCatchE ${e}");

      getBusinessCardByIdModel = GetBusinessCardByIdModel(
          isSuccessful: 0, message: 'Internal Server Issue');
    }
    _isFetching = false;
    notifyListeners();
    return getBusinessCardByIdModel;
  }
}
