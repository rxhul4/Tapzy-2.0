class GetDigitalCardModel {
  int? isSuccessful;
  int? code;
  String? message;
  Data? data;

  GetDigitalCardModel({this.isSuccessful, this.code, this.message, this.data});

  GetDigitalCardModel.fromJson(Map<String, dynamic> json) {
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isSuccessful'] = this.isSuccessful;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  UserData? userData;
  List<CardData>? cardData;

  Data({this.userData, this.cardData});

  Data.fromJson(Map<String, dynamic> json) {
    userData = json['user_data'] != null
        ? new UserData.fromJson(json['user_data'])
        : null;
    if (json['card_data'] != null) {
      cardData = <CardData>[];
      json['card_data'].forEach((v) {
        cardData!.add(new CardData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userData != null) {
      data['user_data'] = this.userData!.toJson();
    }
    if (this.cardData != null) {
      data['card_data'] = this.cardData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserData {
  String? firstName;
  String? lastName;
  String? profileImage;

  UserData({this.firstName, this.lastName, this.profileImage});

  UserData.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    profileImage = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['profile_image'] = this.profileImage;
    return data;
  }
}

class CardData {
  int? id;
  String? type;
  String? cardImage;
  String? field1;
  String? field2;
  int? isActive;
  String? qrImage;
  String? cardLabel;
  int? isImageSet;

  CardData(
      {this.id,
        this.type,
        this.cardImage,
        this.field1,
        this.field2,
        this.isActive,
        this.qrImage,
        this.cardLabel,
        this.isImageSet
      });

  CardData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    cardImage = json['card_image'];
    field1 = json['field1'];
    field2 = json['field2'];
    isActive = json['isActive'];
    qrImage = json['qr_image'];
    cardLabel = json['card_label'];
    isImageSet = json['is_image_set'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['card_image'] = this.cardImage;
    data['field1'] = this.field1;
    data['field2'] = this.field2;
    data['isActive'] = this.isActive;
    data['qr_image'] = this.qrImage;
    data['card_label'] = this.cardLabel;
    data['is_image_set'] = this.isImageSet;
    return data;
  }
}
