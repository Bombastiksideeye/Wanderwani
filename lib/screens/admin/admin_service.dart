import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AdminService extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRecyclingRequests() {
    return _firestore
        .collection('recycling_requests')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> approveRequest(
      String requestId, String userId, int points) async {
    final batch = _firestore.batch();

    try {
      // Get the request document
      final requestDoc = await _firestore
          .collection('recycling_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw 'Request not found';
      }

      // Update request status
      final requestRef =
          _firestore.collection('recycling_requests').doc(requestId);
      batch.update(requestRef, {
        'status': 'approved',
        'pointsAwarded': points,
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Update user's points
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(
          userRef,
          {
            'totalPoints': FieldValue.increment(points),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw 'Failed to approve request: $e';
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      // Get the request document first to check if it exists
      final requestDoc = await _firestore
          .collection('recycling_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw 'Request not found';
      }

      // Delete the request
      await _firestore.collection('recycling_requests').doc(requestId).delete();
    } catch (e) {
      throw 'Failed to delete request: $e';
    }
  }

  Future<Map<String, int>> getTotalRecyclingStats() async {
    Map<String, int> totals = {
      'plastic': 0,
      'glass': 0,
      'metal': 0,
      'electronics': 0,
    };

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('recycling_requests')
          .where('status', isEqualTo: 'approved')
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final quantity = data['quantity'] as int? ?? 0;
        final weight = data['weight'] as int? ?? 0;
        totals['glass'] = (totals['glass'] ?? 0) + quantity;
        totals['plastic'] = (totals['plastic'] ?? 0) + weight;
        totals['metal'] = (totals['metal'] ?? 0) + weight;
        totals['electronics'] = (totals['electronics'] ?? 0) + weight;
      }

      return totals;
    } catch (e) {
      throw 'Failed to get recycling stats: $e';
    }
  }

  Future<int> calculatePoints(String materialType, String? metalType,
      double weight, int? quantity) async {
    try {
      final pricingDoc = await FirebaseFirestore.instance
          .collection('pricing')
          .doc('current')
          .get();

      if (!pricingDoc.exists) {
        throw 'Pricing information not found';
      }

      final pricing = pricingDoc.data() as Map<String, dynamic>;

      if (materialType.toLowerCase() == 'glass') {
        final pricePerItem = pricing['glass'] as double;
        return (pricePerItem * (quantity ?? 0)).round();
      } else if (materialType.toLowerCase() == 'metal') {
        final metalPrices = pricing['metal'] as Map<String, dynamic>;
        final pricePerKg = metalPrices[metalType ?? 'Other'] as double;
        return (pricePerKg * weight).round();
      } else {
        final pricePerKg = pricing[materialType.toLowerCase()] as double;
        return (pricePerKg * weight).round();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating points: $e');
      }
      return 0;
    }
  }

  RxList<Map<String, dynamic>> activityLogs = <Map<String, dynamic>>[].obs;

  Future<void> fetchActivityData() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('userActivities').get();

      activityLogs.value = querySnapshot.docs.map((doc) {
        return {
          "email": doc["email"],
          "ip": doc["ipAddress"],
          "date": doc["date"],
          "time": doc["time"],
          "action": doc["action"],
          "description": doc["description"],
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching activity logs: $e");
      }
    }
  }
}
