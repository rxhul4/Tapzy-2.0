import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/models/get_user_profile_model.dart';
import 'package:tapzy/models/update_user_profile_model.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class UserProfilesProvider with ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  UpdateUserProfileModel? updateUserProfileModel;

  GetUserProfileModel? getUserProfileModel;

  Future<GetUserProfileModel?> callGetUserProfileApi() async {
    _isFetching = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      "user_id": userId,
    };
    try {
      String endPoint = ApiConstants.getUserProfile;
      var response = await callPostMethod(endPoint, body);
      getUserProfileModel = GetUserProfileModel.fromJson(json.decode(response));
      print("beforeIf ${getUserProfileModel?.isSuccessful}");
      if (getUserProfileModel != null &&
          getUserProfileModel?.isSuccessful == 1) {
        print("InIf ${getUserProfileModel?.isSuccessful}");
      } else {
        print("inElse ${getUserProfileModel?.isSuccessful}");

        getUserProfileModel = GetUserProfileModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${getUserProfileModel?.isSuccessful}");
      print("inCatchE ${e}");

      getUserProfileModel = GetUserProfileModel(
          isSuccessful: 0, message: 'Internal Server Issue');
    }
    _isFetching = false;
    notifyListeners();
    return getUserProfileModel;
  }

  Future<UpdateUserProfileModel?> callUpdateUserProfileApi({
    String? first_name,
    String? last_name,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body;
    if (phoneNumber == null) {
      body = {
        "user_id": userId,
        "first_name": first_name,
        "last_name": last_name
      };
    } else {
      body = {
        "user_id": userId,
        "first_name": first_name,
        "last_name": last_name,
        "phone_number": phoneNumber
      };
    }

    try {
      print("updateProfileBody    ${body}");
      String endPoint = ApiConstants.editProfile;
      var response = await callPostMethod(endPoint, body);
      updateUserProfileModel =
          UpdateUserProfileModel.fromJson(json.decode(response));
      print("beforeIf ${updateUserProfileModel?.isSuccessful}");
      if (updateUserProfileModel != null &&
          updateUserProfileModel?.isSuccessful == 1) {
        print("InIf ${updateUserProfileModel?.isSuccessful}");
      } else {
        print("inElse ${updateUserProfileModel?.isSuccessful}");

        updateUserProfileModel = UpdateUserProfileModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${updateUserProfileModel?.isSuccessful}");
      print("inCatchE ${e}");

      updateUserProfileModel = UpdateUserProfileModel(
          isSuccessful: 0, message: 'Internal Server Issue');
    }
    _isLoading = false;
    notifyListeners();
    return updateUserProfileModel;
  }

  Future<UpdateUserProfileModel?> callUpdateUserProfile(
      {File? imageFile,
      String? first_name,
      String? last_name,
      String? phoneNumber,
      required BuildContext context}) async {
    print('========sa==${first_name} , ${last_name}');
    _isUploading = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(ApiConstants.editProfile));
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

      request.fields['user_id'] = userId ?? '';
      request.fields['first_name'] = first_name.toString();
      request.fields['last_name'] = last_name.toString();
      request.fields['phone_number'] = phoneNumber.toString();
      /*   request.fields['name'] = name.toString();
    request.fields['email'] = email.toString();
    request.fields['phone'] = phone.toString();
    request.fields['hide_credit'] = hide_credit.toString();*/
      print("request is ${request.fields}");
      var response = await request.send();
      print('---------response$response');
      var responsed = await http.Response.fromStream(response);
      print("SUCCESS  ${responsed.body}");
      // final responseData = json.decode(responsed.body);

      if (response.statusCode == 200) {
        updateUserProfileModel =
            UpdateUserProfileModel.fromJson(json.decode(responsed.body));
      } else {
        print("inElse ${updateUserProfileModel?.isSuccessful}");

        updateUserProfileModel = UpdateUserProfileModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
    } catch (e) {
      print("inCatch ${updateUserProfileModel?.isSuccessful}");
      print("inCatchE ${e}");

      updateUserProfileModel = UpdateUserProfileModel(
          isSuccessful: 0, message: 'Internal Server Issue');
    }

    _isUploading = false;
    notifyListeners();
    return updateUserProfileModel;
  }
}
