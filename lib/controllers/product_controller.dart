import 'package:get/get.dart';
import 'package:nilu/utils/constants.dart';
import '../models/product_model.dart';
import '../services/firestore_db.dart';

class ProductController extends GetxController {
  @override
  void onInit() {
    try {
      products.bindStream(FirestoreDb().getProducts());
      searchProducts.value = products;
      filteredProducts.value = products;
      // ignore: empty_catches
    } catch (e) {}
    super.onInit();
  }

  // * CRUD
  final products = <Product>[].obs;

  void updateProductCount(Product product, int count) async {
    try {
      await firestore.collection('products').doc(product.id).update(
        {
          'quantity': count,
        },
      );
      search(searchText.value);
      // ignore: empty_catches
    } catch (e) {}
  }

  void deleteProduct(Product product) async {
    try {
      await firestore.collection('products').doc(product.id).delete();
      successSnackbar('${product.name} ${'deleted'.tr}');
    } catch (e) {
      errorSnackbar('error'.tr);
    }
  }

  int getProductQuantity(Product product) {
    return products.where((p) => p.id == product.id).length;
  }

  Product getProduct(String productId) {
    return products.firstWhere(
      (product) => product.id == productId,
      orElse: () => Product(
        owner: '',
        id: '',
        name: '',
        price: 0,
        quantity: 0,
        code: '',
        image: '',
      ),
    );
  }

  Product getProductByCode(String code) {
    return products.firstWhere(
      (product) => product.code == code,
      orElse: () => Product(
        owner: '',
        id: '',
        name: '',
        price: 0,
        quantity: 0,
        code: '',
        image: '',
      ),
    );
  }

  // * FILTERING
  final searchProducts = <Product>[].obs;
  final searchText = ''.obs;
  final filteredProducts = <Product>[].obs;
  final filterCategories = <String>[].obs;

  void filterProducts() {
    filteredProducts.value = products;
    if (searchText.value.isNotEmpty) {
      filteredProducts.value = products
          .where((product) => product.name
              .toLowerCase()
              .contains(searchText.value.toLowerCase()))
          .toList();
    }
    if (filterCategories.isNotEmpty) {
      filteredProducts.value = filteredProducts.where((product) {
        return filterCategories.contains(product.category);
      }).toList();
    }
  }

  void setFilterCategories(List<String> categories) {
    filterCategories.value = categories;
    filterProducts();
  }

  void search(String searchValue) {
    searchText.value = searchValue;
    searchProducts.value = products
        .where((product) =>
            product.name.toLowerCase().contains(searchValue.toLowerCase()))
        .toList();
    filterProducts();
  }

  final selectedCategory = 'No category'.obs;
  void setCategory(String upcategorydCategory) {
    selectedCategory.value = upcategorydCategory;
  }
}
