import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/models/get_shared_contacts_model.dart';
import 'package:tapzy/models/scanned_contact.dart';
import 'package:tapzy/models/scan_paper_card_model.dart';
import 'package:tapzy/models/edit_shared_contact_model.dart';

class ScanConnectProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isPaginating = false;

  // Contacts
  List<ScannedContact> _allContacts = [];
  List<ScannedContact> _scannedContacts = [];
  List<ScannedContact> _receivedContacts = [];

  List<ScannedContact> get allContacts => _allContacts;
  List<ScannedContact> get scannedContacts => _scannedContacts;
  List<ScannedContact> get receivedContacts => _receivedContacts;

  // Pagination states
  int allCurrentPage = 1;
  int allTotalPage = 1;
  
  int scannedCurrentPage = 1;
  int scannedTotalPage = 1;
  
  int receivedCurrentPage = 1;
  int receivedTotalPage = 1;

  ScanConnectProvider() {
    // _init is handled by UI passing filter 'all'
  }

  Future<void> fetchSharedContacts({
    required String filter,
    bool isLoadMore = false,
    String? searchKeyword,
  }) async {
    int currentPage = 1;

    if (filter == 'all') {
      if (isLoadMore) {
        if (allCurrentPage >= allTotalPage) return;
        currentPage = allCurrentPage + 1;
      } else {
        allCurrentPage = 1;
      }
    } else if (filter == 'scanned') {
      if (isLoadMore) {
        if (scannedCurrentPage >= scannedTotalPage) return;
        currentPage = scannedCurrentPage + 1;
      } else {
        scannedCurrentPage = 1;
      }
    } else if (filter == 'received') {
      if (isLoadMore) {
        if (receivedCurrentPage >= receivedTotalPage) return;
        currentPage = receivedCurrentPage + 1;
      } else {
        receivedCurrentPage = 1;
      }
    }

    if (isLoadMore) {
      isPaginating = true;
    } else {
      isLoading = true;
    }
    notifyListeners();

    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    
    Map<String, dynamic> body = {
      "user_id": userId.toString(),
      "search_keyword": searchKeyword ?? "",
      "filters": filter,
      "page_no": currentPage.toString()
    };

    try {
      String endPoint = ApiConstants.getSharedContacts;
      var response = await callPostMethod(endPoint, body);
      GetSharedContactsModel model = GetSharedContactsModel.fromJson(json.decode(response));

      if (model.isSuccessful == 1 && model.data != null) {
        List<ScannedContact> fetchedContacts = [];
        if (model.data?.connections != null) {
          fetchedContacts = model.data!.connections!.map((c) {
            DateTime parsedDate = DateTime.now();
            if (c.createdAt != null) {
              try {
                String dateStr = c.createdAt!.trim();
                dateStr = dateStr.replaceAll(' ', 'T');
                if (!dateStr.endsWith('Z') && !dateStr.contains(RegExp(r'[+-]\d\d:?\d\d$'))) {
                  dateStr = '${dateStr}Z';
                }
                parsedDate = DateTime.parse(dateStr).toLocal();
              } catch (_) {
                try {
                  parsedDate = DateTime.parse(c.createdAt!).toLocal();
                } catch (_) {}
              }
            }
            return ScannedContact(
              id: c.id.toString(),
              name: c.name ?? 'Unknown',
              phone: c.phone,
              email: c.email,
              company: c.company,
              address: c.address,
              source: (c.tag?.toLowerCase() == 'scanned')
                  ? ContactSource.scanned
                  : ContactSource.received,
              dateTime: parsedDate,
            );
          }).toList();
        }

        if (filter == 'all') {
          allCurrentPage = model.data?.currentPage ?? 1;
          allTotalPage = model.data?.totalPage ?? 1;
          if (isLoadMore) {
            _allContacts.addAll(fetchedContacts);
          } else {
            _allContacts = fetchedContacts;
          }
        } else if (filter == 'scanned') {
          scannedCurrentPage = model.data?.currentPage ?? 1;
          scannedTotalPage = model.data?.totalPage ?? 1;
          if (isLoadMore) {
            _scannedContacts.addAll(fetchedContacts);
          } else {
            _scannedContacts = fetchedContacts;
          }
        } else if (filter == 'received') {
          receivedCurrentPage = model.data?.currentPage ?? 1;
          receivedTotalPage = model.data?.totalPage ?? 1;
          if (isLoadMore) {
            _receivedContacts.addAll(fetchedContacts);
          } else {
            _receivedContacts = fetchedContacts;
          }
        }
      }
    } catch (e) {
      print("Error fetching shared contacts: $e");
    }

    isLoading = false;
    isPaginating = false;
    notifyListeners();
  }

  // Edit/Delete mappings - leaving local actions intact but user may refresh via pull-to-refresh
  void saveContact(ScannedContact contact) {
    // Find and update if exists locally
    for (var list in [_allContacts, _scannedContacts, _receivedContacts]) {
      int index = list.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        list[index] = contact;
      }
    }
    notifyListeners();
  }

  Future<void> deleteScannedContact(String id) async {
    try {
      var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
      Map<String, dynamic> body = {
        "contact_id": id,
        "user_id": userId.toString(),
      };
      String endPoint = ApiConstants.deleteSharedContact;
      var response = await callPostMethod(endPoint, body);
      var decoded = json.decode(response);

      if (decoded['isSuccessful'] == 1 || decoded['isSuccessful'] == true) {
        _allContacts.removeWhere((c) => c.id == id);
        _scannedContacts.removeWhere((c) => c.id == id);
        _receivedContacts.removeWhere((c) => c.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Error deleting shared contact: $e");
    }
  }

  Future<ScanPaperCardModel> scanPaperCard({
    required List<String> frontOcr,
    required List<String> backOcr,
  }) async {
    var userIdString = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    int userId = int.tryParse(userIdString ?? "") ?? 0;

    Map<String, dynamic> body = {
      "user_id": userId,
      "tag": "Scanned",
      "front_ocr": frontOcr,
      "back_ocr": backOcr,
    };

    try {
      String endPoint = ApiConstants.scanPaperCard;
      var response = await callPostJsonMethod(endPoint, body);
      return ScanPaperCardModel.fromJson(json.decode(response));
    } catch (e) {
      print("Error scanning paper card: $e");
      return ScanPaperCardModel(
        isSuccessful: 0,
        message: "An error occurred while connecting to the server.",
      );
    }
  }

  Future<EditSharedContactModel> editSharedContact({
    required int contactId,
    required String name,
    required String company,
    required String email,
    required String phone,
    required String address,
  }) async {
    Map<String, dynamic> body = {
      "contact_id": contactId,
      "name": name,
      "company": company,
      "email": email,
      "phone": phone,
      "address": address,
    };

    try {
      String endPoint = ApiConstants.editSharedContact;
      var response = await callPostJsonMethod(endPoint, body);
      return EditSharedContactModel.fromJson(json.decode(response));
    } catch (e) {
      print("Error editing shared contact: $e");
      return EditSharedContactModel(
        isSuccessful: 0,
        message: "An error occurred while connecting to the server.",
      );
    }
  }
}
