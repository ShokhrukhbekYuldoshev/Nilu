import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String phone;
  final String id;
  final String name;
  final String business;
  final String mainCurrency;
  final String secondaryCurrency;
  final dynamic date;
  String? image;
  List categories;

  ProfileModel({
    required this.phone,
    required this.id,
    required this.name,
    required this.business,
    required this.mainCurrency,
    required this.secondaryCurrency,
    required this.date,
    this.image = '',
    this.categories = const [],
  });

  static ProfileModel fromSnapshot(DocumentSnapshot snapshot) {
    ProfileModel profile = ProfileModel(
      phone: snapshot['phone'],
      id: snapshot.id,
      name: snapshot['name'],
      business: snapshot['business'],
      mainCurrency: snapshot['mainCurrency'],
      secondaryCurrency: snapshot['secondaryCurrency'],
      date: snapshot['date'],
      image: snapshot['image'],
      categories: snapshot['categories'] ?? const [],
    );
    return profile;
  }
}
