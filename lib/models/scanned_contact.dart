import 'dart:convert';

enum ContactSource { scanned, received }

class ScannedContact {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? company;
  final String? designation;
  final String? address;
  final ContactSource source;
  final DateTime dateTime;

  ScannedContact({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.company,
    this.designation,
    this.address,
    required this.source,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'company': company,
        'designation': designation,
        'address': address,
        'source': source.name,
        'dateTime': dateTime.toIso8601String(),
      };

  factory ScannedContact.fromJson(Map<String, dynamic> json) => ScannedContact(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        email: json['email'],
        company: json['company'],
        designation: json['designation'],
        address: json['address'],
        source: ContactSource.values.firstWhere((e) => e.name == json['source'],
            orElse: () => ContactSource.scanned),
        dateTime: DateTime.parse(json['dateTime']),
      );

  ScannedContact copyWith({
    String? name,
    String? phone,
    String? email,
    String? company,
    String? designation,
    String? address,
  }) =>
      ScannedContact(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        company: company ?? this.company,
        designation: designation ?? this.designation,
        address: address ?? this.address,
        source: source,
        dateTime: dateTime,
      );

  static String encodeList(List<ScannedContact> list) =>
      jsonEncode(list.map((c) => c.toJson()).toList());

  static List<ScannedContact> decodeList(String raw) {
    final list = jsonDecode(raw) as List;
    return list.map((e) => ScannedContact.fromJson(e)).toList();
  }
}
