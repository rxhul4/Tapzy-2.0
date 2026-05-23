class GetSharedContactsModel {
  int? isSuccessful;
  int? code;
  String? message;
  SharedContactsData? data;

  GetSharedContactsModel(
      {this.isSuccessful, this.code, this.message, this.data});

  GetSharedContactsModel.fromJson(Map<String, dynamic> json) {
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? SharedContactsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['isSuccessful'] = isSuccessful;
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SharedContactsData {
  List<Connection>? connections;
  int? totalPage;
  int? currentPage;

  SharedContactsData({this.connections, this.totalPage, this.currentPage});

  SharedContactsData.fromJson(Map<String, dynamic> json) {
    if (json['connections'] != null) {
      connections = <Connection>[];
      json['connections'].forEach((v) {
        connections!.add(Connection.fromJson(v));
      });
    }
    totalPage = json['total_page'];
    currentPage = json['current_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (connections != null) {
      data['connections'] = connections!.map((v) => v.toJson()).toList();
    }
    data['total_page'] = totalPage;
    data['current_page'] = currentPage;
    return data;
  }
}

class Connection {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? tag;
  String? createdAt;
  String? company;
  String? address;

  Connection(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.tag,
      this.createdAt,
      this.company,
      this.address});

  Connection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    tag = json['tag'];
    createdAt = json['created_at'];
    company = json['company'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['tag'] = tag;
    data['created_at'] = createdAt;
    data['company'] = company;
    data['address'] = address;
    return data;
  }
}
