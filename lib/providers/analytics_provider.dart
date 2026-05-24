import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/models/analytics_model.dart';

class AnalyticsProvider with ChangeNotifier {
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  AnalyticsModel? _analyticsModel;
  AnalyticsModel? get analyticsModel => _analyticsModel;

  AnalyticsProfile? _selectedProfile;
  AnalyticsProfile? get selectedProfile => _selectedProfile;

  DateTimeRange? _selectedDateRange;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  void setSelectedProfile(AnalyticsProfile? profile) {
    _selectedProfile = profile;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  Future<AnalyticsModel?> fetchAnalytics({int? profileId, String? profileType}) async {
    _isFetching = true;
    notifyListeners();

    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      "user_id": userId,
    };

    if (profileId != null && profileType != null) {
      body["profile_id"] = profileId.toString();
      body["profile_type"] = profileType.toLowerCase();
    }

    if (_selectedDateRange != null) {
      body["start_date"] = _selectedDateRange!.start.toIso8601String().substring(0, 10);
      body["end_date"] = _selectedDateRange!.end.toIso8601String().substring(0, 10);
    }

    try {
      String endPoint = ApiConstants.getAnalytics;
      var response = await callPostMethod(endPoint, body);
      _analyticsModel = AnalyticsModel.fromJson(json.decode(response));

      if (_analyticsModel == null || _analyticsModel?.isSuccessful != true) {
        _analyticsModel = AnalyticsModel(isSuccessful: false, message: 'Failed to fetch analytics data');
      } else {
        _syncSelectedProfileWithLatestData();
      }
    } catch (e) {
      print("Error fetching analytics: $e");
      _analyticsModel = AnalyticsModel(isSuccessful: false, message: 'Internal Server Issue');
    }

    _isFetching = false;
    notifyListeners();
    return _analyticsModel;
  }

  void _syncSelectedProfileWithLatestData() {
    if (_selectedProfile == null) return;
    final profiles = _analyticsModel?.data?.profiles;
    if (profiles == null || profiles.isEmpty) return;

    final match = profiles.where((p) => p == _selectedProfile).toList();
    if (match.isNotEmpty) {
      _selectedProfile = match.first;
    }
  }

  AnalyticsProfile? profileMatchingSelection(List<AnalyticsProfile> profiles) {
    if (_selectedProfile == null) return null;
    for (final profile in profiles) {
      if (profile == _selectedProfile) return profile;
    }
    return null;
  }

  Future<bool> clearAnalytics({int? profileId, String? profileType}) async {
    _isFetching = true;
    notifyListeners();

    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      "user_id": userId,
    };

    if (profileId != null && profileType != null) {
      body["profile_id"] = profileId.toString();
      body["profile_type"] = profileType.toLowerCase();
    }

    try {
      String endPoint = ApiConstants.clearAnalytics;
      var response = await callPostMethod(endPoint, body);
      var responseMap = json.decode(response);

      _isFetching = false;
      notifyListeners();

      if (responseMap != null && responseMap['isSuccessful'] == true) {
        // Refetch empty/reset analytics
        await fetchAnalytics(profileId: profileId, profileType: profileType);
        return true;
      }
      return false;
    } catch (e) {
      print("Error clearing analytics: $e");
      _isFetching = false;
      notifyListeners();
      return false;
    }
  }
}
