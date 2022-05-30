import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/models/client_model.dart';
import 'package:nilu/models/sale_model.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class FirestoreDb {
  // * Initialize Firestore
  final ProfileController _profileController = Get.find();

  // * PRODUCT
  Stream<List<Product>> getProducts() {
    return firestore
        .collection('products')
        .where('owner', isEqualTo: _profileController.user['id'])
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList(),
        );
  }

  // * SALE
  Stream<List<Sale>> getSales() {
    return firestore
        .collection('sales')
        .where('owner', isEqualTo: _profileController.user['id'])
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromSnapshot(doc)).toList());
  }

  // * CLIENT
  Stream<List<Client>> getClients() {
    return firestore
        .collection('clients')
        .where('owner', isEqualTo: _profileController.user['id'])
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Client.fromSnapshot(doc)).toList());
  }
}
