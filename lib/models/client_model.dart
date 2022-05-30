import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String owner;
  final String name;
  final String phone;
  final dynamic date;
  final double debt;
  String? note;
  String? image;

  Client({
    required this.id,
    required this.owner,
    required this.name,
    required this.phone,
    required this.date,
    this.debt = 0.0,
    this.note,
    this.image,
  });

  static Client fromSnapshot(DocumentSnapshot snapshot) {
    Client client = Client(
      id: snapshot.id,
      owner: snapshot['owner'],
      name: snapshot['name'],
      phone: snapshot['phone'],
      date: snapshot['date'],
      debt: double.parse(snapshot['debt'].toStringAsFixed(2)),
      note: snapshot['note'],
      image: snapshot['image'],
    );
    return client;
  }
}
