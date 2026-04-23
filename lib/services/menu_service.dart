// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constant/constants.dart';
import '../models/menu_item_model.dart';

class MenuService {
  Future<List<MenuItem>> getMenu() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/menu-v2');
    print('📤 Fetching menu: $uri');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 20));

    print('📥 Menu status: ${response.statusCode}');

    // Log the raw body so we can see exactly what the server returns
    final bodyPreview = response.body.length > 500
        ? '${response.body.substring(0, 500)}...'
        : response.body;
    print('📥 Menu raw body: $bodyPreview');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = (decoded['data'] as List?) ?? [];

      print('📥 Menu data items: ${data.length}');
      for (int i = 0; i < data.length; i++) {
        final item = data[i] as Map<String, dynamic>;
        print('  [$i] id=${item['id']} label=${item['label']} '
            'name=${item['name']} type=${item['type']} '
            'children=${(item['children'] as List?)?.length ?? 0}');
      }

      // Filter to only super_category (root) items — handles both shapes:
      // new shape: type == 'super_category'
      // old shape: no type field, all items are root-level super categories
      final roots = data
          .map((item) => item as Map<String, dynamic>)
          .where((item) {
            final type = item['type'] as String?;
            // If type is present, only keep super_category
            // If type is absent (old shape), keep everything at root level
            return type == null || type == 'super_category';
          })
          .map((item) => MenuItem.fromJson(item))
          .toList();

      print('📥 Menu root items after filter: ${roots.length}');
      for (final r in roots) {
        print('  → id=${r.id} label="${r.label}" genderValue=${r.genderValue}');
      }

      return roots;
    }

    throw Exception('Failed to load menu: ${response.statusCode}');
  }
}
