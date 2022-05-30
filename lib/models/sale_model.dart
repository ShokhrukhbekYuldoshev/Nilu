import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String owner;
  final String client;
  final Timestamp date;
  final List<dynamic> products;
  final double price;
  final double payment;
  final double debt;
  final double discount;
  final String comment;

  Sale({
    required this.id,
    required this.client,
    required this.owner,
    required this.date,
    required this.products,
    required this.price,
    required this.payment,
    required this.debt,
    required this.discount,
    required this.comment,
  });

  static Sale fromSnapshot(DocumentSnapshot snapshot) {
    Sale sale = Sale(
      id: snapshot.id,
      owner: snapshot['owner'],
      client: snapshot['client'] as String,
      products: snapshot['products'] as List<dynamic>,
      date: snapshot['date'] as Timestamp,
      price: snapshot['price'] as double,
      payment: snapshot['payment'] as double,
      debt: snapshot['debt'] as double,
      discount: snapshot['discount'] as double,
      comment: snapshot['comment'] as String,
    );
    return sale;
  }
}
