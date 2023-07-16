import 'package:get/get.dart';

import '../models/client_model.dart';
import '../services/firestore_db.dart';
import '../utils/constants.dart';

class ClientController extends GetxController {
  @override
  void onInit() {
    try {
      clients.bindStream(FirestoreDb().getClients());
      searchClients.value = clients;
      // ignore: empty_catches
    } catch (e) {}
    super.onInit();
  }

  // * CRUD
  final clients = <Client>[].obs;
  Client getClient(String clientId) {
    return clients.firstWhere((client) => client.id == clientId,
        orElse: () => Client(
              owner: '',
              id: '',
              name: '',
              phone: '',
              date: DateTime.now(),
            ));
  }

  void updateDebt(Client client, double debt) async {
    try {
      await firestore.collection('clients').doc(client.id).update(
        {
          'debt': debt,
        },
      );
    } catch (e) {
      errorSnackbar(e.toString());
    }
  }

  void deleteClient(String clientId) async {
    try {
      await firestore.collection('clients').doc(clientId).delete();
      successSnackbar('${'client'.tr} ${'deleted'.tr}');
    } catch (e) {
      errorSnackbar(e.toString());
    }
  }

  // * FILTERING
  final searchClients = <Client>[].obs;
  final sortCategory = 'name'.obs;

  void search(String searchText) {
    searchClients.value = clients
        .where((client) =>
            client.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  void sort(String category) {
    sortCategory.value = category;
    switch (category) {
      case 'name':
        searchClients.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'debt':
        searchClients.sort((a, b) => b.debt.compareTo(a.debt));
        break;
      case 'date':
        searchClients.sort((a, b) => b.date.compareTo(a.date));
        break;
      default:
        searchClients.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  void setSortCategoryValue(String value) {
    sortCategory.value = value;
  }
}
