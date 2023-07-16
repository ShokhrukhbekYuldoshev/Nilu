import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/controllers/theme_controller.dart';

import '../ui/screens/auth/otp_screen.dart';
import 'package:nilu/utils/constants.dart';
import 'package:nilu/utils/preferences.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final ProfileController _profileController = Get.put(ProfileController());
  late Rx<User?> _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs;
  final RxString mainCurrency = ''.obs;
  final RxString secondaryCurrency = ''.obs;

  final phoneNumber = ''.obs;
  String verificationID = "";
  final loginSuccess = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    Future.delayed(Duration.zero, () async {
      if (Preferences.isLoggedIn()) {
        await _profileController.updateUserData();
        Get.offAllNamed('/home');
      } else if (user == null) {
        Get.offAllNamed('/login');
      }
    });
  }

  void loginWithPhone(
      String phone, String verificationId, BuildContext context) async {
    loginSuccess.value = false;

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential).then(
              (value) {
                var snapshot = firestore
                    .collection('users')
                    .where('phone', isEqualTo: phoneNumber.value)
                    .get();

                snapshot.then((value) async {
                  if (value.docs.isEmpty) {
                    Navigator.pushNamed(context, '/register');
                  } else {
                    await _profileController.updateUserData();
                    await Preferences.setPhone(phoneNumber.value);
                    await Preferences.setLoggedIn(true);
                    Get.offAllNamed('/home');
                  }
                });
              },
            );
          } on FirebaseAuthException catch (e) {
            errorSnackbar(e.message!);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          errorSnackbar(e.message!);
          isLoading.value = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          phoneNumber.value += phone;
          loginSuccess.value = true;
          verificationID = verificationId;
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) {
                return OtpScreen(
                  phone: phone,
                );
              },
            ),
          );
          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      errorSnackbar(e.message!);
    }
  }

  void verifyOTP(
      String sms, String verificationID, BuildContext context) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID,
        smsCode: sms,
      );
      await _auth.signInWithCredential(credential).then(
        (value) {
          var snapshot = firestore
              .collection('users')
              .where('phone', isEqualTo: phoneNumber.value)
              .get();

          snapshot.then((value) async {
            if (value.docs.isEmpty) {
              Navigator.pushNamed(context, '/register');
            } else {
              await _profileController.updateUserData();
              await Preferences.setPhone(phoneNumber.value);
              await Preferences.setLoggedIn(true);
              Get.offAllNamed('/home');
            }
          });
        },
      );
    } on FirebaseAuthException catch (e) {
      errorSnackbar(e.message!);
    }
  }

  void resendOTP(BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential).then(
              (value) {
                var snapshot = firestore
                    .collection('users')
                    .where('phone', isEqualTo: phoneNumber.value)
                    .get();

                snapshot.then((value) async {
                  if (value.docs.isEmpty) {
                    Navigator.pushNamed(context, '/register');
                  } else {
                    await _profileController.updateUserData();
                    await Preferences.setPhone(phoneNumber.value);
                    await Preferences.setLoggedIn(true);
                    Get.offAllNamed('/home');
                  }
                });
              },
            );
          } on FirebaseAuthException catch (e) {
            errorSnackbar(e.message!);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          errorSnackbar(e.message!);
          isLoading.value = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationID = verificationId;
          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      errorSnackbar(e.message!);
    }
  }

  void register(
    String name,
    String phone,
    String business,
    String mainCurrency,
    String secondaryCurrency,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('users').add({
        'phone': phoneNumber.value,
        'name': name,
        'business': business,
        'image': '',
        'categories': [],
        'mainCurrency': mainCurrency,
        'secondaryCurrency': secondaryCurrency,
        'date': DateTime.now(),
      });
      await Preferences.setPhone(phoneNumber.value);
      await Preferences.setLoggedIn(true);
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      errorSnackbar(e.message!);
    }
  }

  void logout(context) {
    try {
      _auth.signOut();
      Get.deleteAll();
      Get.put(ThemeController());
      Get.offAllNamed('/login');
    } on FirebaseAuthException catch (e) {
      errorSnackbar(e.message!);
    }
  }
}
