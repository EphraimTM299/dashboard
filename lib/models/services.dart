// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Services {
  final String name;
  final double price;

  Services({required this.name, required this.price});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'price': price,
    };
  }

  factory Services.fromMap(Map<String, dynamic> map) {
    return Services(
      name: map['name'] as String,
      price: map['price'].toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Services.fromJson(String source) =>
      Services.fromMap(json.decode(source) as Map<String, dynamic>);
}
