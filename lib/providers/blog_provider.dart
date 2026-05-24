import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/models/blogModel.dart';



class BlogProvider with ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;
  BlogModel? _blogModel;
  BlogModel? get blogModel => _blogModel;
  /*
  LoginModel? _loginModel;
  ProfileModel? _profileModel;



  ProfileModel? get profileModel => _profileModel;
*/

  BlogModel? getBlogList;

  Future<BlogModel?> getBlog(BuildContext context) async {
    _isFetching = true;
    notifyListeners();

    try {
      String endPoint = "https://reqres.in/api/users?page=2";
      var response = await callGetMethod(endPoint);
      final data = jsonDecode(response);
      // getSkillModelList.clear();
      // for (Map<String, dynamic> i in data) {
      //   getSkillModelList.add(GetSkillModel.fromJson(i));
      // }
      getBlogList = BlogModel.fromJson(json.decode(response));
      if (getBlogList != null ) {
      } else {
        print('e');
      }
      // return result;
    } catch (e) {
      print('e1${e}');
    }

    _isFetching = false;
    notifyListeners();
    return getBlogList;
  }


}
