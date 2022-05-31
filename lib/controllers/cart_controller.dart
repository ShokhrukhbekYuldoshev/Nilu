import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/models/payment_model.dart';
import 'package:nilu/models/product_model.dart';
import 'package:nilu/utils/preferences.dart';

import '../models/client_model.dart';

class CartController extends GetxController {
  // * PRODUCTS
  final _products = <Product>[].obs;
  get products => _products;
  getUniqueProducts() {
    var products = <Product>[];
    for (var product in _products) {
      if (!products.contains(product)) {
        if (product.owner != '') {
          products.add(product);
        }
      }
    }
    return products;
  }

  final productsPriceMap = [].obs;

  double getPrice(String productId) {
    try {
      return productsPriceMap
          .firstWhere((element) => element['id'] == productId)['price'];
    } catch (e) {
      return 0;
    }
  }

  setProducts(List<Product> products, List<dynamic> productsMap) {
    productsPriceMap.value = [];
    for (var product in productsMap) {
      for (int i = 0; i < productsPriceMap.length; i++) {
        if (productsPriceMap[i]['id'] == product['id']) {
          productsPriceMap.remove(productsPriceMap[i]);
        }
      }
      for (int i = 0; i < product['quantity']; i++) {
        productsPriceMap.add({
          'id': product['id'],
          'price': product['price'],
        });
      }
    }
    _products.value = products;
  }

  void clearSingleProduct(Product product) {
    _products.removeWhere((p) => p.id == product.id);
  }

  void clearCart() {
    _products.clear();
  }

  void updateCart(Product product, int count, double price) {
    clearSingleProduct(product);
    for (int i = 0; i < productsPriceMap.length; i++) {
      if (productsPriceMap[i]['id'] == product.id) {
        productsPriceMap.remove(productsPriceMap[i]);
      }
    }
    productsPriceMap.add({
      'id': product.id,
      'price': price,
    });

    for (int i = 0; i < count; i++) {
      _products.add(product);
    }
    payments.clear();
    addPayment(remaining, _profileController.user['mainCurrency']);
  }

  double get productsPrice {
    double price = 0;
    for (var product in productsPriceMap) {
      price += product['price'];
    }

    return price;
  }

  int singleProductQuantity(String productId) {
    return _products.where((p) => p.id == productId).length;
  }

  // * CLIENT
  Client? client;
  void setClient(Client client) {
    this.client = client;
  }

  void clearClient() {
    client = null;
    update();
  }

  // * PAYMENT
  final ProfileController _profileController = Get.find();
  final _payments = <Payment>[].obs;
  get payments => _payments;

  void addPayment(double amount, String currency) {
    if (_payments.length < 4) {
      _payments.add(
        Payment(
          amount: amount,
          currency: currency,
        ),
      );
    }
  }

  double get payment {
    double sum = 0;
    sum += _payments
        .where((payment) =>
            payment.currency == _profileController.user['mainCurrency'])
        .fold(0, (sum, payment) => sum + payment.amount);

    sum += _payments
        .where((payment) =>
            payment.currency == _profileController.user['secondaryCurrency'])
        .fold(
            0,
            (sum, payment) =>
                sum + payment.amount * Preferences.getExchangeRate());
    return sum;
  }

  double get remaining {
    return productsPrice - payment - discount.value;
  }

  void clearPayments() {
    _payments.clear();
  }

  // * COMMENT
  final _comment = ''.obs;
  get comment => _comment.value;
  void setComment(String comment) {
    _comment.value = comment;
  }

  void clearComment() {
    _comment.value = '';
  }

  // * DISCOUNT
  final discount = 0.0.obs;

  void setDiscount(double discount) {
    this.discount.value = discount;
  }

  void clearDiscount() {
    discount.value = 0.0;
    discount.value = 0.0;
  }
}
