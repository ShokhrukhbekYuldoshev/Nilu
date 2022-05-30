import 'package:get/get.dart';
import 'package:nilu/models/profile_model.dart';

import '../utils/constants.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get user => _user.value;
  final Rx<String> _phone = "".obs;

  updateUserPhone(String phone) async {
    _phone.value = phone;
    await updateUserData();
  }

  updateUserData() async {
    try {
      var user = await firestore
          .collection('users')
          .where('phone', isEqualTo: _phone.value)
          .get()
          .then((value) => ProfileModel.fromSnapshot(value.docs.first));

      _user.value = {
        'name': user.name,
        'business': user.business,
        'image': user.image,
        'categories': user.categories,
        'phone': user.phone,
        'id': user.id,
        'mainCurrency': user.mainCurrency,
        'secondaryCurrency': user.secondaryCurrency,
        'date': user.date,
      };
      // ignore: empty_catches
    } catch (e) {}

    update();
  }
}
