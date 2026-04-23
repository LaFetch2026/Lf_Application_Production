// ignore_for_file: avoid_print

class MenuItem {
  final int id;
  final String label;
  final String type;
  final int? refId;
  final String link;
  final int sortOrder;
  final bool isVisible;
  final String? image;
  final String? banner;
  final List<MenuItem> children;

  const MenuItem({
    required this.id,
    required this.label,
    required this.type,
    this.refId,
    required this.link,
    required this.sortOrder,
    required this.isVisible,
    this.image,
    this.banner,
    required this.children,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Handle both the new menu-v2 shape { label, type, refId, link, ... }
    // and the old category-hierarchy fallback shape { name, id, ... }
    // when USE_DYNAMIC_MENU is false on the server.
    final label = (json['label'] as String?)?.isNotEmpty == true
        ? json['label'] as String
        : (json['name'] as String?) ?? '';

    final type = (json['type'] as String?)?.isNotEmpty == true
        ? json['type'] as String
        : 'super_category';

    // refId: new shape uses 'refId', old shape uses 'id'
    final refId = json['refId'] as int? ?? json['id'] as int?;

    // link: new shape provides it, old shape doesn't
    final link = (json['link'] as String?)?.isNotEmpty == true
        ? json['link'] as String
        : _inferLink(type, refId, json);

    return MenuItem(
      id: (json['id'] as int?) ?? 0,
      label: label,
      type: type,
      refId: refId,
      link: link,
      sortOrder: (json['sortOrder'] as int?) ?? (json['sort_order'] as int?) ?? 0,
      isVisible: (json['isVisible'] as bool?) ?? (json['is_visible'] as bool?) ?? true,
      image: json['image'] as String?,
      banner: json['banner'] as String?,
      children: ((json['children'] as List<dynamic>?) ?? [])
          .map((c) => MenuItem.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Infer a link when the old category-hierarchy shape is returned
  static String _inferLink(String type, int? refId, Map<String, dynamic> json) {
    if (type == 'super_category') {
      final slug = (json['slug'] as String?) ??
          (json['name'] as String? ?? '').toLowerCase().replaceAll(' ', '-');
      return '/shop/$slug';
    }
    if (type == 'category' && refId != null) return '/categories?catId=$refId';
    if (type == 'sub_category' && refId != null) return '/products?subCatId=$refId';
    return '#';
  }

  /// Slug for super_category links like /shop/men → "men"
  String? get shopSlug {
    if (link.startsWith('/shop/')) {
      return link.split('/shop/').last;
    }
    // Fallback: derive from label for old-shape items
    return label.toLowerCase().replaceAll(' ', '-');
  }

  /// Maps the slug to the gender int used by the app (1=Men, 2=Women, 3=Accessories).
  /// For unknown/new sections (e.g. TEST tab), returns the item's own id so
  /// each section gets a unique value and doesn't collide with the known three.
  int get genderValue {
    final slug = shopSlug?.toLowerCase() ?? '';
    if (slug == 'men' || slug.contains('men') && !slug.contains('women')) return 1;
    if (slug == 'women' || slug.contains('women')) return 2;
    if (slug == 'accessories' || slug.contains('accessor') || slug.contains('essential')) return 3;
    // Unknown section — use the item's own DB id as a unique gender key
    return id;
  }
}
