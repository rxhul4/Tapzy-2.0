import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/models/disable_enable_card_model.dart';
import 'package:tapzy/models/get_digital_card_model.dart';
import 'package:tapzy/models/link_card_model.dart';


class DashboardProvider with ChangeNotifier {

  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;



  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

DisableEnableCardModel? disableEnableCardModel;
GetDigitalCardModel? getDigitalCardModel;
LinkCardModel? linkCardModel ;



  Future<DisableEnableCardModel?> callDisableEnableApi(
      String card_id,String card_type) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "card_id": card_id,
      "card_type" : card_type.toLowerCase()
    };
    try {
      String endPoint = ApiConstants.disableDigitalCard;
      var response = await callPostMethod(endPoint, body);
      disableEnableCardModel = DisableEnableCardModel.fromJson(json.decode(response));
      print("beforeIf ${disableEnableCardModel?.isSuccessful}");
      if (disableEnableCardModel != null && disableEnableCardModel?.isSuccessful == 1) {
        print("InIf ${disableEnableCardModel?.isSuccessful}");

      } else {
        print("inElse ${disableEnableCardModel?.isSuccessful}");

        disableEnableCardModel =
            DisableEnableCardModel(isSuccessful: 0, message: 'Internal Server Issue');
      }

    } catch (e) {
      print("inCatch ${disableEnableCardModel?.isSuccessful}");
      print("inCatchE ${e}");

      disableEnableCardModel =
          DisableEnableCardModel(isSuccessful: 0, message: 'Internal Server Issue');

    }
    _isLoading = false;
    notifyListeners();
    return disableEnableCardModel;
  }




  Future<GetDigitalCardModel?> callGetDigitalCardsApi() async {
    _isFetching = true;
    notifyListeners();
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      "user_id": userId
    };
    try {
      String endPoint = ApiConstants.getDigitalCard;
      var response = await callPostMethod(endPoint, body);
      getDigitalCardModel = GetDigitalCardModel.fromJson(json.decode(response));
      print("beforeIf ${getDigitalCardModel?.isSuccessful}");
      if (getDigitalCardModel != null && getDigitalCardModel?.isSuccessful == 1) {
        print("InIf ${getDigitalCardModel?.isSuccessful}");

      } else {
        print("inElse ${getDigitalCardModel?.isSuccessful}");

        getDigitalCardModel =
            GetDigitalCardModel(isSuccessful: 0, message: 'Internal Server Issue');
      }

    } catch (e) {
      print("inCatch ${getDigitalCardModel?.isSuccessful}");
      print("inCatchE ${e}");

      getDigitalCardModel =
          GetDigitalCardModel(isSuccessful: 0, message: 'Internal Server Issue');

    }
    _isFetching = false;
    notifyListeners();
    return getDigitalCardModel;
  }

  Future<LinkCardModel?> callLinkQrPhysicalCardApi(String cardNo,String cardType,String cardLink,String profileID) async {
    _isUploading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "card_no":cardNo,
      "card_type":cardType,
      "card_link":cardLink,
      "profile_id":profileID
    };
    try {
      String endPoint = ApiConstants.linkCard;
      var response = await callPostMethod(endPoint, body);
      linkCardModel = LinkCardModel.fromJson(json.decode(response));
      print("beforeIf ${linkCardModel?.isSuccessful}");
      if (linkCardModel != null && linkCardModel?.isSuccessful == 1) {
        print("InIf ${linkCardModel?.isSuccessful}");

      } else {
        print("inElse ${linkCardModel?.isSuccessful}");

        linkCardModel =
            LinkCardModel(isSuccessful: 0, message: 'Internal Server Issue');
      }

    } catch (e) {
      print("inCatch ${linkCardModel?.isSuccessful}");
      print("inCatchE ${e}");

      linkCardModel =
          LinkCardModel(isSuccessful: 0, message: 'Internal Server Issue');

    }
    _isUploading = false;
    notifyListeners();
    return linkCardModel;
  }

}
