import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String owner, id, name, code;
  final String? category;
  late String? image;
  int? quantity;
  double price;

  Product({
    required this.owner,
    required this.id,
    required this.name,
    required this.code,
    this.category,
    this.image,
    this.quantity = 0,
    required this.price,
  });

  static Product fromSnapshot(DocumentSnapshot snapshot) {
    Product product = Product(
      owner: snapshot['owner'] as String,
      code: snapshot['code'] as String,
      id: snapshot.id,
      name: snapshot['name'] as String,
      category: snapshot['category'] as String?,
      image: snapshot['image'] as String?,
      quantity: snapshot['quantity'] as int,
      price: snapshot['price'],
    );
    return product;
  }
}
