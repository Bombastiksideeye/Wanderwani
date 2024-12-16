import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GeneralController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  var pricing = {}.obs;

  Future<void> fetchPricing() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('pricing').doc('current').get();
      if (documentSnapshot.exists) {
        pricing.value = documentSnapshot.data() as Map;
      }
    } catch (e) {
      log('Error $e');
    }
  }
}
