import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/food_item.dart';

class FoodApiService {
  const FoodApiService();

  static const String _collection = 'recipes';
  static const String _dummyEndpoint = 'https://dummyjson.com/recipes?limit=100';
  static const Duration _timeout = Duration(seconds: 12);
  static bool _seededChecked = false;

  Future<void> _seedFromDummyJsonIfNeeded() async {
    if (_seededChecked) {
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final existing = await firestore
        .collection(_collection)
        .limit(1)
        .get()
        .timeout(_timeout);
    if (existing.docs.isNotEmpty) {
      _seededChecked = true;
      return;
    }

    final response = await http.get(Uri.parse(_dummyEndpoint)).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Không thể tải dữ liệu nguồn để import Firebase.');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final recipes = data['recipes'];
    if (recipes is! List) {
      throw Exception('Dữ liệu nguồn không hợp lệ để import Firebase.');
    }

    final batch = firestore.batch();
    for (final recipe in recipes) {
      if (recipe is! Map<String, dynamic>) {
        continue;
      }

      final id = (recipe['id'] ?? '').toString();
      if (id.isEmpty) {
        continue;
      }

      final docRef = firestore.collection(_collection).doc(id);
      batch.set(docRef, recipe, SetOptions(merge: true));
    }

    await batch.commit().timeout(_timeout);
    _seededChecked = true;
  }

  Future<List<FoodItem>> fetchMenuItems() async {
    try {
      try {
        await _seedFromDummyJsonIfNeeded().timeout(_timeout);
      } catch (_) {
      }

      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .get()
          .timeout(_timeout);

      final allItems = snapshot.docs
          .map((doc) => FoodItem.fromJson(doc.data(), fallbackId: doc.id))
          .toList();

      final uniqueById = <String, FoodItem>{
        for (final item in allItems) item.id: item,
      };

      final result = uniqueById.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return result;
    } on FirebaseException catch (error) {
      throw Exception(
        'Lỗi Firebase (${error.code}). Vui lòng kiểm tra cấu hình Firestore.',
      );
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    } catch (_) {
      throw Exception('Mất kết nối mạng. Vui lòng kiểm tra Internet và thử lại.');
    }
  }
}
