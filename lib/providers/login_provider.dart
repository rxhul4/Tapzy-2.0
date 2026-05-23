import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/core/services/push_notification_service.dart';
import 'package:tapzy/models/login_model.dart';
import 'package:tapzy/models/otp_verify_model.dart';


class LoginProvider with ChangeNotifier {

  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  OtpVerifyModel? _otpVerifyModel;


  OtpVerifyModel? get otpVerifyModel => _otpVerifyModel;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;


  LoginModel ? loginModel;


    Future<LoginModel?> callLoginApi(
      String email) async {
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "email": email
    };
    try {
      String endPoint = ApiConstants.loginApi;
      var response = await callPostMethod(endPoint, body);
       loginModel = LoginModel.fromJson(json.decode(response));
       print("beforeIf ${loginModel?.isSuccessful}");
      if (loginModel != null && loginModel?.data != null) {
        await PreferenceHelper.setBool(
            PreferenceHelper.IS_NEW, loginModel?.data?.isNew == 1 ? true : false);

        print("InIf ${loginModel?.isSuccessful}");

      } else {
        print("inElse ${loginModel?.isSuccessful}");

        loginModel =
        LoginModel(isSuccessful: 0, message: 'Internal Server Issue');
      }

    } catch (e) {
      print("inCatch ${loginModel?.isSuccessful}");
      print("inCatchE ${e}");

      loginModel =
      LoginModel(isSuccessful: 0, message: 'Internal Server Issue');

    }
    _isFetching = false;
    notifyListeners();
    return loginModel;
  }


  Future<OtpVerifyModel?> callOtpVerifyApi(
      String? otp,
      String? email,
      ) async {
    Map<String, dynamic> body = {
      "email":email,
      "otp":otp
    };
    _isLoading = true;
    notifyListeners();

    try {
      String endPoint = ApiConstants.verifyOtp;
      var response = await callPostMethod(endPoint, body);
      _otpVerifyModel = OtpVerifyModel.fromJson(json.decode(response));
      if (_otpVerifyModel != null) {
        await PreferenceHelper.setString(
            PreferenceHelper.USER_ID, _otpVerifyModel?.data?.userId.toString() ?? '');
            
        if (_otpVerifyModel?.data?.authToken != null) {
          await PreferenceHelper.setString(
              PreferenceHelper.AUTH_TOKEN, _otpVerifyModel!.data!.authToken!);
        }
        await PushNotificationService.registerDeviceToken();

      } else {
        _otpVerifyModel = OtpVerifyModel(
            isSuccessful: 0, message: 'Internal Server Issue');
      }
      // return result;
    } catch (e) {
      _otpVerifyModel = OtpVerifyModel(
          isSuccessful: 0, message: 'Internal Server Issue');
      // return result;
    }
    _isLoading = false;
    notifyListeners();
    return _otpVerifyModel;
  }


}
